@external(javascript, "./uri_ffi.mjs", "encode")
pub fn encode_uri_component(text: String) -> String

@external(javascript, "./uri_ffi.mjs", "decode")
pub fn decode_uri_component(text: String) -> String
