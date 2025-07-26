import ffi/jsonrpc
import gleam/dynamic/decode
import gleam/list
import gleam/regexp
import gleam/string
import make_result
import plugin/helper

pub fn settings_decoder() {
  use projects <- decode.field("projects", decode.string)
  use sid <- decode.field("sid", decode.string)
  use ignore_title_pattern <- decode.field(
    "ignore_title_pattern",
    decode.string,
  )
  use bookmark_pattern <- decode.field("bookmark_pattern", decode.string)
  let projects = projects |> string.split(",") |> list.map(string.trim)
  let assert Ok(ignore_re) = regexp.from_string(ignore_title_pattern)
  let assert Ok(bookmark_re) = regexp.from_string(bookmark_pattern)
  decode.success(make_result.Settings(projects, sid, ignore_re, bookmark_re))
}

pub fn main() -> Nil {
  let connection = jsonrpc.create_connection()
  helper.initialize(connection, fn(context) {
    use query, settings <- helper.query(connection, settings_decoder())
    make_result.make_result(connection, query, settings, context)
  })

  helper.on(connection, "open_url", fn(params) {
    {
      case decode.run(params, decode.list(decode.string)) {
        Ok([url]) -> helper.open_url(connection, url)
        _ -> Nil
      }
    }
  })

  helper.on(connection, "show_message", fn(params) {
    {
      case decode.run(params, decode.string) {
        Ok(message) -> helper.show_message(connection, message)
        _ -> Nil
      }
    }
  })

  helper.on(connection, "copy_text", fn(params) {
    {
      case decode.run(params, decode.string) {
        Ok(message) -> helper.copy_text(connection, message)
        _ -> Nil
      }
    }
  })

  jsonrpc.listen(connection)
}
