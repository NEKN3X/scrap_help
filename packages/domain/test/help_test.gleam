import core/help
import gleam/option
import gleeunit/should

pub fn extract_help_with_content_test() {
  let project_name = "test_project"
  let page_name = "test_page"

  help.extract_help_with_content(project_name, page_name, [
    "? command", "$ content",
  ])
  |> should.equal([
    help.TextHelp(
      project: project_name,
      page: page_name,
      command: "command",
      text: "content",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "% https://example.com",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://example.com",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "https://example.com",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://example.com",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "[https://example.com link text]",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://example.com",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "[/project/page title]",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://scrapbox.io" <> "/project/page title",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "[/project name]",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://scrapbox.io" <> "/project name",
    ),
  ])

  help.extract_help_with_content(project_name, page_name, [
    "? command", "[page link]",
  ])
  |> should.equal([
    help.UrlHelp(
      project: project_name,
      page: page_name,
      command: "command",
      url: "https://scrapbox.io/" <> project_name <> "/page link",
    ),
  ])
}

pub fn extract_bookmark_test() {
  help.extract_bookmark("foo [# bookmark text] bar")
  |> should.be_some
  help.extract_bookmark("foo [#bookmark text] bar")
  |> should.be_none
}

pub fn extract_bookmark_help_test() {
  let project_name = "test_project"
  let page_name = "test_page"

  help.extract_bookmark_help(
    project_name,
    page_name,
    "foo [# [https://example.com]] bar",
  )
  |> should.equal(
    option.Some(help.BookmarkHelp(
      project: project_name,
      page: page_name,
      command: "https://example.com",
      url: "https://example.com",
    )),
  )

  help.extract_bookmark_help(
    project_name,
    page_name,
    "foo [# [https://example.com some text]] bar",
  )
  |> should.equal(
    option.Some(help.BookmarkHelp(
      project: project_name,
      page: page_name,
      command: "some text",
      url: "https://example.com",
    )),
  )

  help.extract_bookmark_help(
    project_name,
    page_name,
    "foo [# [/project/page title]] bar",
  )
  |> should.equal(
    option.Some(help.BookmarkHelp(
      project: project_name,
      page: page_name,
      command: "/project/page title",
      url: "https://scrapbox.io/project/page title",
    )),
  )

  help.extract_bookmark_help(project_name, page_name, "foo [# [page link]] bar")
  |> should.equal(
    option.Some(help.BookmarkHelp(
      project: project_name,
      page: page_name,
      command: project_name <> "/page link",
      url: "https://scrapbox.io/" <> project_name <> "/page link",
    )),
  )

  help.extract_bookmark_help(
    project_name,
    page_name,
    "foo [#bookmark text] bar",
  )
  |> should.be_none
}
