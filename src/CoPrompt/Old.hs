{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TupleSections #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

module CoPrompt.Old where

--------------------------------------------------------------------------------

import Data.Map.Strict (Map)

-- import Data.Map.Strict qualified as Map
-- import System.FilePath
-- import System.Directory

--------------------------------------------------------------------------------

-- | The contents of the prompt input field.
type Command = [String]

-- | A possible completion for the current command.
type Completion = String

-- | The 'Step' 'Functor' represents interaction steps with the
-- prompt.
--
-- Each field of the record is a possible action at this step in the
-- unfolding interaction.
--
-- A series of interactions looks like @Step (Step (Step (Step x)))@
-- which we then fold into a final action.
data Step x = Step
  { -- | 'Char' user input adding a 'Char' to the completion
    enterChar :: Char -> x,
    -- | Delete the last 'Char' from the completion
    -- , selectCompletions :: IO (Map Completion x)
    -- -- ^
    backspace :: x
  }
  deriving stock (Functor)

-- | Emacs style filepath prompt.
filepathPrompt :: Command -> Step Command
filepathPrompt input = do
  -- compls <- listDirectory $ joinPath chunks
  Step
    { enterChar = \case
        -- Start a new path fragment:
        '/' -> "" : input
        -- Append char to existing path fragment:
        c | (x : xs) <- input -> (c : x) : xs
        c | [] <- input -> [[c]],
      backspace = backspace' input
      -- , selectCompletions =
      --     -- TODO
      --     undefined
    }

dropLast :: String -> String
dropLast [] = []
dropLast xs = reverse $ tail $ reverse xs

-- | Delete the last char from the last input chunk or delete the chunk if it is
-- empty
backspace' :: Command -> [String]
backspace' xs' =
  case reverse xs' of
    [] -> []
    "" : rest -> reverse rest
    (x : xs) -> reverse (dropLast x : xs)
