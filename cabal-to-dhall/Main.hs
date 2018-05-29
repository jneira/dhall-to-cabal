{-# language NamedFieldPuns #-}
{-# language OverloadedStrings #-}

module Main ( main ) where

import Control.Applicative ( (<**>), optional )
import Data.Version ( showVersion )
import GHC.Stack

import qualified Data.Text.Lazy as LazyText
import qualified Data.Text.Lazy.IO as LazyText
import qualified Data.Text.Prettyprint.Doc as Pretty
import qualified Data.Text.Prettyprint.Doc.Render.Text as Pretty
import qualified Data.Text.Prettyprint.Doc.Symbols.Unicode as Pretty
import qualified Dhall.Core
import qualified Options.Applicative as OptParse
import qualified System.IO

import CabalToDhall ( cabalToDhall, DhallLocation ( DhallLocation ) )
import qualified Paths_dhall_to_etlas as Paths


data Command
  = RunCabalToDhall CabalToDhallOptions


data CabalToDhallOptions = CabalToDhallOptions
  { cabalFilePath :: Maybe String
  }


cabalToDhallOptionsParser :: OptParse.Parser CabalToDhallOptions
cabalToDhallOptionsParser =
  CabalToDhallOptions
    <$>
      optional
        ( OptParse.argument
            OptParse.str
            ( mconcat
                [ OptParse.metavar "<cabal input file>"
                , OptParse.help "The Cabal file to convert to Dhall"
                ]
            )
        )


commandLineParser =
  RunCabalToDhall <$> ( cabalToDhallOptionsParser <**> OptParse.helper )


main :: IO ()
main = do
  command <-
    OptParse.execParser
      ( OptParse.info commandLineParser mempty )

  case command of
    RunCabalToDhall options ->
      runCabalToDhall options


version :: LazyText.Text
version = LazyText.pack ( showVersion Paths.version )


preludeLocation :: Dhall.Core.Import
preludeLocation =
  Dhall.Core.Import
    { Dhall.Core.importHashed =
        Dhall.Core.ImportHashed
          { Dhall.Core.hash =
              Nothing
          , Dhall.Core.importType =
              Dhall.Core.URL
                "https://raw.githubusercontent.com"
                ( Dhall.Core.File
                   ( Dhall.Core.Directory [ "dhall", version, "dhall-to-cabal", "dhall-lang" ] )
                   "prelude.dhall"
                )
                ""
                Nothing
          }
    , Dhall.Core.importMode =
        Dhall.Core.Code
    }


typesLocation :: Dhall.Core.Import
typesLocation =
  Dhall.Core.Import
    { Dhall.Core.importHashed =
        Dhall.Core.ImportHashed
          { Dhall.Core.hash =
              Nothing
          , Dhall.Core.importType =
              Dhall.Core.URL
                "https://raw.githubusercontent.com"
                ( Dhall.Core.File
                   ( Dhall.Core.Directory [ "dhall", version, "dhall-to-cabal", "dhall-lang" ] )
                   "types.dhall"
                )
                ""
                Nothing
          }
    , Dhall.Core.importMode =
        Dhall.Core.Code
    }


runCabalToDhall :: CabalToDhallOptions -> IO ()
runCabalToDhall CabalToDhallOptions{ cabalFilePath } = do
  let dhallLocation = DhallLocation preludeLocation typesLocation

  source <-
    case cabalFilePath of
      Nothing ->
        LazyText.getContents

      Just filePath ->
        LazyText.readFile filePath

  dhall <-
    cabalToDhall dhallLocation source

  Pretty.renderIO
    System.IO.stdout
    ( Pretty.layoutSmart opts
        ( Pretty.pretty dhall )
    )

  putStrLn ""



-- Shamelessly taken from dhall-format

-- Note: must remain in sync with the layout options in
-- golden-tests/GoldenTests.hs, so that test output is easy to generate
-- at the command line.
opts :: Pretty.LayoutOptions
opts =
  Pretty.defaultLayoutOptions
    { Pretty.layoutPageWidth = Pretty.AvailablePerLine 80 1.0 }
