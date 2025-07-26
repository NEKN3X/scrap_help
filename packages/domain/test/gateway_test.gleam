// import gateway/gateway
// import gleam/javascript/promise
// import gleam/list
// import gleam/option

// pub fn gateway_test() {
//   let projects = ["custom"]
//   use result <- promise.tap(gateway.get_projects(projects, option.None))
//   let assert Ok(project) = result |> list.first
//   assert project.pages |> list.length > 0
// }
