// import core/scrapbox
// import gateway/db
// import gleeunit/should

// pub fn db_test() {
//   let page =
//     scrapbox.ScrapboxPage(
//       id: "1",
//       title: "Test Page",
//       created: 0,
//       updated: 0,
//       helpfeels: ["foo", "bar"],
//       lines: [
//         scrapbox.ScrapboxPageLine(id: "1", text: "First line"),
//         scrapbox.ScrapboxPageLine(id: "2", text: "Second line"),
//       ],
//     )
//   let projects = [
//     scrapbox.ScrapboxProject("test_project", [page, page]),
//     scrapbox.ScrapboxProject("another_project", [page, page]),
//   ]
//   let _ = db.write(db.Schema(projects: projects, timestamp: 0))
//   db.read()
//   |> should.be_ok
// }
