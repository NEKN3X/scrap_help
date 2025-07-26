import core/help
import core/scrapbox
import ffi/fuse
import ffi/jsonrpc
import gateway/gateway
import get_all_helps
import gleam/dict
import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/string
import plugin/context
import plugin/query
import plugin/response
import public_types
import settings

pub fn make_result(
  _connection: jsonrpc.MessageConnection,
  query: query.Query,
  settings: settings.Settings,
  ctx: context.Context,
) -> promise.Promise(List(response.JSONRPCResponse)) {
  use projects <- promise.map(gateway.get_projects(
    settings.projects,
    Some(settings.sid),
  ))
  let terms =
    case query.search_terms {
      [_, ..xs] -> xs
      _ -> []
    }
    |> string.join(" ")
  let glossary = case terms {
    "" -> public_types.Glossary(dict.from_list([]))
    _ -> public_types.Glossary(dict.from_list([#("query", terms)]))
  }
  get_all_helps.workflow().run(projects, glossary)
  |> list.append(
    projects
    |> list.flat_map(fn(project) {
      pages_to_helps(project, settings.ignore_title_pattern)
    }),
  )
  |> fuse.search(query.search, fuse.FuseOptions(["command"]))
  |> list.fold([], fn(acc: List(fuse.FuseResult(help.Help)), result) {
    let find_dup = acc |> list.find(fn(r) { dup(r.item, result.item) })
    case find_dup {
      Ok(_) -> acc
      _ -> acc |> list.append([result])
    }
  })
  |> list.map(fn(result) { help_to_item(result, ctx.metadata.action_keyword) })
}

fn scrapbox_url(project: String, page: String) {
  "https://scrapbox.io/" <> project <> "/" <> page
}

fn is_scrapbox_url(url: String) {
  url |> string.starts_with("https://scrapbox.io/")
}

fn format_url(url: String) {
  url
  |> string.replace("https://scrapbox.io", "")
  |> string.replace("https://", "")
  |> string.replace("http://", "")
  |> string.replace("www.", "")
}

fn help_to_item(result: fuse.FuseResult(help.Help), keyword: String) {
  let highlight =
    result.matches
    |> list.flat_map(fn(match) {
      match.indices
      |> list.flat_map(fn(indexex) {
        let assert Ok(start) = list.first(indexex)
        let assert Ok(end) = list.last(indexex)
        list.range(start, end)
      })
    })
  let auto_complete_text = keyword <> " " <> result.item.command
  let score = result.score |> float.multiply(100.0) |> float.round |> int.negate
  case result.item {
    help.ScrapTextHelp(_, _, command, text) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(text),
        glyph: None,
        auto_complete_text: Some(auto_complete_text),
        title_highlight_data: Some(highlight),
        ico_path: Some("assets/clipboard-solid-full.png"),
        json_rpc_action: response.JSONRPCAction("copy_text", [
          response.StringParam(text),
        ]),
        context_data: Some([
          response.JSONRPCResponse(
            title: "Open in Scrapbox",
            sub_title: Some(
              format_url(scrapbox_url(result.item.project, result.item.page)),
            ),
            glyph: None,
            auto_complete_text: None,
            title_highlight_data: None,
            ico_path: Some("assets/note-sticky-solid-full.png"),
            json_rpc_action: response.JSONRPCAction("open_url", [
              response.StringParam(scrapbox_url(
                result.item.project,
                result.item.page,
              )),
            ]),
            context_data: None,
            score: None,
          ),
        ]),
        score: Some(score),
      )
    }
    help.ScrapUrlHelp(p, _, command, url) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(case is_scrapbox_url(url) {
          True -> "/" <> p
          False -> format_url(url)
        }),
        auto_complete_text: Some(auto_complete_text),
        title_highlight_data: Some(highlight),
        glyph: None,
        ico_path: Some(case is_scrapbox_url(url) {
          True -> "assets/note-sticky-solid-full.png"
          False -> "assets/globe-solid-full.png"
        }),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: Some([
          response.JSONRPCResponse(
            title: "Open in Scrapbox",
            sub_title: Some(
              format_url(scrapbox_url(result.item.project, result.item.page)),
            ),
            glyph: None,
            auto_complete_text: None,
            title_highlight_data: None,
            ico_path: Some("assets/note-sticky-solid-full.png"),
            json_rpc_action: response.JSONRPCAction("open_url", [
              response.StringParam(scrapbox_url(
                result.item.project,
                result.item.page,
              )),
            ]),
            context_data: None,
            score: None,
          ),
        ]),
        score: Some(score),
      )
    }
    help.ScrapUrlHelpWithTitle(p, _, command, url, _) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(case is_scrapbox_url(url) {
          True -> "/" <> p
          False -> format_url(url)
        }),
        auto_complete_text: Some(auto_complete_text),
        title_highlight_data: Some(highlight),
        glyph: None,
        ico_path: Some(case is_scrapbox_url(url) {
          True -> "assets/note-sticky-solid-full.png"
          False -> "assets/globe-solid-full.png"
        }),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: Some([
          response.JSONRPCResponse(
            title: "Open in Scrapbox",
            sub_title: Some(
              format_url(scrapbox_url(result.item.project, result.item.page)),
            ),
            glyph: None,
            auto_complete_text: None,
            title_highlight_data: None,
            ico_path: Some("assets/note-sticky-solid-full.png"),
            json_rpc_action: response.JSONRPCAction("open_url", [
              response.StringParam(scrapbox_url(
                result.item.project,
                result.item.page,
              )),
            ]),
            context_data: None,
            score: None,
          ),
        ]),
        score: Some(score),
      )
    }
  }
}

fn dup(a: help.Help, b: help.Help) {
  a.project == b.project && a.page == b.page && a.content == b.content
}

fn pages_to_helps(
  project: scrapbox.ScrapboxProject,
  ignore_pattern: regexp.Regexp,
) {
  project.pages
  |> list.filter_map(fn(page) {
    case regexp.check(ignore_pattern, page.title) {
      True -> Error(Nil)
      False -> {
        let title = page.title
        let url = scrapbox_url(project.name, title)
        Ok(help.ScrapUrlHelp(project.name, title, title, url))
      }
    }
  })
}
