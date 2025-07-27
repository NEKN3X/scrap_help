import core/scrapbox
import gateway/dto/scrapbox_project
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import simplifile

const filepath = "./db.json"

pub type DBError {
  FailedToReadFile
  FailedToWriteFile
  FailedToDecodeJson
}

pub type Schema {
  Schema(projects: List(scrapbox.ScrapboxProject), timestamp: Int)
}

pub fn default() {
  Schema([], 0)
}

pub fn read() {
  simplifile.read(filepath)
  |> result.replace_error(FailedToReadFile)
  |> result.try(fn(content) {
    json.parse(content, decoder()) |> result.replace_error(FailedToDecodeJson)
  })
}

pub fn read_cache(schema: Schema, timestamp, timeout) {
  case schema.timestamp {
    t if timestamp - t < timeout -> option.Some(schema)
    _ -> option.None
  }
}

pub fn write(data: Schema) {
  let json = to_json(data)
  simplifile.write(filepath, json.to_string(json))
  |> result.replace_error(FailedToWriteFile)
}

fn decoder() {
  use projects <- decode.field(
    "projects",
    decode.list(scrapbox_project.decoder()),
  )
  use timestamp <- decode.field("timestamp", decode.int)
  decode.success(Schema(projects, timestamp))
}

fn to_json(schema: Schema) {
  json.object([
    #(
      "projects",
      json.preprocessed_array(list.map(
        schema.projects,
        scrapbox_project.to_json,
      )),
    ),
    #("timestamp", json.int(schema.timestamp)),
  ])
}
