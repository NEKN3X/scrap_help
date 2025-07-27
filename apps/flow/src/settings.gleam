import gleam/dynamic/decode
import gleam/list
import gleam/regexp
import gleam/string

pub type Settings {
  Settings(
    projects: List(String),
    sid: String,
    ignore_title_pattern: regexp.Regexp,
  )
}

pub fn decoder() {
  use projects <- decode.field("projects", decode.string)
  use sid <- decode.field("sid", decode.string)
  use ignore_title_pattern <- decode.field(
    "ignore_title_pattern",
    decode.string,
  )
  let projects = projects |> string.split(",") |> list.map(string.trim)
  let assert Ok(ignore_re) = regexp.from_string(ignore_title_pattern)
  decode.success(Settings(projects, sid, ignore_re))
}
