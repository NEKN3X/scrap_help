import gleam/dynamic
import gleam/json

pub type MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "createConnection")
pub fn create_connection() -> MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
pub fn on_request(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "sendRequest")
pub fn send_request(
  connection: MessageConnection,
  method: String,
  params: json.Json,
) -> a

@external(javascript, "./dist/jsonrpc_ffi.js", "listen")
pub fn listen(connection: MessageConnection) -> Nil
