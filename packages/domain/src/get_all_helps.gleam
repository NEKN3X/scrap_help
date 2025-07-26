import core/help
import core/helpfeel_parser
import core/scrapbox
import gleam/dict
import gleam/list
import gleam/regexp
import gleam/result
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

fn replace_glossary(glossary: public_types.Glossary, text: String) {
  let result = case glossary {
    public_types.Glossary(dict) ->
      dict
      |> dict.fold(text, fn(acc, key, value) {
        string.replace(acc, "{" <> key <> "}", value)
      })
  }
  let assert Ok(re) = regexp.from_string("\\{(.*)\\}")
  case regexp.check(re, result) {
    True -> Error(Nil)
    _ -> Ok(result)
  }
}

fn expand_glossary(project: ProjectWithGlossaryAndHelps, glossary) {
  let helps = {
    use help <- list.map(project.helps)
    use replaced_command <- result.try(replace_glossary(glossary, help.command))
    use replaced_content <- result.try(replace_glossary(glossary, help.content))
    help
    |> help.set_command(replaced_command)
    |> help.set_content(replaced_content)
    |> Ok
  }
  ProjectWithHelps(project.project, helps |> result.values)
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
