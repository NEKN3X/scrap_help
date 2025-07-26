import ffi/jsonrpc
import gleam/option.{None}
import gleam/regexp
import plugin/context
import plugin/helper
import plugin/query
import plugin/response

pub type Settings {
  Settings(
    projects: List(String),
    sid: String,
    ignore_title_pattern: regexp.Regexp,
    bookmark_pattern: regexp.Regexp,
  )
}

pub fn make_result(
  connection: jsonrpc.MessageConnection,
  query: query.Query,
  settings: Settings,
  context: context.Context,
) -> List(response.JSONRPCResponse) {
  helper.show_message(connection, "Example Message")
  [
    response.JSONRPCResponse(
      title: "Example Response",
      sub_title: None,
      glyph: None,
      ico_path: None,
      json_rpc_action: response.JSONRPCAction(
        method: "example.method",
        parameters: [],
      ),
      context_data: None,
      score: None,
    ),
  ]
}
