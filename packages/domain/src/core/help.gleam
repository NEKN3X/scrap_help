pub type Help {
  TextHelp(project: String, page: String, command: String, text: String)
  UrlHelp(project: String, page: String, command: String, url: String)
  ScrapLink(project: String, page: String, command: String, path: String)
  ScrapPage(project: String, page: String)
}
