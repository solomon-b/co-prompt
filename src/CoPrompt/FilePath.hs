module CoPrompt.FilePath where

--------------------------------------------------------------------------------

import Control.Arrow
import Data.Bool
import Data.Foldable
import Data.Text (Text)
import Data.Text qualified as Text
import System.Directory hiding (isSymbolicLink)
import System.FilePath
import System.Posix.Files

--------------------------------------------------------------------------------

data PathType = Relative | Absolute
  deriving (Show)

data Path = Path {path :: [Text], pathType :: PathType}
  deriving stock (Show)

mkPath :: FilePath -> Path
mkPath fp = Path (fmap Text.pack $ splitPath fp) (bool Absolute Relative (isRelative fp))

prettyPath :: Path -> FilePath
prettyPath Path {path} =
  foldl' (</>) "" (fmap Text.unpack path)

--------------------------------------------------------------------------------

data FileType = Regular | BlockDevice | CharacterDevice | NamedPipe | Directory | SymbolicLink | Socket
  deriving stock (Show)

data File = File
  { fPath :: Path,
    fType :: FileType
  }
  deriving (Show)

mkNode :: FilePath -> IO File
mkNode fp =
  pathIsSymbolicLink fp >>= \case
    True -> pure (File (mkPath fp) SymbolicLink)
    False ->
      getFileStatus fp >>= \case
        fs | isBlockDevice fs -> pure (File (mkPath fp) BlockDevice)
        fs | isCharacterDevice fs -> pure (File (mkPath fp) CharacterDevice)
        fs | isNamedPipe fs -> pure (File (mkPath fp) NamedPipe)
        fs | isRegularFile fs -> pure (File (mkPath fp) Regular)
        fs | isDirectory fs -> pure (File (mkPath fp) Directory)
        fs | isSocket fs -> pure (File (mkPath fp) Socket)

--------------------------------------------------------------------------------

-- 1. Define the state space
data PromptState = PromptState
  { input :: String,
    history :: [String],
    directoryPath :: Path,
    directoryContents :: [File]
  }
  deriving (Show)

--------------------------------------------------------------------------------

data InteractionF next = Ask String (String -> next) | Done
  deriving stock (Functor)

--------------------------------------------------------------------------------

type CoAlgebra f s = s -> f s

--------------------------------------------------------------------------------

interactionStep :: CoAlgebra InteractionF PromptState
interactionStep ps@(PromptState msg history curPath curContent) = Ask msg $ \userInput ->
  let newHistory = history <> [userInput]
   in if userInput == "exit"
        then ps {history = newHistory}
        else
          if userInput == "history"
            then ps {input = show history, history = newHistory}
            else ps {input = "You said: " ++ userInput ++ ". Say more!", history = newHistory}

runInteraction :: PromptState -> IO ()
runInteraction state = case interactionStep state of
  Ask input next -> do
    putStrLn input
    putStrLn $ "> " <> (prettyPath $ directoryPath state)
    traverse_ (putStrLn . prettyPath) (fmap fPath $ directoryContents state)
    nextInput <- getContents
    runInteraction (next nextInput)
  Done -> return ()

initialState :: Path -> [File] -> PromptState
initialState = PromptState "Find file" []

split :: Char -> String -> [String]
split c s = case rest of
  [] -> [chunk]
  _ : rest -> chunk : split c rest
  where
    (chunk, rest) = break (== c) s

main :: IO ()
main = do
  currentDir <- getCurrentDirectory
  dirContents <- listDirectory currentDir
  contents <- traverse (mkNode . (</>) currentDir) dirContents
  runInteraction $ initialState (mkPath currentDir) contents
