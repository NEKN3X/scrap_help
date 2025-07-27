import core/scrapbox
import gleam/dynamic/decode
import gleam/json

pub fn lines_decoder() {
  use id <- decode.field("id", decode.string)
  use text <- decode.field("text", decode.string)
  decode.success(scrapbox.ScrapboxPageLine(id, text))
}

pub fn lines_to_json(line: scrapbox.ScrapboxPageLine) {
  json.object([#("id", json.string(line.id)), #("text", json.string(line.text))])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use created <- decode.field("created", decode.int)
  use updated <- decode.field("updated", decode.int)
  use helpfeels <- decode.field("helpfeels", decode.list(decode.string))
  use lines <- decode.field("lines", decode.list(lines_decoder()))
  decode.success(scrapbox.ScrapboxPage(
    id,
    title,
    created,
    updated,
    helpfeels,
    lines,
  ))
}

pub fn to_json(page: scrapbox.ScrapboxPage) {
  json.object([
    #("id", json.string(page.id)),
    #("title", json.string(page.title)),
    #("created", json.int(page.created)),
    #("updated", json.int(page.updated)),
    #("helpfeels", json.array(page.helpfeels, json.string)),
    #("lines", json.array(page.lines, lines_to_json)),
  ])
}
