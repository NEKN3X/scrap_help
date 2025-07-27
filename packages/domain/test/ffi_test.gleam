import gateway/ffi/uri
import gleeunit/should

pub fn encode_uri_component_test() {
  "Hello, World!"
  |> uri.encode_uri_component
  |> should.equal("Hello%2C%20World!")
}

pub fn decode_uri_component_test() {
  "Hello%2C%20World!"
  |> uri.decode_uri_component
  |> should.equal("Hello, World!")
}
