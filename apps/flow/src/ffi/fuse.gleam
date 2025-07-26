import gleam/javascript/array
import gleam/json

pub type FuseOptions {
  FuseOptions(keys: List(String))
}

pub type FuseResult(a) {
  FuseResult(item: a)
}

@external(javascript, "./dist/fuse_ffi.js", "search")
fn search_js(
  items: array.Array(a),
  query: String,
  options: json.Json,
) -> array.Array(FuseResult(a))

pub fn search(
  items: List(a),
  query: String,
  options: FuseOptions,
) -> List(FuseResult(a)) {
  let options = json.object([#("keys", json.array(options.keys, json.string))])
  search_js(items |> array.from_list, query, options) |> array.to_list
}
