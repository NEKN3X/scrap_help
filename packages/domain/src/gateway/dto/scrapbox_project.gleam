import core/scrapbox
import gateway/dto/scrapbox_page
import gleam/dynamic/decode
import gleam/json

pub fn decoder() {
  use name <- decode.field("name", decode.string)
  use pages <- decode.field("pages", decode.list(scrapbox_page.decoder()))
  decode.success(scrapbox.ScrapboxProject(name, pages))
}

pub fn to_json(project: scrapbox.ScrapboxProject) {
  json.object([
    #("name", json.string(project.name)),
    #("pages", json.array(project.pages, scrapbox_page.to_json)),
  ])
}
