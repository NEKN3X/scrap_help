import core
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import scrapbox_api
import simplifile

const filepath = "./db.json"

pub type Schema {
  Schema(projects: List(core.ScrapboxProject), timestamp: Int)
}

pub fn default() {
  Schema([], 0)
}

fn project_decoder() {
  use name <- decode.field("name", decode.string)
  use pages <- decode.field("pages", decode.list(scrapbox_api.page_decoder()))
  decode.success(core.ScrapboxProject(name, pages))
}

fn decoder() {
  use projects <- decode.field("projects", decode.list(project_decoder()))
  use timestamp <- decode.field("timestamp", decode.int)
  decode.success(Schema(projects, timestamp))
}

pub fn read() {
  simplifile.read(filepath)
  |> result.map(fn(content) { json.parse(content, decoder()) })
}

fn to_json(schema: Schema) {
  let line_to_json = fn(line: core.ScrapboxPageLine) {
    json.object([
      #("id", json.string(line.id)),
      #("text", json.string(line.text)),
    ])
  }
  let page_to_json = fn(page: core.ScrapboxPage) {
    json.object([
      #("id", json.string(page.id)),
      #("title", json.string(page.title)),
      #("created", json.int(page.created)),
      #("updated", json.int(page.updated)),
      #(
        "helpfeels",
        json.preprocessed_array(list.map(page.helpfeels, json.string)),
      ),
      #("lines", json.preprocessed_array(list.map(page.lines, line_to_json))),
    ])
  }
  let project_to_json = fn(project: core.ScrapboxProject) {
    json.object([
      #("name", json.string(project.name)),
      #("pages", json.preprocessed_array(list.map(project.pages, page_to_json))),
    ])
  }
  json.object([
    #(
      "projects",
      json.preprocessed_array(list.map(schema.projects, project_to_json)),
    ),
    #("timestamp", json.int(schema.timestamp)),
  ])
}

pub fn write(data: Schema) {
  let json = to_json(data)
  simplifile.write(filepath, json.to_string(json))
}
