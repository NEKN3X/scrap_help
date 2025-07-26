import core/help
import core/helpfeel_parser
import core/scrapbox
import gleam/dict
import gleam/list
import gleam/string
import public_types

type ProjectWithGlossaryAndHelps {
  ProjectWithGlossaryAndHelps(
    project: scrapbox.ScrapboxProject,
    helps: List(help.Help),
  )
}

fn extract_helps(project: scrapbox.ScrapboxProject) {
  let helps = help.extract(project)
  ProjectWithGlossaryAndHelps(project, helps)
}

type ProjectWithHelps {
  ProjectWithHelps(project: scrapbox.ScrapboxProject, helps: List(help.Help))
}

pub fn replace_glossary(glossary: public_types.Glossary, text: String) {
  let replace = fn(pair, text) {
    let #(key, value) = pair
    string.replace(text, "{" <> key <> "}", value)
  }

  case glossary {
    public_types.Glossary(dict) ->
      dict
      |> dict.to_list
      |> list.fold(text, fn(acc, pair) { replace(pair, acc) })
  }
}

fn expand_glossary(project: ProjectWithGlossaryAndHelps, glossary) {
  let helps =
    project.helps
    |> list.map(fn(help) {
      let replaced = replace_glossary(glossary, help.command)
      help.set_command(help, replaced)
    })
  ProjectWithHelps(project.project, helps)
}

pub fn workflow() {
  public_types.GetAllHelp(fn(projects, glossary) {
    projects
    |> list.map(extract_helps)
    |> list.map(expand_glossary(_, glossary))
    |> list.map(fn(x) { x.helps })
    |> list.flatten
    |> list.flat_map(fn(help) {
      case helpfeel_parser.expand(help.command) {
        Ok(expanded) -> list.map(expanded, help.set_command(help, _))
        _ -> [help]
      }
    })
  })
}
