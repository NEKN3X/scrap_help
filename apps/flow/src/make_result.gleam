import core/help
import ffi/jsonrpc
import gateway/get_projects
import gleam/javascript/promise
import gleam/list
import gleam/option
import plugin/context
import plugin/query
import plugin/response
import settings
import workflow/get_all_helps

pub fn make_result(
  _connection: jsonrpc.MessageConnection,
  _query: query.Query,
  settings: settings.Settings,
  _ctx: context.Context,
) -> promise.Promise(List(response.JSONRPCResponse)) {
  let get_projects = get_projects.usecase(_, option.Some(settings.sid))
  get_all_helps.workflow(get_projects).run(settings.projects)
  |> promise.map(list.map(_, help_to_item))
  |> promise.map(option.values)
}

fn help_to_item(result: help.Help) {
  text_help_to_item(result)
  |> option.or(url_help_to_item(result))
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
        ico_path: option.Some("assets/clipboard-solid-full.png"),
        json_rpc_action: response.JSONRPCAction("copy_text", [
          response.StringParam(text),
        ]),
        context_data: option.Some([]),
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
        sub_title: option.Some(url),
        auto_complete_text: option.None,
        title_highlight_data: option.None,
        glyph: option.None,
        ico_path: option.Some("assets/globe-solid-full.png"),
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam(url),
        ]),
        context_data: option.Some([]),
        score: option.None,
      ))
    }
    _ -> option.None
  }
}
