import core/scrapbox
import gleeunit/should

pub fn extract_helpfeel_test() {
  scrapbox.extract_helpfeel(" ? some help text")
  |> should.be_some
  scrapbox.extract_helpfeel(" ?")
  |> should.be_none
  scrapbox.extract_helpfeel("a ? some help text")
  |> should.be_none
}

pub fn extract_dollar_command_test() {
  scrapbox.extract_dollar_command(" $ some command")
  |> should.be_some
  scrapbox.extract_dollar_command(" $")
  |> should.be_none
  scrapbox.extract_dollar_command("a $ some command")
  |> should.be_none
}

pub fn extract_percent_command_test() {
  scrapbox.extract_percent_command(" % some command")
  |> should.be_some
  scrapbox.extract_percent_command(" %")
  |> should.be_none
  scrapbox.extract_percent_command("a % some command")
  |> should.be_none
}

pub fn extract_external_link_test() {
  scrapbox.extract_external_link(" http://example.com")
  |> should.be_some
  scrapbox.extract_external_link("a http://example.com ")
  |> should.be_some
  scrapbox.extract_external_link("ahttp://example.com")
  |> should.be_some
  scrapbox.extract_external_link("no link here")
  |> should.be_none
}

pub fn extract_scrapbox_external_link_test() {
  scrapbox.extract_scrapbox_external_link(" [http://example.com]")
  |> should.be_some
  scrapbox.extract_scrapbox_external_link(" [http://example.com some text]")
  |> should.be_some
  scrapbox.extract_scrapbox_external_link(" [some text http://example.com]")
  |> should.be_some
  scrapbox.extract_scrapbox_external_link("no link here")
  |> should.be_none
}

pub fn extract_external_scrapbox_link_test() {
  scrapbox.extract_external_scrapbox_link(" [/project/page]")
  |> should.be_some
  scrapbox.extract_external_scrapbox_link(" [/project/page some text]")
  |> should.be_some
  scrapbox.extract_external_scrapbox_link(" [project/page some text]")
  |> should.be_none
  scrapbox.extract_external_scrapbox_link(" [some text /project/page]")
  |> should.be_none
  scrapbox.extract_external_scrapbox_link("no link here")
  |> should.be_none
}

pub fn extract_internal_scrapbox_link_test() {
  scrapbox.extract_internal_scrapbox_link(" [page title]")
  |> should.be_some
  scrapbox.extract_internal_scrapbox_link(" [page title some text]")
  |> should.be_some
  scrapbox.extract_internal_scrapbox_link(" [some text page title]")
  |> should.be_some
  scrapbox.extract_internal_scrapbox_link(" [/some text page title]")
  |> should.be_none
  scrapbox.extract_internal_scrapbox_link("no link here")
  |> should.be_none
}
