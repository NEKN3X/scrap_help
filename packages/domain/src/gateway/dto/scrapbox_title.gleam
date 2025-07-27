import core/scrapbox
import gleam/dynamic/decode
import gleam/json

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use updated <- decode.field("updated", decode.int)
  decode.success(scrapbox.ScrapboxTitle(id, title, updated))
}

pub fn to_json(title: scrapbox.ScrapboxTitle) {
  json.object([
    #("id", json.string(title.id)),
    #("title", json.string(title.title)),
    #("updated", json.int(title.updated)),
  ])
}
