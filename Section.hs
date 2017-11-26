{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS -Wno-unused-imports #-}
{-# OPTIONS -Wno-unused-matches #-}
module Section where

import Turtle hiding (f, e, x, o, s)
--import Filesystem.Path.CurrentOS ( FilePath(FilePath) )
import Data.Text (Text, lines)
import Data.Monoid ((<>))
import Prelude hiding (lines)
import Safe
import System.Posix.Directory
import qualified Control.Foldl as Fold
import Data.String.Conversions
import Filesystem.Path.CurrentOS (encodeString, fromText)
import Render
import Text.Mustache
import Data.Bool
import System.Directory
import Data.Text (splitOn)
import Text.Regex.Posix
import Git

compileSection :: Text -> IO (Either String Text)
compileSection filePrefix = do
  let v = find (prefix $ fromString $ dir ++ convertString filePrefix) (fromString dir)
        where
          dir = "sections/"
  fP <- fold (v) Fold.head
  case fP of
    Just fP' -> do
      let fP'' = convertString $ encodeString $ fP'
      cHash <- gitPathCommitHash fP''
      case cHash of
        Just cHash' -> do
          z <- gitCheckout cHash' "src/"
          case z of
            ExitSuccess -> do
              sContent <- readTextFile fP'
              rendered <- renderTemplate sContent
              case rendered of
                Right r -> do
                  appendFile compiledOutput $ convertString r
                  return $ Right "Success compilation"
                Left e -> return $ Left e
            _ -> return $ Left ":("
        Nothing -> return $ Left $ convertString $ "Unable to retrieve commit for " <> fP''
    Nothing -> return $ Left "Nope"

compiledOutput :: Prelude.FilePath
compiledOutput = "compiledArticle.md"
