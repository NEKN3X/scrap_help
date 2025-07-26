import ffi/jsonrpc
import gleam/json

pub fn main() -> Nil {
  let connection = jsonrpc.create_connection()
  jsonrpc.on_request(connection, "initialize", fn(_) { json.object([]) })
  jsonrpc.on_request(connection, "query", fn(_) { json.object([]) })
  jsonrpc.listen(connection)
}
