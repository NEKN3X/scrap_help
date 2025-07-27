// import gateway/get_projects
// import gleam/javascript/promise
// import gleam/list
// import gleam/option
// import gleeunit/should
// import workflow/get_all_helps

// pub fn get_all_helps_test() {
//   let project_name = "custom"

//   let get_projects = get_projects.get_projects(_, option.None)

//   get_all_helps.workflow(get_projects).run([project_name])
//   |> promise.tap(fn(result) {
//     list.length(result)
//     |> should.not_equal(0)
//   })
// }
