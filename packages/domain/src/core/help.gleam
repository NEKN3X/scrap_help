pub type Help {
  ScrapTextHelp(project: String, page: String, command: String, text: String)
  ScrapUrlHelp(project: String, page: String, command: String, url: String)
  ScrapUrlHelpWithTitle(
    project: String,
    page: String,
    command: String,
    url: String,
    title: String,
  )
}
