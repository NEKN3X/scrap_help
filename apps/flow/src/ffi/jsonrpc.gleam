import gleam/dynamic
import gleam/javascript/promise
import gleam/json

pub type MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "createConnection")
pub fn create_connection() -> MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
fn on_request_js(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
fn on_request_async_js(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> promise.Promise(json.Json),
) -> Nil

pub fn on_request(a, b, c) {
  on_request_js(a, b, c)
  a
}

pub fn on_request_async(a, b, c) {
  on_request_async_js(a, b, c)
  a
}

@external(javascript, "./dist/jsonrpc_ffi.js", "sendRequest")
pub fn send_request(
  connection: MessageConnection,
  method: String,
  params: json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "sendRequest")
pub fn send_return_request(
  connection: MessageConnection,
  method: String,
  params: json.Json,
) -> a

@external(javascript, "./dist/jsonrpc_ffi.js", "listen")
pub fn listen(connection: MessageConnection) -> Nil
