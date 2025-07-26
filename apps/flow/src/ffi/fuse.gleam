import gleam/int
import gleam/javascript/array
import gleam/json
import gleam/list

pub type FuseOptions {
  FuseOptions(keys: List(String))
}

pub type FuseMatchJs {
  FuseMatchJs(
    indices: array.Array(array.Array(Int)),
    value: String,
    key: String,
  )
}

pub type FuseMatch {
  FuseMatch(indices: List(List(Int)), value: String, key: String)
}

pub type FuseResultJs(a) {
  FuseResultJs(item: a, matches: array.Array(FuseMatchJs), score: Float)
}

pub type FuseResult(a) {
  FuseResult(item: a, matches: List(FuseMatch), score: Float)
}

@external(javascript, "./dist/fuse_ffi.js", "search")
fn search_js(
  items: array.Array(a),
  query: String,
  options: json.Json,
) -> array.Array(FuseResultJs(a))

pub fn search(
  items: List(a),
  query: String,
  options: FuseOptions,
) -> List(FuseResult(a)) {
  let options = json.object([#("keys", json.array(options.keys, json.string))])
  search_js(items |> array.from_list, query, options)
  |> array.to_list
  |> list.map(fn(r) {
    let matches =
      r.matches
      |> array.to_list
      |> list.map(fn(m) {
        FuseMatch(
          m.indices |> array.to_list |> list.map(fn(i) { i |> array.to_list }),
          m.value,
          m.key,
        )
      })
    FuseResult(r.item, matches, r.score)
  })
}
