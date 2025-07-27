module Test.Main where

import Prelude

import Effect (Effect)
import Test.Core (core)
import Test.Unit (suite, test)
import Test.Unit.Assert (assert)
import Test.Unit.Main (runTest)

main :: Effect Unit
main = do
  runTest do
    suite "main" do
      test "sample" do
        assert "sample" $ (2 + 2) == 4
  core
