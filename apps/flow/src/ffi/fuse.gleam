import gleam/javascript/array

type FuseOptionsJs {
  FuseOptionsJs(keys: array.Array(String))
}

pub type FuseOptions {
  FuseOptions(keys: List(String))
}

@external(javascript, "./dist/fuse_ffi.js", "search")
fn search_js(
  items: array.Array(a),
  query: String,
  options: FuseOptionsJs,
) -> array.Array(a)

pub fn search(items: List(a), query: String, options: FuseOptions) -> List(a) {
  let options = FuseOptionsJs(options.keys |> array.from_list)
  search_js(items |> array.from_list, query, options) |> array.to_list
}
