import gateway
import gleam/javascript/promise
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

pub fn get_projects_test() {
  let projects = ["custom"]
  let sid = option.None

  use projects <- promise.tap(gateway.get_projects(projects, sid))
  let assert Ok(project) = list.first(projects)
  project.pages
  |> list.length
  |> should.not_equal(0)
}
