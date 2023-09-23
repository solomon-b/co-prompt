module CoPrompt where
 
--------------------------------------------------------------------------------

import Data.Map.Strict (Map)
-- import Data.Map.Strict qualified as Map
-- import System.FilePath
-- import System.Directory
 
--------------------------------------------------------------------------------

type Command = String
type Completion = String

data Step x = Step
  { enterChar :: Char -> x
  , backspace :: x
  , selectCompletions :: IO (Map Completion x)
  }
  deriving stock Functor

-- | Emacs style filepath prompt.
-- 
filepathPrompt :: [Command] -> Step [Command]
filepathPrompt input = do
  -- compls <- listDirectory $ joinPath chunks
  Step
    { enterChar = \case
          -- Start a new path fragment:
          '/' -> "" : input 
          -- Append char to existing path fragment:
          c | (x : xs) <- input -> (c:x) : xs
          c | [] <- input -> [[c]]
    , backspace =
        -- TODO: Delete the last char from the last input chunk or delete the chunk if it is empty
        undefined input
    , selectCompletions =
        -- TODO
        undefined
    }
