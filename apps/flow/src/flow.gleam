import ffi/jsonrpc
import gleam/json

pub fn main() -> Nil {
  jsonrpc.create_connection()
  |> jsonrpc.on_request("initialize", fn(_) { json.object([]) })
  |> jsonrpc.on_request("query", fn(_) { json.object([]) })
  |> jsonrpc.listen
}
