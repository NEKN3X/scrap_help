import core/help
import core/scrapbox
import gleam/dict

pub type Glossary {
  Glossary(dict.Dict(String, String))
}

pub type GetAllHelp {
  GetAllHelp(
    run: fn(List(scrapbox.ScrapboxProject), Glossary) -> List(help.Help),
  )
}
