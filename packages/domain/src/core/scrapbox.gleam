pub type ScrapboxTitle {
  ScrapboxTitle(id: String, title: String, updated: Int)
}

pub type ScrapboxProject {
  ScrapboxProject(name: String, pages: List(ScrapboxPage))
}

pub type ScrapboxPage {
  ScrapboxPage(
    id: String,
    title: String,
    created: Int,
    updated: Int,
    helpfeels: List(String),
    lines: List(ScrapboxPageLine),
  )
}

pub type ScrapboxPageLine {
  ScrapboxPageLine(id: String, text: String)
}
