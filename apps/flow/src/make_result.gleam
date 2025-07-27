import core/help
import core/parser
import core/scrapbox
import ffi/fuse
import ffi/jsonrpc
import gateway/get_projects
import gleam/dict
import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import plugin/context
import plugin/query
import plugin/response
import settings
import workflow/get_all_helps

pub fn make_result(
  _connection: jsonrpc.MessageConnection,
  query: query.Query,
  settings: settings.Settings,
  _ctx: context.Context,
) -> promise.Promise(List(response.JSONRPCResponse)) {
  let get_projects = get_projects.usecase(_, option.Some(settings.sid))
  let glossary =
    dict.from_list([
      #("query", query.search_terms |> list.drop(1) |> string.join(" ")),
    ])
  let workflow = get_all_helps.workflow(get_projects)
  use helps <- promise.await(workflow.run(settings.projects))
  list.map(helps, replace_help_with_glossary(_, glossary))
  |> list.filter_map(ignore_page(_, settings.ignore_title_pattern))
  |> list.flat_map(expand_help_feel)
  |> list.map(help_to_item)
  |> option.values
  |> fuse.search(query.search, fuse.FuseOptions(["title", "sub_title"]))
  |> list.map(fn(x) {
    response.JSONRPCResponse(
      ..x.item,
      score: float.multiply(x.score, 100.0)
        |> float.round
        |> int.negate
        |> option.Some,
    )
  })
  |> list.fold([], fn(acc: List(response.JSONRPCResponse), item) {
    let find_dup = acc |> list.find(fn(r) { dup(r, item) })
    case find_dup {
      Ok(_) -> acc
      _ -> acc |> list.append([item])
    }
  })
  |> promise.resolve
}

fn cut_host(url: String) {
  string.replace(url, "http://", "")
  |> string.replace("https://", "")
  |> string.replace("www.", "")
}

fn help_to_item(result: help.Help) {
  text_help_to_item(result)
  |> option.or(url_help_to_item(result))
  |> option.or(bookmark_help_to_item(result))
  |> option.or(page_to_item(result))
}

fn text_help_to_item(result: help.Help) {
  case result {
    help.TextHelp(_, _, command, text) -> {
      option.Some(response.JSONRPCResponse(
        title: command,
        sub_title: option.Some(text),
        glyph: option.None,
        auto_complete_text: option.None,
        title_highlight_data: option.None,
        ico_path: option.Some("assets/clipboard-regular-full.png"),
        json_rpc_action: response.JSONRPCAction("copy_text", [
          response.StringParam(text),
        ]),
        context_data: option.Some([
          open_in_scrapbox(result.project, result.page),
        ]),
        score: option.None,
      ))
    }
    _ -> option.None
  }
}

fn url_help_to_item(result: help.Help) {
  case result {
    help.UrlHelp(_, _, command, url) -> {
      option.Some(response.JSONRPCResponse(
        title: command,
        sub_title: option.Some(cut_host(url)),
        auto_complete_text: option.None,
        title_highlight_data: option.None,
        glyph: option.None,
        ico_path: option.Some("assets/globe-solid-full.png"),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: option.Some([
          open_in_scrapbox(result.project, result.page),
        ]),
        score: option.None,
      ))
    }
    _ -> option.None
  }
}

fn bookmark_help_to_item(result: help.Help) {
  case result {
    help.BookmarkHelp(_, _, command, url) -> {
      option.Some(response.JSONRPCResponse(
        title: command,
        sub_title: option.Some(cut_host(url)),
        auto_complete_text: option.None,
        title_highlight_data: option.None,
        glyph: option.None,
        ico_path: option.Some("assets/bookmark-solid-full.png"),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: option.Some([
          open_in_scrapbox(result.project, result.page),
        ]),
        score: option.None,
      ))
    }
    _ -> option.None
  }
}

fn page_to_item(result: help.Help) {
  case result {
    help.ScrapPage(project, page) -> {
      option.Some(response.JSONRPCResponse(
        title: page,
        sub_title: option.Some("/" <> project),
        auto_complete_text: option.None,
        title_highlight_data: option.None,
        glyph: option.None,
        ico_path: option.Some("assets/note-sticky-regular-full.png"),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(scrapbox.scrapbox_url(project, option.Some(page))),
        ]),
        context_data: option.Some([]),
        score: option.None,
      ))
    }
    _ -> option.None
  }
}

fn replace_with_glossary(text: String, glossary: dict.Dict(String, String)) {
  dict.fold(glossary, text, fn(acc, key, value) {
    string.replace(acc, "{" <> key <> "}", value)
  })
}

fn replace_help_with_glossary(
  help: help.Help,
  glossary: dict.Dict(String, String),
) {
  case help {
    help.TextHelp(_, _, command, text) -> {
      help.TextHelp(
        ..help,
        command: replace_with_glossary(command, glossary),
        text: replace_with_glossary(text, glossary),
      )
    }
    help.UrlHelp(_, _, command, url) -> {
      help.UrlHelp(
        ..help,
        command: replace_with_glossary(command, glossary),
        url: replace_with_glossary(url, glossary),
      )
    }
    help.BookmarkHelp(_, _, command, url) -> {
      help.BookmarkHelp(
        ..help,
        command: replace_with_glossary(command, glossary),
        url: replace_with_glossary(url, glossary),
      )
    }
    _ -> help
  }
}

fn expand_help_feel(help: help.Help) {
  case help {
    // help.ScrapPage(_, _) -> [help]
    help.TextHelp(_, _, command, _) ->
      result.unwrap(parser.expand(command), [command])
      |> list.map(fn(expanded) { help.TextHelp(..help, command: expanded) })
    help.UrlHelp(_, _, command, _) ->
      result.unwrap(parser.expand(command), [command])
      |> list.map(fn(expanded) { help.UrlHelp(..help, command: expanded) })
    help.BookmarkHelp(_, _, command, _) ->
      result.unwrap(parser.expand(command), [command])
      |> list.map(fn(expanded) { help.BookmarkHelp(..help, command: expanded) })
    _ -> [help]
  }
}

fn dup(a: response.JSONRPCResponse, b: response.JSONRPCResponse) {
  a.sub_title == b.sub_title
  && a.json_rpc_action == b.json_rpc_action
  && a.context_data == b.context_data
}

fn ignore_page(help: help.Help, re: regexp.Regexp) {
  case help {
    help.ScrapPage(_, page) ->
      case regexp.check(re, page) {
        True -> Error(Nil)
        False -> Ok(help)
      }
    _ -> Ok(help)
  }
}

fn open_in_scrapbox(project: String, page: String) -> response.JSONRPCResponse {
  response.JSONRPCResponse(
    title: "Open in Scrapbox",
    sub_title: option.Some("/" <> project <> " " <> page),
    auto_complete_text: option.None,
    title_highlight_data: option.None,
    glyph: option.None,
    ico_path: option.Some("assets/note-sticky-regular-full.png"),
    json_rpc_action: response.JSONRPCAction("open_url", [
      response.StringParam(scrapbox.scrapbox_url(project, option.Some(page))),
    ]),
    context_data: option.Some([]),
    score: option.None,
  )
}
