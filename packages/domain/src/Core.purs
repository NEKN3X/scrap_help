module Core where

import Prelude

import Data.Array.NonEmpty.Internal (NonEmptyArray(..))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String.Regex (match, regex)
import Data.String.Regex.Flags (noFlags)

type TextHelp = {
  project::String,
  page::String,
  command::String,
  text::String
}

type UrlHelp = {
  project::String,
  page::String,
  command::String,
  url::String
}

type ScrapboxPage = {
  project::String,
  page::String
}

extractHelpFeel :: String -> Maybe String
extractHelpFeel input =
  let re = regex "^\\s*\\?\\s+(.*\\S)\\s*$" noFlags
  in case re of
    Left _ -> Nothing
    Right r ->
      case match r input of
        Nothing -> Nothing
        Just (NonEmptyArray [_, text]) -> text
        _ -> Nothing
