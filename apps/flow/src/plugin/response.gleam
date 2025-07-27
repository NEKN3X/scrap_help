import gleam/dict
import gleam/function
import gleam/json.{
  type Json, array, bool, dict, int, object, preprocessed_array, string,
}
import gleam/list
import gleam/option.{None, Some}

pub type Glyph {
  Glyph(glyph: String, font_family: String)
}

pub type ParametersAllowedTypes {
  StringParam(String)
  IntParam(Int)
  BoolParam(Bool)
  RecordParam(dict.Dict(String, ParametersAllowedTypes))
  StringListParam(List(String))
  IntListParam(List(Int))
  BoolListParam(List(Bool))
  RecordListParam(List(dict.Dict(String, ParametersAllowedTypes)))
}

pub type Parameters =
  List(ParametersAllowedTypes)

pub type JSONRPCAction {
  JSONRPCAction(method: String, parameters: Parameters)
}

pub type JSONRPCResponse {
  JSONRPCResponse(
    title: String,
    sub_title: String,
    auto_complete_text: option.Option(String),
    title_highlight_data: option.Option(List(Int)),
    glyph: option.Option(Glyph),
    ico_path: option.Option(String),
    json_rpc_action: JSONRPCAction,
    context_data: option.Option(List(JSONRPCResponse)),
    score: option.Option(Int),
  )
}

fn param_to_json(param) {
  case param {
    StringParam(s) -> string(s)
    IntParam(n) -> int(n)
    BoolParam(b) -> bool(b)
    RecordParam(r) -> dict(r, function.identity, param_to_json)
    StringListParam(l) -> array(l, string)
    IntListParam(l) -> array(l, int)
    BoolListParam(l) -> array(l, bool)
    RecordListParam(l) ->
      array(l, fn(record) { dict(record, function.identity, param_to_json) })
  }
}

pub fn to_json(data: List(JSONRPCResponse)) -> List(Json) {
  use item <- list.map(data)
  let glyph = case item.glyph {
    Some(g) ->
      Some([#("glyph", string(g.glyph)), #("fontFamily", string(g.font_family))])
    None -> None
  }
  let parameters =
    preprocessed_array(list.map(item.json_rpc_action.parameters, param_to_json))
  let action =
    object([
      #("method", string(item.json_rpc_action.method)),
      #("parameters", parameters),
    ])
  let context_data = case item.context_data {
    Some(cd) ->
      Some(#(
        "contextData",
        json.object([#("result", preprocessed_array(to_json(cd)))]),
      ))
    None -> None
  }
  object(
    [
      #("title", string(item.title)),
      #("subTitle", string(item.sub_title)),
      #("jsonRPCAction", action),
    ]
    |> list.append(
      [
        glyph |> option.map(fn(x) { #("glyph", object(x)) }),
        item.auto_complete_text
          |> option.map(fn(x) { #("autoCompleteText", string(x)) }),
        item.title_highlight_data
          |> option.map(fn(x) { #("titleHighlightData", array(x, int)) }),
        item.ico_path |> option.map(fn(x) { #("icoPath", string(x)) }),
        item.score |> option.map(fn(x) { #("score", int(x)) }),
        context_data,
      ]
      |> list.filter_map(fn(x) {
        case x {
          Some(value) -> Ok(value)
          None -> Error("No value")
        }
      }),
    ),
  )
}
