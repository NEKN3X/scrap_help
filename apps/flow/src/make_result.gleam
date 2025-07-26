import ffi/fuse
import ffi/jsonrpc
import gleam/list
import gleam/option.{None}
import plugin/context
import plugin/query
import plugin/response
import settings

pub fn make_result(
  _connection: jsonrpc.MessageConnection,
  query: query.Query,
  _settings: settings.Settings,
  _context: context.Context,
) -> List(response.JSONRPCResponse) {
  fuse.search(
    [
      response.JSONRPCResponse(
        title: "Hello, Flow!",
        sub_title: None,
        glyph: None,
        ico_path: None,
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam("https://example.com"),
        ]),
        context_data: None,
        score: None,
      ),
      response.JSONRPCResponse(
        title: "Hello, World!",
        sub_title: None,
        glyph: None,
        ico_path: None,
        json_rpc_action: response.JSONRPCAction("open_url", [
          response.StringParam("https://example.com"),
        ]),
        context_data: None,
        score: None,
      ),
    ],
    query.search,
    fuse.FuseOptions(["title", "sub_title"]),
  )
  |> list.map(fn(result) { result.item })
}
