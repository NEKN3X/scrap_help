import core/help
import core/scrapbox
import gleam/javascript/promise
import gleam/list
import gleam/option
import workflow/public_types

fn extract_helps(project: scrapbox.ScrapboxProject) {
  list.flat_map(project.pages, fn(page) {
    let lines = list.map(page.lines, fn(line) { line.text })
    let helps = help.extract_help_with_content(project.name, page.title, lines)
    let bookmarks =
      list.map(lines, help.extract_bookmark_help(project.name, page.title, _))
      |> option.values
    help.ScrapPage(project: project.name, page: page.title)
    |> list.wrap
    |> list.append(helps)
    |> list.append(bookmarks)
  })
}

pub fn workflow(
  get_projects: fn(List(String)) ->
    promise.Promise(List(scrapbox.ScrapboxProject)),
) {
  public_types.GetAllHelps(fn(projects) {
    get_projects(projects)
    |> promise.map(list.flat_map(_, extract_helps))
  })
}
