import gleam/list
import gleam/option.{None, Some}
import monadic_parser/char.{type Char}
import monadic_parser/parser.{type Parser, alt, bind, parse, pure}

fn letter() -> Parser(Char) {
  parser.sat(fn(x) {
    case x |> char.to_string {
      "(" -> False
      ")" -> False
      "|" -> False
      _ -> True
    }
  })
}

fn some_str() -> Parser(List(String)) {
  use s <- bind(parser.some(letter()))
  pure([s |> char.join])
}

fn product(xs: List(a), ys: List(b)) -> List(#(a, b)) {
  xs |> list.flat_map(fn(x) { ys |> list.map(fn(y) { #(x, y) }) })
}

fn concat_pair(p: #(String, String)) -> String {
  let #(x, y) = p
  x <> y
}

/// literal := factor (*literal | ε)
pub fn literal() -> Parser(List(String)) {
  use fac <- bind(factor())
  {
    use lit <- bind(literal())
    pure(product(fac, lit) |> list.map(concat_pair))
  }
  |> alt(pure(fac))
}

/// synonym := (literal | 空文字) (+"|"synonym | ε)
pub fn synonym() -> Parser(List(String)) {
  use lit <- bind(literal() |> alt(pure([""])))
  {
    use _ <- bind(parser.string("|"))
    use syn <- bind(synonym())
    pure(list.append(lit, syn))
  }
  |> alt(pure(lit))
}

/// factor := "("synonym")" | some_str
pub fn factor() -> Parser(List(String)) {
  {
    use _ <- bind(parser.string("("))
    use syn <- bind(synonym())
    use _ <- bind(parser.string(")"))
    pure(syn)
  }
  |> alt(some_str())
}

pub type HelpfeelParserError {
  UnusedInput(String)
  InvalidInput(String)
}

pub fn expand(xs: String) -> Result(List(String), HelpfeelParserError) {
  case parse(literal(), xs) {
    Some(#(n, "")) -> Ok(n)
    Some(#(_, out)) -> Error(UnusedInput(out))
    None -> Error(InvalidInput(xs))
  }
}
