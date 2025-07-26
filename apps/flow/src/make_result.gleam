import ffi/jsonrpc
import gleam/option.{None}
import plugin/context
import plugin/helper
import plugin/query
import plugin/response
import settings

pub fn make_result(
  connection: jsonrpc.MessageConnection,
  query: query.Query,
  settings: settings.Settings,
  context: context.Context,
) -> List(response.JSONRPCResponse) {
  helper.show_message(connection, "Example Message")
  [
    response.JSONRPCResponse(
      title: "Example Response",
      sub_title: None,
      glyph: None,
      ico_path: None,
      json_rpc_action: response.JSONRPCAction("open_url", [
        response.StringParam("https://example.com"),
      ]),
      context_data: None,
      score: None,
    ),
  ]
}
