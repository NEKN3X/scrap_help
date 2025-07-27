import gleam/option
import gleam/regexp

pub type ScrapboxTitle {
  ScrapboxTitle(id: String, title: String, updated: Int)
}

pub type ScrapboxProject {
  ScrapboxProject(name: String, pages: List(ScrapboxPage))
}

pub type ScrapboxPage {
  ScrapboxPage(
    id: String,
    title: String,
    created: Int,
    updated: Int,
    helpfeels: List(String),
    lines: List(ScrapboxPageLine),
  )
}

pub type ScrapboxPageLine {
  ScrapboxPageLine(id: String, text: String)
}

fn simple_extract_text(
  input: String,
  re: regexp.Regexp,
) -> option.Option(String) {
  case regexp.scan(re, input) {
    [regexp.Match(_, [option.Some(text)])] -> option.Some(text)
    _ -> option.None
  }
}

pub fn extract_helpfeel(input) {
  let assert Ok(re) = regexp.from_string("^\\s*\\?\\s+(.*\\S)\\s*$")
  simple_extract_text(input, re)
}

pub fn extract_dollar_command(input) {
  let assert Ok(re) = regexp.from_string("^\\s*\\$\\s+(.*\\S)\\s*$")
  simple_extract_text(input, re)
}

pub fn extract_percent_command(input) {
  let assert Ok(re) = regexp.from_string("^\\s*%\\s+(.*\\S)\\s*$")
  simple_extract_text(input, re)
}

pub fn extract_external_link(input) {
  let assert Ok(re) = regexp.from_string("^.*(https?:\\/\\/.+\\S)(?:\\s+.*)?$")
  simple_extract_text(input, re)
}

pub fn extract_scrapbox_external_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[(https?:\\/\\/[^\\s]*)\\].*$")
  let assert Ok(re2) =
    regexp.from_string("^.*\\[.*\\S\\s+(https?:\\/\\/[^\\s]*)\\].*$")
  let assert Ok(re3) =
    regexp.from_string("^.*\\[(https?:\\/\\/[^\\s]*)\\s+\\S.*\\].*$")
  simple_extract_text(input, re)
  |> option.or(simple_extract_text(input, re2))
  |> option.or(simple_extract_text(input, re3))
}

pub fn extract_external_scrapbox_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[(\\/.+)\\].*$")
  simple_extract_text(input, re)
}

pub fn extract_internal_scrapbox_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[([^\\/].+)\\].*$")
  simple_extract_text(input, re)
}
