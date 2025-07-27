import core/scrapbox
import gleam/option
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

pub fn extract_link_test() {
  scrapbox.extract_url(" http://example.com")
  |> should.be_some
  scrapbox.extract_url("a http://example.com ")
  |> should.be_some
  scrapbox.extract_url("ahttp://example.com")
  |> should.be_some
  scrapbox.extract_url("no link here")
  |> should.be_none
}

pub fn extract_external_link_test() {
  scrapbox.extract_external_link(" [http://example.com]")
  |> should.be_some
  scrapbox.extract_external_link("no link here")
  |> should.be_none
}

pub fn extract_external_link_with_title_test() {
  scrapbox.extract_external_link_with_title(" [http://example.com some text]")
  |> should.equal(option.Some(#("some text", "http://example.com")))
  scrapbox.extract_external_link_with_title(" [some text http://example.com]")
  |> should.equal(option.Some(#("some text", "http://example.com")))
  scrapbox.extract_external_link_with_title(" [http://example.com]")
  |> should.be_none
}

pub fn extract_external_page_link_test() {
  scrapbox.extract_external_page_link(" [/project/page]")
  |> should.be_some
  scrapbox.extract_external_page_link(" [/project/page some text]")
  |> should.be_some
  scrapbox.extract_external_page_link(" [project/page some text]")
  |> should.be_none
  scrapbox.extract_external_page_link(" [some text /project/page]")
  |> should.be_none
  scrapbox.extract_external_page_link("no link here")
  |> should.be_none
}

pub fn extract_internal_scrapbox_link_test() {
  scrapbox.extract_internal_page_link(" [page title]")
  |> should.be_some
  scrapbox.extract_internal_page_link(" [page title some text]")
  |> should.be_some
  scrapbox.extract_internal_page_link(" [some text page title]")
  |> should.be_some
  scrapbox.extract_internal_page_link(" [/some text page title]")
  |> should.be_none
  scrapbox.extract_internal_page_link("no link here")
  |> should.be_none
}
