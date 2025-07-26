import gleam/dynamic/decode.{bool, field, list, string, success}

pub type Query {
  Query(
    raw_query: String,
    is_re_query: Bool,
    is_home_query: Bool,
    search: String,
    search_terms: List(String),
    action_keyword: String,
  )
}

pub fn decode(data) {
  let decoder = {
    use raw_query <- field("rawQuery", string)
    use is_re_query <- field("isReQuery", bool)
    use is_home_query <- field("isHomeQuery", bool)
    use search <- field("search", string)
    use search_terms <- field("searchTerms", list(string))
    use action_keyword <- field("actionKeyword", string)
    success(Query(
      raw_query,
      is_re_query,
      is_home_query,
      search,
      search_terms,
      action_keyword,
    ))
  }
  decode.run(data, decoder)
}
