import core/scrapbox
import gleam/list
import gleam/option
import gleam/regexp

pub type Help {
  TextHelp(project: String, page: String, command: String, text: String)
  UrlHelp(project: String, page: String, command: String, url: String)
  BookmarkHelp(project: String, page: String, command: String, url: String)
  ScrapPage(project: String, page: String)
}

pub fn extract_help_with_content(
  project_name: String,
  page_name: String,
  lines: List(String),
) -> List(Help) {
  let pairs = list.window_by_2(lines)
  list.map(pairs, fn(pair) {
    scrapbox.extract_helpfeel(pair.0)
    |> option.then(fn(command) {
      {
        use text <- option.map(scrapbox.extract_dollar_command(pair.1))
        TextHelp(project_name, page_name, command: command, text: text)
      }
      |> option.or({
        use url <- option.map(scrapbox.extract_percent_command(pair.1))
        UrlHelp(project_name, page_name, command: command, url: url)
      })
      |> option.or({
        use url <- option.map(scrapbox.extract_external_link(pair.1))
        UrlHelp(project_name, page_name, command: command, url: url)
      })
      |> option.or({
        use #(_, url) <- option.map(scrapbox.extract_external_link_with_title(
          pair.1,
        ))
        UrlHelp(project_name, page_name, command: command, url: url)
      })
      |> option.or({
        use url <- option.map(scrapbox.extract_url(pair.1))
        UrlHelp(project_name, page_name, command: command, url: url)
      })
      |> option.or({
        use path <- option.map(scrapbox.extract_external_page_link(pair.1))
        UrlHelp(
          project_name,
          page_name,
          command: command,
          url: "https://scrapbox.io" <> path,
        )
      })
      |> option.or({
        use page <- option.map(scrapbox.extract_internal_page_link(pair.1))
        UrlHelp(
          project_name,
          page_name,
          command: command,
          url: "https://scrapbox.io/" <> project_name <> "/" <> page,
        )
      })
    })
  })
  |> option.values
}

pub fn extract_bookmark(input) {
  let assert Ok(re) = regexp.from_string("^.*\\[#\\s+(\\S.*\\S)\\].*$")
  scrapbox.simple_extract_text(input, re)
}

pub fn extract_bookmark_help(
  project_name: String,
  page_name: String,
  input: String,
) -> option.Option(Help) {
  use text <- option.then(extract_bookmark(input))
  {
    use url <- option.map(scrapbox.extract_external_link(text))
    BookmarkHelp(project: project_name, page: page_name, command: url, url: url)
  }
  |> option.or({
    use #(title, url) <- option.map(scrapbox.extract_external_link_with_title(
      text,
    ))
    BookmarkHelp(
      project: project_name,
      page: page_name,
      command: title,
      url: url,
    )
  })
  |> option.or({
    use path <- option.map(scrapbox.extract_external_page_link(text))
    BookmarkHelp(
      project: project_name,
      page: page_name,
      command: path,
      url: "https://scrapbox.io" <> path,
    )
  })
  |> option.or({
    use page <- option.map(scrapbox.extract_internal_page_link(text))
    BookmarkHelp(
      project: project_name,
      page: page_name,
      command: project_name <> "/" <> page,
      url: "https://scrapbox.io/" <> project_name <> "/" <> page,
    )
  })
}
