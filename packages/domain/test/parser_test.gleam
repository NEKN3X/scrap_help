import core/parser
import gleam/list
import gleam/result
import gleeunit/should

pub fn parser_test() {
  parser.expand("a | b | c")
  |> should.be_error
  parser.expand("(a|b|c")
  |> should.be_error
  parser.expand("(a|b)")
  |> should.equal(Ok(["a", "b"]))
  parser.expand("((a|b) | c)")
  |> should.equal(Ok(["a ", "b ", " c"]))
  parser.expand("1(2(a|b|c)(x|y)z)3")
  |> result.map(list.length)
  |> should.equal(Ok(6))
  parser.expand("(|||a)b")
  |> should.equal(Ok(["b", "b", "b", "ab"]))
  parser.expand("(((a|b|)x)|(y|z))")
  |> should.equal(Ok(["ax", "bx", "x", "y", "z"]))
}
