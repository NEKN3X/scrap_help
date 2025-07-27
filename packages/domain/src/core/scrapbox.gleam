import gleam/option
import gleam/pair
import gleam/regexp
import gleam/string

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

pub fn simple_extract_text(
  input: String,
  re: regexp.Regexp,
) -> option.Option(String) {
  case regexp.scan(re, input) {
    [regexp.Match(_, [option.Some(text)])] -> option.Some(text)
    _ -> option.None
  }
}

pub fn simple_extract_text2(
  input: String,
  re: regexp.Regexp,
) -> option.Option(#(String, String)) {
  case regexp.scan(re, input) {
    [regexp.Match(_, [option.Some(first), option.Some(second)])] ->
      option.Some(#(first, second))
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

pub fn extract_url(input) {
  let assert Ok(re) = regexp.from_string("^.*(https?:\\/\\/.+\\S)(?:\\s+.*)?$")
  simple_extract_text(input, re)
}

pub fn extract_external_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[(https?:\\/\\/[^\\s]*)\\].*$")
  simple_extract_text(input, re)
}

pub fn extract_external_link_with_title(input) {
  let assert Ok(re) =
    regexp.from_string("^.*\\[(.*\\S)\\s+(https?:\\/\\/[^\\s]*)\\].*$")
  let assert Ok(re2) =
    regexp.from_string("^.*\\[(https?:\\/\\/[^\\s]*)\\s+(\\S.*)\\].*$")
  simple_extract_text2(input, re)
  |> option.or(simple_extract_text2(input, re2) |> option.map(pair.swap))
}

pub fn extract_external_page_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[(\\/.+)\\].*$")
  simple_extract_text(input, re)
}

pub fn extract_internal_page_link(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[([^\\/].+)\\].*$")
  simple_extract_text(input, re)
}

pub fn scrapbox_url(project: String, page: option.Option(String)) {
  case page {
    option.Some(p) -> "https://scrapbox.io/" <> project <> "/" <> p
    option.None -> "https://scrapbox.io/" <> project
  }
}

pub fn scrapbox_url_with_path(path) {
  "https://scrapbox.io" <> path
}

pub fn is_scrapbox_url(url: String) {
  string.starts_with(url, "https://scrapbox.io/")
}
