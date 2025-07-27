import gateway/dto/scrapbox_page
import gateway/dto/scrapbox_title
import gateway/ffi/uri
import gleam/dynamic/decode
import gleam/fetch
import gleam/http/request
import gleam/javascript/promise
import gleam/option.{type Option, None, Some}
import gleam/result

pub type ScrapboxApiError {
  FailedToFetch
  FailedToReadJsonBody
  FailedToDecode
}

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
  |> promise.map(result.map_error(_, fn(_) { FailedToFetch }))
}

pub fn fetch_titles(project: String, sid: Option(String)) {
  let path = "/pages/" <> project <> "/search/titles"
  use resp <- promise.try_await(fetch_scrapbox(path, sid))
  fetch.read_json_body(resp)
  |> promise.map(result.map_error(_, fn(_) { FailedToReadJsonBody }))
  |> promise.map_try(fn(resp) {
    decode.run(resp.body, decode.list(scrapbox_title.decoder()))
    |> result.replace_error(FailedToDecode)
  })
}

pub fn fetch_page(project: String, title: String, sid: Option(String)) {
  let path = "/pages/" <> project <> "/" <> uri.encode_uri_component(title)
  use resp <- promise.try_await(fetch_scrapbox(path, sid))
  fetch.read_json_body(resp)
  |> promise.map(result.map_error(_, fn(_) { FailedToReadJsonBody }))
  |> promise.map_try(fn(resp) {
    decode.run(resp.body, scrapbox_page.decoder())
    |> result.replace_error(FailedToDecode)
  })
}
