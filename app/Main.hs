{-# LANGUAGE TemplateHaskell #-}

import Language.Haskell.TH.Syntax

main :: IO ()
main = putStrLn $( do liftString ("answer: " ++ show 42) )

