module Test.Core where

import Prelude

import Core (extractHelpFeel)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert (equal)
import Test.Unit.Main (runTest)

core :: Effect Unit
core = runTest do
  suite "extractHelpFeel" do
    test "正しいHelpfeel記法なら文字列を返す" do
      equal (Just "これはヘルプのテキスト") (extractHelpFeel "? これはヘルプのテキスト  ")
      equal (Just "これはヘルプのテキスト") (extractHelpFeel "?    これはヘルプのテキスト  ")
      equal (Just "これはヘルプのテキスト") (extractHelpFeel "  ? これはヘルプのテキスト")
      equal (Just "これは ヘルプ？ の テキスト") (extractHelpFeel "  ? これは ヘルプ？ の テキスト")
      equal (Just "(これは|あれは)ヘルプ？ のテキスト") (extractHelpFeel "  ? (これは|あれは)ヘルプ？ のテキスト")
    test "Helpfeel記法でない場合はNothingを返す" do
      equal Nothing (extractHelpFeel "これはヘルプのテキスト")
      equal Nothing (extractHelpFeel "?これはヘルプのテキスト")
      equal Nothing (extractHelpFeel "  ?  ")
      equal Nothing (extractHelpFeel "?  ")
      equal Nothing (extractHelpFeel "  ?")
      equal Nothing (extractHelpFeel "これはヘルプのテキスト ? ")
