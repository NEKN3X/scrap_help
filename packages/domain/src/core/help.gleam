import core/helpfeel
import core/scrapbox
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result

pub type Help {
  ScrapTextHelp(project: String, page: String, command: String, content: String)
  ScrapUrlHelp(project: String, page: String, command: String, content: String)
  ScrapUrlHelpWithTitle(
    project: String,
    page: String,
    command: String,
    content: String,
    title: String,
  )
}

fn scan_text_help(text) {
  let assert Ok(re) = regexp.from_string("^\\s*\\$\\s+(\\S.*\\S)\\s*$")
  case regexp.scan(re, text) {
    [regexp.Match(_, [option.Some(help_text)])] -> Ok(help_text)
    _ -> Error(Nil)
  }
}

fn scan_url_help(text) {
  let assert Ok(re) = regexp.from_string("^\\s*%\\s+(\\S.*\\S)\\s*$")
  let assert Ok(re2) =
    regexp.from_string("^\\s*\\[(http.*\\S)\\s+(\\S.*)\\]\\s*$")
  let assert Ok(re3) =
    regexp.from_string("^\\s*\\[(.*\\S)\\s+(http.*\\S)\\]\\s*$")
  use _ <- result.try_recover({
    case regexp.scan(re, text) {
      [regexp.Match(_, [option.Some(url)])] -> Ok(#(url, option.None))
      _ -> Error(Nil)
    }
  })
  use _ <- result.try_recover({
    case regexp.scan(re2, text) {
      [regexp.Match(_, [option.Some(url), option.Some(title)])] ->
        Ok(#(url, option.Some(title)))
      _ -> Error(Nil)
    }
  })
  use _ <- result.try_recover({
    case regexp.scan(re3, text) {
      [regexp.Match(_, [option.Some(title), option.Some(url)])] ->
        Ok(#(url, option.Some(title)))
      _ -> Error(Nil)
    }
  })
  Error(Nil)
}

pub fn extract(project: scrapbox.ScrapboxProject) {
  project.pages
  |> list.map(fn(page) {
    page.lines
    |> list.window_by_2
    |> list.filter_map(fn(pair) {
      case helpfeel.scan_helpfeel({ pair.0 }.text) {
        Error(_) -> {
          let assert Ok(re) =
            regexp.from_string("^\\s*\\[#\\s+\\[(.*)\\s+(http.*)\\]\\].*$")
          use _ <- result.try_recover({
            case regexp.scan(re, { pair.1 }.text) {
              [regexp.Match(_, [option.Some(title), option.Some(url)])] ->
                Ok(#(title, url))
              _ -> Error(Nil)
            }
            |> result.map(fn(pair) {
              ScrapUrlHelpWithTitle(
                project.name,
                page.title,
                { pair.0 },
                pair.0,
                pair.1,
              )
            })
          })
          Error(Nil)
        }
        Ok(command) -> {
          scan_text_help({ pair.1 }.text)
          |> result.map(fn(text) {
            ScrapTextHelp(project.name, page.title, command, text)
          })
          |> result.try_recover(fn(_) {
            scan_url_help({ pair.1 }.text)
            |> result.map(fn(url) {
              case url {
                #(url, option.None) ->
                  ScrapUrlHelp(project.name, page.title, command, url)
                #(url, option.Some(title)) ->
                  ScrapUrlHelpWithTitle(
                    project.name,
                    page.title,
                    command,
                    url,
                    title,
                  )
              }
            })
          })
        }
      }
    })
  })
  |> list.flatten
}

pub fn set_command(help: Help, command: String) {
  case help {
    ScrapTextHelp(project, page, _, text) ->
      ScrapTextHelp(project, page, command, text)
    ScrapUrlHelp(project, page, _, url) ->
      ScrapUrlHelp(project, page, command, url)
    ScrapUrlHelpWithTitle(project, page, _, url, title) ->
      ScrapUrlHelpWithTitle(project, page, command, url, title)
  }
}

pub fn set_content(help: Help, content: String) {
  case help {
    ScrapTextHelp(project, page, command, _) ->
      ScrapTextHelp(project, page, command, content)
    ScrapUrlHelp(project, page, command, _) ->
      ScrapUrlHelp(project, page, command, content)
    ScrapUrlHelpWithTitle(project, page, command, _, title) ->
      ScrapUrlHelpWithTitle(project, page, command, content, title)
  }
}
