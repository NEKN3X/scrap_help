import gleam/dynamic
import gleam/dynamic/decode
import gleam/javascript/promise
import gleam/json

pub type MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "createConnection")
pub fn create_connection() -> MessageConnection

@external(javascript, "./dist/jsonrpc_ffi.js", "initialize")
pub fn initialize(
  connection: MessageConnection,
  handler: fn(dynamic.Dynamic) -> json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
pub fn on_request(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
pub fn on_request_async(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> promise.Promise(json.Json),
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onRequest")
pub fn context_menu(
  connection: MessageConnection,
  method: String,
  handler: fn(dynamic.Dynamic) -> decode.Dynamic,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onQuery")
pub fn on_query(
  connection: MessageConnection,
  handler: fn(dynamic.Dynamic, dynamic.Dynamic) -> json.Json,
) -> Nil

@external(javascript, "./dist/jsonrpc_ffi.js", "onQuery")
pub fn on_query_async(
  connection: MessageConnection,
  handler: fn(dynamic.Dynamic, dynamic.Dynamic) -> promise.Promise(json.Json),
) -> Nil

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
