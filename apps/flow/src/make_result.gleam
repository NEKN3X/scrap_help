import core/help
import core/helpfeel
import ffi/fuse
import ffi/jsonrpc
import gateway/gateway
import get_all_helps
import gleam/dict
import gleam/javascript/promise
import gleam/list
import gleam/option.{None, Some}
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
  _context: context.Context,
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
  let glossary = public_types.Glossary(dict.from_list([#("query", terms)]))
  get_all_helps.workflow().run(projects, glossary)
  |> list.map(fn(help) { help_to_item(help) })
  |> fuse.search(query.search, fuse.FuseOptions(["title", "sub_title"]))
  |> list.map(fn(result) { result.item })
}

fn scrapbox_url(project: String, page: String) {
  "https://scrapbox.io/" <> project <> "/" <> page
}

fn help_to_item(help: help.Help) {
  case help {
    help.ScrapTextHelp(_, _, command, text) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(text),
        glyph: None,
        ico_path: None,
        json_rpc_action: response.JSONRPCAction("copy_text", [
          response.StringParam(text),
        ]),
        context_data: None,
        score: None,
      )
    }
    help.ScrapUrlHelp(_, _, command, url) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(url),
        glyph: None,
        ico_path: None,
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: None,
        score: None,
      )
    }
    help.ScrapUrlHelpWithTitle(_, _, command, url, title) -> {
      response.JSONRPCResponse(
        title: command,
        sub_title: Some(title),
        glyph: None,
        ico_path: None,
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: None,
        score: None,
      )
    }
  }
}
