{-# language FlexibleContexts #-}
{-# language FlexibleInstances #-}
{-# language GADTs #-}
{-# language LambdaCase #-}
{-# language OverloadedStrings #-}
{-# language PatternSynonyms #-}
{-# language RecordWildCards #-}

module DhallToCabal
  ( dhallToCabal
  , genericPackageDescription
  , sourceRepo
  , repoKind
  , repoType
  , compiler
  , operatingSystem
  , library
  , extension
  , compilerOptions
  , guarded
  , arch
  , compilerFlavor
  , language
  , license
  , executable
  , testSuite
  , benchmark
  , foreignLib
  , buildType
  , versionRange
  , version
  , configRecordType

  , sortExpr
  ) where
import Control.Exception ( Exception, throwIO )
import Data.Function ( (&) )
import Data.List ( partition )
import Data.Maybe ( fromMaybe )
import Data.Monoid ( (<>) )
import Formatting.Buildable ( Buildable(..) )

import qualified Data.ByteString.Lazy as LazyByteString
import qualified Data.HashMap.Strict.InsOrd as Map
import qualified Data.Text as StrictText
import qualified Data.Text.Encoding as StrictText
import qualified Data.Text.Lazy as LazyText
import qualified Data.Text.Lazy.Builder as Builder
import qualified Data.Text.Lazy.Encoding as LazyText
import qualified Dhall
import qualified Dhall.Core
import qualified Dhall.Import
import qualified Dhall.Parser
import qualified Dhall.TypeCheck
import qualified Distribution.Compiler as Cabal
import qualified Distribution.License as Cabal
import qualified Distribution.ModuleName as Cabal
import qualified Distribution.PackageDescription as Cabal
import qualified Distribution.System as Cabal ( Arch(..), OS(..) )
import qualified Distribution.Text as Cabal ( simpleParse )
import qualified Distribution.Types.CondTree as Cabal
import qualified Distribution.Types.Dependency as Cabal
import qualified Distribution.Types.ExeDependency as Cabal
import qualified Distribution.Types.Executable as Cabal
import qualified Distribution.Types.ForeignLib as Cabal
import qualified Distribution.Types.ForeignLibOption as Cabal
import qualified Distribution.Types.ForeignLibType as Cabal
import qualified Distribution.Types.IncludeRenaming as Cabal
import qualified Distribution.Types.LegacyExeDependency as Cabal
import qualified Distribution.Types.Mixin as Cabal
import qualified Distribution.Types.PackageId as Cabal
import qualified Distribution.Types.PackageName as Cabal
import qualified Distribution.Types.PkgconfigDependency as Cabal
import qualified Distribution.Types.PkgconfigName as Cabal
import qualified Distribution.Types.UnqualComponentName as Cabal
import qualified Distribution.Version as Cabal
import qualified Language.Haskell.Extension as Cabal

import qualified Dhall.Core as Expr
  ( Chunks(..), Const(..), Expr(..), Var(..) )

import Dhall.Extra
import DhallToCabal.ConfigTree ( ConfigTree(..), toConfigTree )
import DhallToCabal.Diff ( Diffable(..)  )



packageIdentifier :: RecordBuilder Cabal.PackageIdentifier
packageIdentifier =
  Cabal.PackageIdentifier <$> keyValue "name" packageName
                          <*> keyValue "version" version



packageName :: Dhall.Type Cabal.PackageName
packageName = Cabal.mkPackageName <$> Dhall.string



packageDescription :: RecordBuilder Cabal.PackageDescription
packageDescription =
  Cabal.PackageDescription
  <$> packageIdentifier
  <*> keyValue "license" license
  <*> keyValue "license-files" ( Dhall.list Dhall.string )
  <*> keyValue "copyright" Dhall.string
  <*> keyValue "maintainer" Dhall.string
  <*> keyValue "author" Dhall.string
  <*> keyValue "stability" Dhall.string
  <*> keyValue "tested-with" ( Dhall.list compiler )
  <*> keyValue "homepage" Dhall.string
  <*> keyValue "package-url" Dhall.string
  <*> keyValue "bug-reports" Dhall.string
  <*> keyValue "source-repos" ( Dhall.list sourceRepo )
  <*> keyValue "synopsis" Dhall.string
  <*> keyValue "description" Dhall.string
  <*> keyValue "category" Dhall.string
  <*> keyValue "x-fields"
      ( Dhall.list ( Dhall.pair Dhall.string Dhall.string ) )
    -- Cabal documentation states
  --
  --   > YOU PROBABLY DON'T WANT TO USE THIS FIELD.
  --
  -- So I guess we won't use this field.
  <*> pure [] -- buildDepends
  <*> (Left <$> keyValue "cabal-version" version)
  <*> keyValue "build-type" ( Dhall.maybe buildType )
  <*> keyValue "custom-setup" ( Dhall.maybe setupBuildInfo )
  <*> pure Nothing -- library
  <*> pure [] -- subLibraries
  <*> pure [] -- executables
  <*> pure [] -- foreignLibs
  <*> pure [] -- testSuites
  <*> pure [] -- benchmarks
  <*> keyValue "data-files" ( Dhall.list Dhall.string )
  <*> keyValue "data-dir" Dhall.string
  <*> keyValue "extra-source-files" ( Dhall.list Dhall.string )
  <*> keyValue "extra-tmp-files" ( Dhall.list Dhall.string )
  <*> keyValue "extra-doc-files" ( Dhall.list Dhall.string )



version :: Dhall.Type Cabal.Version
version =
  let
    parse builder =
      fromMaybe
        ( error "Could not parse version" )
        ( Cabal.simpleParse ( LazyText.unpack ( Builder.toLazyText builder ) ) )

    extract =
      \case
        LamArr _Version (LamArr _v v) ->
          go v

        e ->
          error ( show e )

    go =
      \case
        Expr.App ( V0 "v" ) ( Expr.TextLit ( Expr.Chunks [] builder ) ) ->
          return ( parse builder )

        e ->
          error ( show e )

    expected =
      Expr.Pi "Version" ( Expr.Const Expr.Type )
        $ Expr.Pi
            "v"
            ( Expr.Pi "_" ( Dhall.expected Dhall.string ) ( V0 "Version" ) )
            ( V0 "Version" )

  in Dhall.Type { .. }



benchmark :: Dhall.Type Cabal.Benchmark
benchmark =
  makeRecord $
  (\ mainIs benchmarkName benchmarkBuildInfo ->
    Cabal.Benchmark
       { benchmarkInterface =
            Cabal.BenchmarkExeV10 ( Cabal.mkVersion [ 1, 0 ] ) mainIs
        , ..
        }) <$> keyValue "main-is" Dhall.string
           <*> pure "" <*> buildInfo



buildInfo :: RecordBuilder Cabal.BuildInfo
buildInfo = Cabal.BuildInfo
  <$> keyValue "buildable" Dhall.bool
  <*> keyValue "build-tools"
      ( Dhall.list legacyExeDependency )
  <*> keyValue "build-tool-depends"
      ( Dhall.list exeDependency )
  <*> keyValue "cpp-options" ( Dhall.list Dhall.string )
  <*> keyValue "cc-options" ( Dhall.list Dhall.string )
  <*> keyValue "ld-options" ( Dhall.list Dhall.string )
  <*> keyValue "pkgconfig-depends"
      ( Dhall.list pkgconfigDependency )
  <*> keyValue "frameworks" ( Dhall.list Dhall.string )
  <*> keyValue "extra-framework-dirs"
      ( Dhall.list Dhall.string )
  <*> keyValue "c-sources" ( Dhall.list Dhall.string )
  <*> keyValue "js-sources" ( Dhall.list Dhall.string )
  <*> keyValue "java-sources" ( Dhall.list Dhall.string )
  <*> keyValue "hs-source-dirs" ( Dhall.list Dhall.string )
  <*> keyValue "other-modules" ( Dhall.list moduleName )
  <*> keyValue "autogen-modules" ( Dhall.list moduleName )
  <*> keyValue "default-language" ( Dhall.maybe language )
  <*> keyValue "other-languages" ( Dhall.list language )
  <*> keyValue "default-extensions" ( Dhall.list extension )
  <*> keyValue "other-extensions" ( Dhall.list extension )
  <*> pure []  -- old-extensions
  <*> keyValue "maven-depends" ( Dhall.list Dhall.string )
  <*> keyValue "extra-ghci-libraries"
      ( Dhall.list Dhall.string )
  <*> keyValue "extra-lib-dirs" ( Dhall.list Dhall.string )
  <*> keyValue "include-dirs" ( Dhall.list Dhall.string )
  <*> keyValue "includes" ( Dhall.list Dhall.string )
  <*> keyValue "install-includes" ( Dhall.list Dhall.string )
  <*> keyValue "compiler-options" compilerOptions
  <*> keyValue "profiling-options" compilerOptions
  <*> keyValue "shared-options" compilerOptions
  <*> pure [] --  customFieldsBI
  <*> keyValue "build-depends" ( Dhall.list dependency )
  <*> keyValue "mixins" ( Dhall.list mixin )



testSuite :: Dhall.Type Cabal.TestSuite
testSuite =
  makeRecord $
  Cabal.TestSuite <$> pure "" <*> keyValue "type" testSuiteInterface
                  <*> buildInfo



testSuiteInterface :: Dhall.Type Cabal.TestSuiteInterface
testSuiteInterface =
  makeUnion
    ( Map.fromList
        [ ( "exitcode-stdio"
          , Cabal.TestSuiteExeV10 ( Cabal.mkVersion [ 1, 0 ] )
              <$> makeRecord ( keyValue "main-is" Dhall.string )
          )
        , ( "detailed"
          , Cabal.TestSuiteLibV09 ( Cabal.mkVersion [ 0, 9 ] )
              <$> makeRecord ( keyValue "module" moduleName )
          )
        ]
    )



unqualComponentName :: Dhall.Type Cabal.UnqualComponentName
unqualComponentName =
  Cabal.mkUnqualComponentName <$> Dhall.string



executable :: Dhall.Type Cabal.Executable
executable =
  makeRecord $
  Cabal.Executable <$> pure "" -- exeName
                   <*> keyValue "main-is" Dhall.string
                   <*> buildInfo



foreignLib :: Dhall.Type Cabal.ForeignLib
foreignLib =
  makeRecord $
  Cabal.ForeignLib <$> pure "" -- foreignLibName
                   <*> keyValue "type" foreignLibType
                   <*> keyValue "options" ( Dhall.list foreignLibOption )
                   <*> buildInfo
                   <*> keyValue "lib-version-info"
                       ( Dhall.maybe versionInfo )
                   <*> keyValue "lib-version-linux" ( Dhall.maybe version )
                   <*> keyValue "mod-def-files" ( Dhall.list Dhall.string )



foreignLibType :: Dhall.Type Cabal.ForeignLibType
foreignLibType =
  makeUnion
    ( Map.fromList
        [ ( "Shared", Cabal.ForeignLibNativeShared <$ Dhall.unit )
        , ( "Static", Cabal.ForeignLibNativeStatic <$ Dhall.unit )
        ]
    )



library :: Dhall.Type Cabal.Library
library =
  makeRecord $
    Cabal.Library <$> pure Nothing -- libName
                  <*> keyValue "exposed-modules"
                      ( Dhall.list moduleName )
                  <*> keyValue "reexported-modules"
                      ( Dhall.list moduleReexport )
                  <*> keyValue "signatures" ( Dhall.list moduleName )
                  <*> pure True -- libExposed
                  <*> buildInfo



sourceRepo :: Dhall.Type Cabal.SourceRepo
sourceRepo =
  makeRecord $
  Cabal.SourceRepo <$> keyValue "kind" repoKind
                   <*> keyValue "type" ( Dhall.maybe repoType )
                   <*> keyValue "location" ( Dhall.maybe Dhall.string )
                   <*> keyValue "module" ( Dhall.maybe Dhall.string )
                   <*> keyValue "branch" ( Dhall.maybe Dhall.string )
                   <*> keyValue "tag" ( Dhall.maybe Dhall.string )
                   <*> keyValue "repoCommit" ( Dhall.maybe Dhall.string )
                   <*> keyValue "subdir" ( Dhall.maybe filePath )


repoKind :: Dhall.Type Cabal.RepoKind
repoKind =
  sortType Dhall.genericAuto



dependency :: Dhall.Type Cabal.Dependency
dependency =
  makeRecord $
  Cabal.Dependency <$> keyValue "package" packageName
                   <*> keyValue "bounds" versionRange



moduleName :: Dhall.Type Cabal.ModuleName
moduleName =
  validateType $
    Cabal.simpleParse <$> Dhall.string



dhallToCabal :: FilePath -> LazyText.Text -> IO Cabal.GenericPackageDescription
dhallToCabal fileName source =
  input fileName source genericPackageDescription


input :: FilePath -> LazyText.Text -> Dhall.Type a -> IO a
input fileName source t = do

  expr  <-
    throws ( Dhall.Parser.exprFromText fileName source )

  expr' <-
    Dhall.Import.load expr

  let
    suffix =
      Dhall.expected t
        & build
        & Builder.toLazyText

  let
    annot =
      case expr' of
        Expr.Note ( Dhall.Parser.Src begin end bytes ) _ ->
          Expr.Note
            ( Dhall.Parser.Src begin end bytes' )
            ( Expr.Annot expr' ( Dhall.expected t ) )

          where

          bytes' =
            bytes <> " : " <> suffix

        _ ->
          Expr.Annot expr' ( Dhall.expected t )

  _ <-
    throws (Dhall.TypeCheck.typeOf annot)

  case Dhall.extract t ( Dhall.Core.normalize expr' ) of
    Just x  ->
      return x

    Nothing ->
      throwIO Dhall.InvalidType

  where

    throws :: Exception e => Either e a -> IO a
    throws =
      either throwIO return



pattern LamArr :: Expr.Expr s a -> Expr.Expr s a -> Expr.Expr s a
pattern LamArr a b <- Expr.Lam _ a b



pattern V0 v = Expr.Var ( Expr.V v 0 )



versionRange :: Dhall.Type Cabal.VersionRange
versionRange =
  let
    extract =
      \case
        LamArr _VersionRange (LamArr _anyVersion (LamArr _noVersion (LamArr _thisVersion (LamArr _notThisVersion (LamArr _laterVersion (LamArr _earlierVersion (LamArr _orLaterVersion (LamArr _orEarlierVersion (LamArr _withinVersion (LamArr _majorBoundVersion (LamArr _unionVersionRanges (LamArr _intersectVersionRanges (LamArr _differenceVersionRanges (LamArr _invertVersionRange versionRange)))))))))))))) ->
          go versionRange

        _ ->
          Nothing

    go =
      \case
        V0 "anyVersion" ->
          return Cabal.anyVersion

        V0 "noVersion" ->
          return Cabal.noVersion

        Expr.App ( V0 "thisVersion" ) components ->
          Cabal.thisVersion <$> Dhall.extract version components

        Expr.App ( V0 "notThisVersion" ) components ->
          Cabal.notThisVersion <$> Dhall.extract version components

        Expr.App ( V0 "laterVersion" ) components ->
          Cabal.laterVersion <$> Dhall.extract version components

        Expr.App ( V0 "earlierVersion" ) components ->
          Cabal.earlierVersion <$> Dhall.extract version components

        Expr.App ( V0 "orLaterVersion" ) components ->
          Cabal.orLaterVersion <$> Dhall.extract version components

        Expr.App ( V0 "orEarlierVersion" ) components ->
          Cabal.orEarlierVersion <$> Dhall.extract version components

        Expr.App ( Expr.App ( V0 "unionVersionRanges" ) a ) b ->
          Cabal.unionVersionRanges <$> go a <*> go b

        Expr.App ( Expr.App ( V0 "intersectVersionRanges" ) a ) b ->
          Cabal.intersectVersionRanges <$> go a <*> go b

        Expr.App ( Expr.App ( V0 "differenceVersionRanges" ) a ) b ->
          Cabal.differenceVersionRanges <$> go a <*> go b

        Expr.App ( V0 "invertVersionRange" ) components ->
          Cabal.invertVersionRange <$> go components

        Expr.App ( V0 "withinVersion" ) components ->
          Cabal.withinVersion <$> Dhall.extract version components

        Expr.App ( V0 "majorBoundVersion" ) components ->
          Cabal.majorBoundVersion <$> Dhall.extract version components

        _ ->
          Nothing

    expected =
      let
        versionRange =
          V0 "VersionRange"

        versionToVersionRange =
          Expr.Pi
            "_"
            ( Dhall.expected version )
            versionRange

        combine =
          Expr.Pi "_" versionRange ( Expr.Pi "_" versionRange versionRange )

      in
      Expr.Pi "VersionRange" ( Expr.Const Expr.Type )
        $ Expr.Pi "anyVersion" versionRange
        $ Expr.Pi "noVersion" versionRange
        $ Expr.Pi "thisVersion" versionToVersionRange
        $ Expr.Pi "notThisVersion" versionToVersionRange
        $ Expr.Pi "laterVersion" versionToVersionRange
        $ Expr.Pi "earlierVersion" versionToVersionRange
        $ Expr.Pi "orLaterVersion" versionToVersionRange
        $ Expr.Pi "orEarlierVersion" versionToVersionRange
        $ Expr.Pi "withinVersion" versionToVersionRange
        $ Expr.Pi "majorBoundVersion" versionToVersionRange
        $ Expr.Pi "unionVersionRanges" combine
        $ Expr.Pi "intersectVersionRanges" combine
        $ Expr.Pi "differenceVersionRanges" combine
        $ Expr.Pi
            "invertVersionRange"
            ( Expr.Pi "_" versionRange versionRange )
            versionRange

  in Dhall.Type { .. }



buildType :: Dhall.Type Cabal.BuildType
buildType =
  sortType Dhall.genericAuto



license :: Dhall.Type Cabal.License
license =
  makeUnion
    ( Map.fromList
        [ ( "GPL", Cabal.GPL <$> Dhall.maybe version )
        , ( "AGPL", Cabal.AGPL <$> Dhall.maybe version )
        , ( "LGPL", Cabal.LGPL <$> Dhall.maybe version )
        , ( "BSD2", Cabal.BSD2 <$ Dhall.unit )
        , ( "BSD3", Cabal.BSD3 <$ Dhall.unit )
        , ( "BSD4", Cabal.BSD4 <$ Dhall.unit )
        , ( "MIT", Cabal.MIT <$ Dhall.unit )
        , ( "ISC", Cabal.ISC <$ Dhall.unit )
        , ( "MPL", Cabal.MPL <$> version )
        , ( "Apache", Cabal.Apache <$> Dhall.maybe version )
        , ( "PublicDomain", Cabal.PublicDomain <$ Dhall.unit )
        , ( "AllRightsReserved", Cabal.AllRightsReserved<$ Dhall.unit )
        , ( "Unspecified", Cabal.UnspecifiedLicense <$ Dhall.unit )
        , ( "Other", Cabal.OtherLicense <$ Dhall.unit )
        ]
    )



compiler :: Dhall.Type ( Cabal.CompilerFlavor, Cabal.VersionRange )
compiler =
  makeRecord $
    (,)
      <$> keyValue "compiler" compilerFlavor
      <*> keyValue "version" versionRange



compilerFlavor :: Dhall.Type Cabal.CompilerFlavor
compilerFlavor =
  sortType Dhall.genericAuto



repoType :: Dhall.Type Cabal.RepoType
repoType =
  sortType Dhall.genericAuto



legacyExeDependency :: Dhall.Type Cabal.LegacyExeDependency
legacyExeDependency =
  makeRecord $
  Cabal.LegacyExeDependency <$> keyValue "exe" Dhall.string
                            <*> keyValue "version" versionRange



compilerOptions :: Dhall.Type [ ( Cabal.CompilerFlavor, [ String ] ) ]
compilerOptions =
  makeRecord $
    sequenceA
      [ (,) <$> pure Cabal.GHC <*> keyValue "GHC" options
      , (,) <$> pure Cabal.GHCJS <*> keyValue "GHCJS" options
      , (,) <$> pure Cabal.NHC <*> keyValue "NHC" options
      , (,) <$> pure Cabal.YHC <*> keyValue "YHC" options
      , (,) <$> pure Cabal.Hugs <*> keyValue "Hugs" options
      , (,) <$> pure Cabal.HBC <*> keyValue "HBC" options
      , (,) <$> pure Cabal.Helium <*> keyValue "Helium" options
      , (,) <$> pure Cabal.JHC <*> keyValue "JHC" options
      , (,) <$> pure Cabal.LHC <*> keyValue "LHC" options
      , (,) <$> pure Cabal.UHC <*> keyValue "UHC" options
      ]

  where

    options =
      Dhall.list Dhall.string



exeDependency :: Dhall.Type Cabal.ExeDependency
exeDependency = 
  makeRecord $
  Cabal.ExeDependency <$> keyValue "package" packageName
                      <*> keyValue "component" unqualComponentName
                      <*> keyValue "version" versionRange



language :: Dhall.Type Cabal.Language
language =
  sortType Dhall.genericAuto



pkgconfigDependency :: Dhall.Type Cabal.PkgconfigDependency
pkgconfigDependency =
  makeRecord $
  Cabal.PkgconfigDependency <$> keyValue "name" pkgconfigName
                            <*> keyValue "version" versionRange



pkgconfigName :: Dhall.Type Cabal.PkgconfigName
pkgconfigName =
  Cabal.mkPkgconfigName <$> Dhall.string



moduleReexport :: Dhall.Type Cabal.ModuleReexport
moduleReexport =
  makeRecord $
  Cabal.ModuleReexport <$> keyValue "moduleReexportOriginalPackage"
                           ( Dhall.maybe packageName )
                       <*> keyValue "moduleReexportOriginalName" moduleName
                       <*> keyValue "moduleReexportName" moduleName



foreignLibOption :: Dhall.Type Cabal.ForeignLibOption
foreignLibOption =
  makeUnion
    ( Map.fromList
        [ ( "Standalone", Cabal.ForeignLibStandalone <$ Dhall.unit ) ]
    )


versionInfo :: Dhall.Type Cabal.LibVersionInfo
versionInfo =
  makeRecord $
  fmap Cabal.mkLibVersionInfo $
    (,,)
      <$> ( fromIntegral <$> keyValue "current" Dhall.natural )
      <*> ( fromIntegral <$> keyValue "revision" Dhall.natural )
      <*> ( fromIntegral <$> keyValue "age" Dhall.natural )



extension :: Dhall.Type Cabal.Extension
extension =
  let
    knownExtension =
      sortType Dhall.genericAuto

    unitType =
      Expr.Record Map.empty

    extract expr = do
      Expr.UnionLit k v alts <-
        return expr

      ext <-
        Dhall.extract
          knownExtension
          ( Expr.UnionLit k ( Expr.RecordLit mempty ) ( unitType <$ alts ) )

      case v of
        Expr.BoolLit True ->
          return ( Cabal.EnableExtension ext )

        Expr.BoolLit False ->
          return ( Cabal.DisableExtension ext )

        _ ->
          Nothing

    expected =
      case Dhall.expected knownExtension of
        Expr.Union alts ->
          sortExpr ( Expr.Union ( Expr.Bool <$ alts ) )

        _ ->
          error "Could not derive extension type"

  in Dhall.Type { .. }



guarded
  :: ( Monoid a, Eq a, Diffable a )
  => Dhall.Type a
  -> Dhall.Type ( Cabal.CondTree Cabal.ConfVar [Cabal.Dependency] a )
guarded t =
  let
    extractConfVar body =
      case body of
        Expr.App ( Expr.App ( Expr.Field ( V0 "config" ) "impl" ) compiler ) version ->
          Cabal.Impl
            <$> Dhall.extract compilerFlavor compiler
            <*> Dhall.extract versionRange version

        Expr.App ( Expr.Field ( V0 "config" ) field ) x ->
          case field of
            "os" ->
              Cabal.OS <$> Dhall.extract operatingSystem x

            "arch" ->
              Cabal.Arch <$> Dhall.extract arch x

            "flag" ->
              Cabal.Flag <$> Dhall.extract flagName x

            _ ->
              error "Unknown field"

        _ ->
          error ( "Unexpected guard expression. This is a bug, please report this! I'm stuck on: " ++ show body )

    extract expr =
      configTreeToCondTree [] <$> extractConfigTree ( toConfigTree expr )

    extractConfigTree ( Leaf a ) =
      Leaf <$> Dhall.extract t a

    extractConfigTree ( Branch cond a b ) =
      Branch <$> extractConfVar cond <*> extractConfigTree a <*> extractConfigTree b

    configTreeToCondTree confVars = \case
      Leaf a ->
        Cabal.CondNode a mempty mempty

      -- The condition has already been shown to hold. Consider only the true
      -- branch and discard the false branch.
      Branch confVar a _impossible | confVar `elem` confVars ->
        configTreeToCondTree confVars a

      Branch confVar a b ->
        let
          confVars' =
            pure confVar <> confVars

          true =
            configTreeToCondTree confVars' a

          false =
            configTreeToCondTree confVars' b

          ( common, true', false' ) =
            diff ( Cabal.condTreeData true ) ( Cabal.condTreeData false )

          ( duplicates, true'', false'' ) =
            diff
              ( Cabal.condTreeComponents false )
              ( Cabal.condTreeComponents true )

        in
          Cabal.CondNode
            common
            mempty
            ( mergeCommonGuards
                ( Cabal.CondBranch
                    ( Cabal.Var confVar )
                    true
                      { Cabal.condTreeData = true'
                      , Cabal.condTreeComponents = true''
                      }
                    ( Just
                        false
                          { Cabal.condTreeData = false'
                          , Cabal.condTreeComponents = false''
                          }
                    )
                : duplicates
                )
            )

    expected =
        Expr.Pi "_" configRecordType ( Dhall.expected t )

  in Dhall.Type { .. }



catCondTree
  :: ( Monoid c, Monoid a )
  => Cabal.CondTree v c a -> Cabal.CondTree v c a -> Cabal.CondTree v c a
catCondTree a b =
  Cabal.CondNode
    { Cabal.condTreeData =
        Cabal.condTreeData a <> Cabal.condTreeData b
    , Cabal.condTreeConstraints =
        Cabal.condTreeConstraints a <> Cabal.condTreeConstraints b
    , Cabal.condTreeComponents =
        Cabal.condTreeComponents a <> Cabal.condTreeComponents b
    }



emptyCondTree :: ( Monoid b, Monoid c ) => Cabal.CondTree a b c
emptyCondTree =
  Cabal.CondNode mempty mempty mempty



mergeCommonGuards
  :: ( Monoid a, Monoid c, Eq v )
  => [Cabal.CondBranch v c a]
  -> [Cabal.CondBranch v c a]
mergeCommonGuards [] =
  []

mergeCommonGuards ( a : as ) =
  let
    ( sameGuard, differentGuard ) =
      partition
        ( ( Cabal.condBranchCondition a == ) . Cabal.condBranchCondition )
        as

  in
    a
      { Cabal.condBranchIfTrue =
          catCondTree
            ( Cabal.condBranchIfTrue a )
            ( foldl
                catCondTree
                emptyCondTree
                ( Cabal.condBranchIfTrue <$> sameGuard )
            )
      , Cabal.condBranchIfFalse =
          Just
            ( catCondTree
              ( fromMaybe emptyCondTree ( Cabal.condBranchIfFalse a ) )
              ( foldl
                  catCondTree
                  emptyCondTree
                  ( fromMaybe emptyCondTree
                      . Cabal.condBranchIfFalse
                      <$> sameGuard
                  )
              )
            )
      }
      : mergeCommonGuards differentGuard



configRecordType :: Expr.Expr Dhall.Parser.Src Dhall.TypeCheck.X
configRecordType =
  let
    predicate on =
      Expr.Pi "_" on Expr.Bool

  in
    Expr.Record
      ( Map.fromList
          [ ( "os", predicate ( Dhall.expected operatingSystem ) )
          , ( "arch", predicate ( Dhall.expected arch ) )
          , ( "flag", predicate ( Dhall.expected flagName ) )
          , ( "impl"
            , Expr.Pi
                "_"
                ( Dhall.expected compilerFlavor )
                ( Expr.Pi "_" ( Dhall.expected versionRange ) Expr.Bool )
            )
          ]
      )



genericPackageDescription :: Dhall.Type Cabal.GenericPackageDescription
genericPackageDescription =
  let
    namedList k t =
      Dhall.list
        ( makeRecord
            ( (,)
                <$> keyValue "name" unqualComponentName
                <*> keyValue k ( guarded t )
            )
        )

  in
    makeRecord $ Cabal.GenericPackageDescription
      <$> packageDescription
      <*> keyValue "flags" ( Dhall.list flag )
      <*> keyValue "library" ( Dhall.maybe ( guarded library ) )
      <*> keyValue "sub-libraries" ( namedList "library" library )
      <*> keyValue "foreign-libraries" ( namedList "foreign-lib" foreignLib )
      <*> keyValue "executables" ( namedList "executable" executable )
      <*> keyValue "test-suites" ( namedList "test-suite" testSuite )
      <*> keyValue "benchmarks" ( namedList "benchmark" benchmark )



operatingSystem :: Dhall.Type Cabal.OS
operatingSystem =
  sortType Dhall.genericAuto



arch :: Dhall.Type Cabal.Arch
arch =
  sortType Dhall.genericAuto



flag :: Dhall.Type Cabal.Flag
flag = makeRecord $
       Cabal.MkFlag <$> keyValue "name" flagName
                    <*> keyValue "description" Dhall.string
                    <*> keyValue "default" Dhall.bool
                    <*> keyValue "manual" Dhall.bool



flagName :: Dhall.Type Cabal.FlagName
flagName =
  Cabal.mkFlagName <$> Dhall.string



setupBuildInfo :: Dhall.Type Cabal.SetupBuildInfo
setupBuildInfo =
  makeRecord $
  Cabal.SetupBuildInfo <$> keyValue "setup-depends" ( Dhall.list dependency )
                       <*> pure False



filePath :: Dhall.Type FilePath
filePath =
  Dhall.string



mixin :: Dhall.Type Cabal.Mixin
mixin =
  makeRecord $ Cabal.Mixin <$> keyValue "package" packageName
                           <*> keyValue "renaming" includeRenaming



includeRenaming :: Dhall.Type Cabal.IncludeRenaming
includeRenaming =
  makeRecord $
  Cabal.IncludeRenaming <$> keyValue "provides" moduleRenaming
                        <*> keyValue "requires" moduleRenaming


moduleRenaming :: Dhall.Type Cabal.ModuleRenaming
moduleRenaming =
  fmap Cabal.ModuleRenaming $
  Dhall.list $
  makeRecord $
    (,) <$> keyValue "rename" moduleName <*> keyValue "to" moduleName


sortType :: Dhall.Type a -> Dhall.Type a
sortType t =
  t { Dhall.expected = sortExpr ( Dhall.expected t ) }
