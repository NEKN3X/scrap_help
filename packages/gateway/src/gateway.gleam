import core
import db
import ffi/date
import gleam/javascript/promise
import gleam/list
import gleam/result
import scrapbox_api

const timeout = 60_000

fn cache(db: db.Schema) {
  case date.now() - db.timestamp {
    n if n < timeout -> Ok(db)
    _ -> Error("Cache expired")
  }
}

pub fn get_projects(projects, sid) {
  let db = case db.read() {
    Ok(Ok(db)) -> db
    _ -> db.default()
  }
  case cache(db) {
    Ok(cache) -> promise.resolve(cache.projects)
    _ -> {
      projects
      |> list.map(fn(project) {
        use titles <- promise.try_await(scrapbox_api.fetch_titles(project, sid))
        let project_cache =
          db.projects
          |> list.find(fn(p) { p.name == project })
          |> result.unwrap(core.ScrapboxProject(project, []))
        titles
        |> list.map(fn(title) {
          let page_cache =
            project_cache.pages
            |> list.find(fn(p) { p.title == title.title })
          case page_cache {
            Ok(page) if page.updated <= title.updated ->
              promise.resolve(Ok(page))
            _ -> scrapbox_api.fetch_page(project, title.title, sid)
          }
        })
        |> promise.await_list
        |> promise.map(result.values)
        |> promise.map(fn(pages) { Ok(core.ScrapboxProject(project, pages)) })
      })
      |> promise.await_list
      |> promise.map(result.values)
      |> promise.tap(fn(projects) { db.write(db.Schema(projects, date.now())) })
    }
  }
}
