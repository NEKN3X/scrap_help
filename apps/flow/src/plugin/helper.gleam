import ffi/jsonrpc
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import plugin/context
import plugin/query
import plugin/response

pub fn initialize(connection, f) {
  use params <- jsonrpc.on_request(connection, "initialize")
  let assert Ok(context) = context.decode(params)
  f(context)
  json.object([])
}

pub fn query(
  connection,
  settings_decoder,
  f: fn(query.Query, settings) -> List(response.JSONRPCResponse),
) {
  use query, settings <- jsonrpc.on_query(connection)
  let assert Ok(query) = query.decode(query)
  let assert Ok(settings) = decode.run(settings, settings_decoder)
  let result = f(query, settings) |> response.to_json
  json.object([#("result", json.preprocessed_array(result))])
}

pub fn on(connection, method, handler: fn(dynamic.Dynamic) -> Nil) {
  jsonrpc.on_request(connection, method, fn(params) {
    handler(params)
    json.object([])
  })
}

pub fn show_message(connection, message) {
  jsonrpc.send_request(
    connection,
    "ShowMsg",
    json.object([#("title", json.string(message))]),
  )
}

pub fn copy_text(connection, text) {
  jsonrpc.send_request(
    connection,
    "CopyToClipboard",
    json.object([#("text", json.string(text))]),
  )
}

pub fn open_url(connection, url) {
  jsonrpc.send_request(
    connection,
    "OpenUrl",
    json.object([#("url", json.string(url))]),
  )
}
