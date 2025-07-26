import ffi/jsonrpc
import gleam/dynamic/decode
import make_result
import plugin/helper
import settings

pub fn main() -> Nil {
  let connection = jsonrpc.create_connection()
  helper.initialize(connection, fn(context) {
    use query, settings <- helper.query(connection, settings.decoder())
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
