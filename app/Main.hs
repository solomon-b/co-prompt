module Main where

import Fudgets

main :: IO ()
main = fudlogue (shellF "Up Counter" counterF)

counterF = intDispF >==< mapstateF count 0 >==< buttonF "Up"

count n Click = (n + 1, [n + 1])
