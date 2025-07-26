import core
import gleam/dynamic/decode
import gleam/fetch
import gleam/http/request
import gleam/javascript/promise
import gleam/option.{type Option, None, Some}
import gleam/result

fn fetch_scrapbox(path: String, sid: Option(String)) {
  let host = "scrapbox.io"
  request.new()
  |> request.set_host(host)
  |> request.set_path("/api" <> path)
  |> fn(req) {
    case sid {
      Some(s) -> request.set_cookie(req, "connect.sid", s)
      None -> req
    }
  }
  |> fetch.send
  |> promise.map(fn(resp) {
    case resp {
      Ok(resp) -> Ok(resp)
      Error(_) -> Error("Failed to fetch")
    }
  })
}

pub fn title_decoder() {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use updated <- decode.field("updated", decode.int)
  decode.success(core.ScrapboxTitle(id, title, updated))
}

pub fn fetch_titles(project: String, sid: Option(String)) {
  let path = "/pages/" <> project <> "/search/titles"
  {
    use resp <- promise.try_await(fetch_scrapbox(path, sid))
    use resp <- promise.map({
      use resp <- promise.map(fetch.read_json_body(resp))
      case resp {
        Ok(resp) -> Ok(resp)
        Error(_) -> Error("Failed to read json body")
      }
    })
    use resp <- result.map(resp)
    decode.run(resp.body, decode.list(title_decoder()))
    |> result.map_error(fn(_) { "Failed to decode titles" })
  }
  |> promise.map(result.flatten)
}

pub fn lines_decoder() {
  use id <- decode.field("id", decode.string)
  use text <- decode.field("text", decode.string)
  decode.success(core.ScrapboxPageLine(id, text))
}

pub fn page_decoder() {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use created <- decode.field("created", decode.int)
  use updated <- decode.field("updated", decode.int)
  use helpfeels <- decode.field("helpfeels", decode.list(decode.string))
  use lines <- decode.field("lines", decode.list(lines_decoder()))
  decode.success(core.ScrapboxPage(
    id,
    title,
    created,
    updated,
    helpfeels,
    lines,
  ))
}

pub fn fetch_page(project: String, title: String, sid: Option(String)) {
  let path = "/pages/" <> project <> "/" <> title
  {
    use resp <- promise.try_await(fetch_scrapbox(path, sid))
    use resp <- promise.map({
      use resp <- promise.map(fetch.read_json_body(resp))
      case resp {
        Ok(resp) -> Ok(resp)
        Error(_) -> Error("Failed to read json body")
      }
    })
    use resp <- result.map(resp)

    decode.run(resp.body, page_decoder())
    |> result.map_error(fn(_) { "Failed to decode page" })
  }
  |> promise.map(result.flatten)
}
