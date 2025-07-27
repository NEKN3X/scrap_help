import core/scrapbox
import gateway/api
import gateway/db
import gateway/ffi/date
import gleam/javascript/promise
import gleam/list
import gleam/option
import gleam/result

pub fn get_projects(projects: List(String), sid) {
  let db = result.unwrap(db.read(), db.default())
  db.read_cache(db, date.now(), 1000 * 60)
  |> option.map(fn(cache) { promise.resolve(cache.projects) })
  |> option.unwrap({
    list.map(projects, fn(project) {
      use titles <- promise.try_await(api.fetch_titles(project, sid))
      let project_cache =
        list.find(db.projects, fn(p) { p.name == project })
        |> result.unwrap(scrapbox.ScrapboxProject(project, []))
      list.map(titles, fn(title) {
        let page_cache =
          project_cache.pages |> list.find(fn(p) { p.title == title.title })
        case page_cache {
          Ok(page) if page.updated == title.updated -> promise.resolve(Ok(page))
          Ok(cache) -> {
            use fetched <- promise.map(api.fetch_page(project, title.title, sid))
            result.or(fetched, Ok(cache))
          }
          _ -> api.fetch_page(project, title.title, sid)
        }
      })
      |> promise.await_list
      |> promise.map(result.values)
      |> promise.map(Ok)
      |> promise.map_try(fn(pages) {
        Ok(scrapbox.ScrapboxProject(name: project, pages: pages))
      })
    })
    |> promise.await_list
    |> promise.map(result.values)
  })
}
