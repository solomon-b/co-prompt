module CoPrompt where

--------------------------------------------------------------------------------

import Data.Foldable
import Data.Functor.Identity
import Data.Machine.Moore

--------------------------------------------------------------------------------

data Prompt f prompt choices result highlights = Prompt
  { prompt :: prompt,
    choices :: choices,
    highlighted :: f highlights,
    halt :: Maybe result
  }
  deriving (Show)

type PromptState = Prompt Identity String [String] String Int

data Command = Up | Down | Choose

parseCommand :: String -> Command
parseCommand "u" = Up
parseCommand "d" = Down
parseCommand "" = Choose
parseCommand _ = undefined

highlight :: Int -> [String] -> [String]
highlight _ [] = []
highlight 0 (x : xs) = ("* " <> x) : xs
highlight n (x : xs) = x : highlight (n - 1) xs

--------------------------------------------------------------------------------

mkMoore :: Prompt f p c r h -> (Prompt f p c r h -> Command -> Prompt f p c r h) -> Moore Command (Prompt f p c r h)
mkMoore s next = flip unfoldMoore s $ \ps -> (ps, next ps)

runMoore :: Moore Command PromptState -> IO ()
runMoore (Moore ps next) =
  case halt ps of
    Just msg -> putStrLn msg
    Nothing -> do
      putStrLn $ prompt ps
      traverse_ putStrLn (highlight (runIdentity $ highlighted ps) $ choices ps)

      nextInput <- getLine
      runMoore (next $ parseCommand nextInput)

colorPicker :: PromptState -> Moore Command PromptState
colorPicker s = mkMoore s $ \ps@Prompt {..} -> \case
  Up -> ps {highlighted = Identity $ (runIdentity highlighted - 1) `mod` length choices}
  Down -> ps {highlighted = Identity $ (runIdentity highlighted + 1) `mod` length choices}
  Choose -> ps {halt = Just $ "You chose: " <> (choices !! runIdentity highlighted)}

mooreMain :: IO ()
mooreMain = do
  let choices = ["red", "green", "blue"]
  runMoore $ colorPicker $ Prompt "Pick a color" choices 0 Nothing
