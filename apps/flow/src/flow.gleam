import ffi/jsonrpc
import gleam/json

pub fn main() -> Nil {
  let connection = jsonrpc.create_connection()
  let on_request = fn(method, handler) {
    jsonrpc.on_request(connection, method, handler)
  }
  on_request("initialize", fn(_) { json.object([]) })
  on_request("query", fn(_) { json.object([]) })
  jsonrpc.listen(connection)
}
