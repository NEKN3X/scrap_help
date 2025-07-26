import core/helpfeel_parser.{expand}
import gleeunit/should

pub fn parser_test() {
  expand("test")
  |> should.be_ok
  expand("(scrapbox|cosense)")
  |> should.be_ok
  expand("(scrapbox|cosense)abc")
  |> should.be_ok
  expand("((scrapbox|cosense))")
  |> should.equal(Ok(["scrapbox", "cosense"]))
  expand("((scrapbox|cosense)abc|xyz)")
  |> should.equal(Ok(["scrapboxabc", "cosenseabc", "xyz"]))
  expand("((scrapbox|cosense)(abc|xyz))")
  |> should.equal(
    Ok(["scrapboxabc", "scrapboxxyz", "cosenseabc", "cosensexyz"]),
  )
  expand("(a(|1|2|)|x)(y|z|)")
  |> should.equal(
    Ok([
      "ay", "az", "a", "a1y", "a1z", "a1", "a2y", "a2z", "a2", "ay", "az", "a",
      "xy", "xz", "x",
    ]),
  )
}
