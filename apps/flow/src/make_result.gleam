import ffi/jsonrpc
import gleam/javascript/promise
import plugin/context
import plugin/query
import plugin/response
import settings

pub fn make_result(
  _connection: jsonrpc.MessageConnection,
  _query: query.Query,
  _settings: settings.Settings,
  _ctx: context.Context,
) -> promise.Promise(List(response.JSONRPCResponse)) {
  promise.resolve([])
}
