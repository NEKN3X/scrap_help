import gleam/option
import gleam/regexp

pub fn scan_helpfeel(text) {
  let assert Ok(re) = regexp.from_string("^\\s*\\?\\s+(\\S.*\\S)\\s*$")
  case regexp.scan(re, text) {
    [regexp.Match(_, [option.Some(helpfeel)])] -> Ok(helpfeel)
    _ -> Error(Nil)
  }
}
