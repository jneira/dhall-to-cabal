    let prelude =
          https://raw.githubusercontent.com/eta-lang/dhall-to-etlas/1.0.0/dhall/prelude.dhall 

in  let types =
          https://raw.githubusercontent.com/eta-lang/dhall-to-etlas/1.0.0/dhall/types.dhall 

in  { author =
        ""
    , benchmarks =
        [] : List
             { benchmark : types.ConfigOptions → types.Benchmark, name : Text }
    , bug-reports =
        "https://github.com/eta-lang/dhall-to-etlas/issues"
    , build-type =
        [ prelude.types.BuildTypes.Simple {=} ] : Optional types.BuildType
    , cabal-version =
        prelude.v "1.10"
    , category =
        "Distribution"
    , copyright =
        ""
    , custom-setup =
        [] : Optional types.CustomSetup
    , data-dir =
        ""
    , data-files =
        [] : List Text
    , description =
        ''
        dhall-to-etlas takes Dhall expressions and compiles them into Etlas
        files. All of the features of Dhall are supported, such as let
        bindings and imports, and all features of Etlas are supported
        (including conditional stanzas).
        ''
    , executables =
        [ { executable =
                λ(config : types.ConfigOptions)
              → { autogen-modules =
                    [] : List Text
                , build-depends =
                    [ { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.3.0.0"))
                          (prelude.earlierVersion (prelude.v "1.4"))
                      , package =
                          "etlas-cabal"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "4.5"))
                          (prelude.earlierVersion (prelude.v "5"))
                      , package =
                          "base"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.12.0"))
                          (prelude.earlierVersion (prelude.v "1.13"))
                      , package =
                          "dhall"
                      }
                    , { bounds =
                          prelude.anyVersion
                      , package =
                          "dhall-to-etlas"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "0.13.2"))
                          (prelude.earlierVersion (prelude.v "0.15"))
                      , package =
                          "optparse-applicative"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.2.0.1"))
                          (prelude.earlierVersion (prelude.v "1.3"))
                      , package =
                          "prettyprinter"
                      }
                    , { bounds =
                          prelude.withinVersion (prelude.v "1.2")
                      , package =
                          "text"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "0.2.0.0"))
                          (prelude.earlierVersion (prelude.v "0.6"))
                      , package =
                          "transformers"
                      }
                    ]
                , build-tool-depends =
                    [] : List
                         { component :
                             Text
                         , package :
                             Text
                         , version :
                             types.VersionRange
                         }
                , build-tools =
                    [] : List { exe : Text, version : types.VersionRange }
                , buildable =
                    True
                , c-sources =
                    [] : List Text
                , cc-options =
                    [] : List Text
                , compiler-options =
                    prelude.defaults.CompilerOptions
                , cpp-options =
                    [] : List Text
                , default-extensions =
                    [] : List types.Extension
                , default-language =
                    [ < Haskell2010 =
                          {=}
                      | UnknownLanguage :
                          { _1 : Text }
                      | Haskell98 :
                          {}
                      >
                    ] : Optional types.Language
                , extra-framework-dirs =
                    [] : List Text
                , extra-ghci-libraries =
                    [] : List Text
                , extra-lib-dirs =
                    [] : List Text
                , frameworks =
                    [] : List Text
                , hs-source-dirs =
                    [ "exe" ]
                , include-dirs =
                    [] : List Text
                , includes =
                    [] : List Text
                , install-includes =
                    [] : List Text
                , java-sources =
                    [] : List Text
                , js-sources =
                    [] : List Text
                , ld-options =
                    [] : List Text
                , main-is =
                    "Main.hs"
                , maven-depends =
                    [] : List Text
                , mixins =
                    [] : List types.Mixin
                , other-extensions =
                    [ prelude.types.Extensions.NamedFieldPuns True ]
                , other-languages =
                    [] : List types.Language
                , other-modules =
                    [] : List Text
                , pkgconfig-depends =
                    [] : List { name : Text, version : types.VersionRange }
                , profiling-options =
                    prelude.defaults.CompilerOptions
                , shared-options =
                    prelude.defaults.CompilerOptions
                }
          , name =
              "dhall-to-etlas"
          }
        , { executable =
                λ(config : types.ConfigOptions)
              → { autogen-modules =
                    [] : List Text
                , build-depends =
                    [ { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.3.0.0"))
                          (prelude.earlierVersion (prelude.v "1.4"))
                      , package =
                          "etlas-cabal"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "4.5"))
                          (prelude.earlierVersion (prelude.v "5"))
                      , package =
                          "base"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.12.0"))
                          (prelude.earlierVersion (prelude.v "1.13"))
                      , package =
                          "dhall"
                      }
                    , { bounds =
                          prelude.anyVersion
                      , package =
                          "dhall-to-etlas"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "0.13.2"))
                          (prelude.earlierVersion (prelude.v "0.15"))
                      , package =
                          "optparse-applicative"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.2.0.1"))
                          (prelude.earlierVersion (prelude.v "1.3"))
                      , package =
                          "prettyprinter"
                      }
                    , { bounds =
                          prelude.withinVersion (prelude.v "1.2")
                      , package =
                          "text"
                      }
                    , { bounds =
                          prelude.withinVersion (prelude.v "1.4")
                      , package =
                          "contravariant"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "1.2.6.1"))
                          (prelude.earlierVersion (prelude.v "1.3"))
                      , package =
                          "hashable"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (prelude.v "0.2.1.0"))
                          (prelude.earlierVersion (prelude.v "0.3"))
                      , package =
                          "insert-ordered-containers"
                      }
                    ]
                , build-tool-depends =
                    [] : List
                         { component :
                             Text
                         , package :
                             Text
                         , version :
                             types.VersionRange
                         }
                , build-tools =
                    [] : List { exe : Text, version : types.VersionRange }
                , buildable =
                    True
                , c-sources =
                    [] : List Text
                , cc-options =
                    [] : List Text
                , compiler-options =
                    prelude.defaults.CompilerOptions
                , cpp-options =
                    [] : List Text
                , default-extensions =
                    [] : List types.Extension
                , default-language =
                    [ < Haskell2010 =
                          {=}
                      | UnknownLanguage :
                          { _1 : Text }
                      | Haskell98 :
                          {}
                      >
                    ] : Optional types.Language
                , extra-framework-dirs =
                    [] : List Text
                , extra-ghci-libraries =
                    [] : List Text
                , extra-lib-dirs =
                    [] : List Text
                , frameworks =
                    [] : List Text
                , hs-source-dirs =
                    [ "cabal-to-dhall" ]
                , include-dirs =
                    [] : List Text
                , includes =
                    [] : List Text
                , install-includes =
                    [] : List Text
                , java-sources =
                    [] : List Text
                , js-sources =
                    [] : List Text
                , ld-options =
                    [] : List Text
                , main-is =
                    "Main.hs"
                , maven-depends =
                    [] : List Text
                , mixins =
                    [] : List types.Mixin
                , other-extensions =
                    [ prelude.types.Extensions.NamedFieldPuns True ]
                , other-languages =
                    [] : List types.Language
                , other-modules =
                    [] : List Text
                , pkgconfig-depends =
                    [] : List { name : Text, version : types.VersionRange }
                , profiling-options =
                    prelude.defaults.CompilerOptions
                , shared-options =
                    prelude.defaults.CompilerOptions
                }
          , name =
              "etlas-to-dhall"
          }
        ]
    , extra-doc-files =
        [] : List Text
    , extra-source-files =
        [ "Changelog.md"
        , "dhall/defaults/BuildInfo.dhall"
        , "dhall/defaults/Library.dhall"
        , "dhall/defaults/CompilerOptions.dhall"
        , "dhall/defaults/SourceRepo.dhall"
        , "dhall/defaults/TestSuite.dhall"
        , "dhall/defaults/Executable.dhall"
        , "dhall/defaults/Package.dhall"
        , "dhall/defaults/Benchmark.dhall"
        , "dhall/unconditional.dhall"
        , "dhall/GitHub-project.dhall"
        , "dhall/prelude.dhall"
        , "dhall/types/VersionRange.dhall"
        , "dhall/types/OS.dhall"
        , "dhall/types/Guarded.dhall"
        , "dhall/types/License.dhall"
        , "dhall/types/Library.dhall"
        , "dhall/types/Version.dhall"
        , "dhall/types/Language.dhall"
        , "dhall/types/Extension.dhall"
        , "dhall/types/CompilerOptions.dhall"
        , "dhall/types/SourceRepo.dhall"
        , "dhall/types/TestSuite.dhall"
        , "dhall/types/Executable.dhall"
        , "dhall/types/Dependency.dhall"
        , "dhall/types/Mixin.dhall"
        , "dhall/types/Compiler.dhall"
        , "dhall/types/Config.dhall"
        , "dhall/types/Package.dhall"
        , "dhall/types/builtin.dhall"
        , "dhall/types/BuildType.dhall"
        , "dhall/types/RepoKind.dhall"
        , "dhall/types/Version/v.dhall"
        , "dhall/types/Arch.dhall"
        , "dhall/types/Scope.dhall"
        , "dhall/types/CustomSetup.dhall"
        , "dhall/types/Benchmark.dhall"
        , "dhall/types/Flag.dhall"
        , "dhall/types/ForeignLibrary.dhall"
        , "dhall/types/ModuleRenaming.dhall"
        , "dhall/types/RepoType.dhall"
        , "dhall/types/TestType.dhall"
        , "dhall/types/VersionRange/IntersectVersionRanges.dhall"
        , "dhall/types/VersionRange/WithinVersion.dhall"
        , "dhall/types/VersionRange/InvertVersionRange.dhall"
        , "dhall/types/VersionRange/EarlierVersion.dhall"
        , "dhall/types/VersionRange/DifferenceVersionRanges.dhall"
        , "dhall/types/VersionRange/ThisVersion.dhall"
        , "dhall/types/VersionRange/OrLaterVersion.dhall"
        , "dhall/types/VersionRange/OrEarlierVersion.dhall"
        , "dhall/types/VersionRange/AnyVersion.dhall"
        , "dhall/types/VersionRange/NotThisVersion.dhall"
        , "dhall/types/VersionRange/LaterVersion.dhall"
        , "dhall/types/VersionRange/NoVersion.dhall"
        , "dhall/types/VersionRange/MajorBoundVersion.dhall"
        , "dhall/types/VersionRange/UnionVersionRanges.dhall"
        , "dhall/types/SetupBuildInfo.dhall"
        ]
    , extra-tmp-files =
        [] : List Text
    , flags =
        [] : List
             { default : Bool, description : Text, manual : Bool, name : Text }
    , foreign-libraries =
        [] : List
             { foreign-lib :
                 types.ConfigOptions → types.ForeignLibrary
             , name :
                 Text
             }
    , homepage =
        "https://github.com/eta-lang/dhall-to-etlas"
    , library =
        [   λ(config : types.ConfigOptions)
          → { autogen-modules =
                [] : List Text
            , build-depends =
                [ { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "1.3.0.0"))
                      (prelude.earlierVersion (prelude.v "1.4"))
                  , package =
                      "etlas-cabal"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "4.5"))
                      (prelude.earlierVersion (prelude.v "5"))
                  , package =
                      "base"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "0.10"))
                      (prelude.earlierVersion (prelude.v "1"))
                  , package =
                      "bytestring"
                  }
                , { bounds =
                      prelude.withinVersion (prelude.v "0.5")
                  , package =
                      "containers"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "1.12.0"))
                      (prelude.earlierVersion (prelude.v "1.13"))
                  , package =
                      "dhall"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "6.3.1"))
                      (prelude.earlierVersion (prelude.v "6.4"))
                  , package =
                      "formatting"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "1.2.6.1"))
                      (prelude.earlierVersion (prelude.v "1.3"))
                  , package =
                      "hashable"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "0.2.1.0"))
                      (prelude.earlierVersion (prelude.v "0.3"))
                  , package =
                      "insert-ordered-containers"
                  }
                , { bounds =
                      prelude.withinVersion (prelude.v "1.2")
                  , package =
                      "text"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "0.2.0.0"))
                      (prelude.earlierVersion (prelude.v "0.6"))
                  , package =
                      "transformers"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "6.1.1"))
                      (prelude.earlierVersion (prelude.v "6.5"))
                  , package =
                      "megaparsec"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (prelude.v "0.11.0.0"))
                      (prelude.earlierVersion (prelude.v "0.13"))
                  , package =
                      "vector"
                  }
                ]
            , build-tool-depends =
                [] : List
                     { component :
                         Text
                     , package :
                         Text
                     , version :
                         types.VersionRange
                     }
            , build-tools =
                [] : List { exe : Text, version : types.VersionRange }
            , buildable =
                True
            , c-sources =
                [] : List Text
            , cc-options =
                [] : List Text
            , compiler-options =
                  prelude.defaults.compiler-options
                ⫽ { GHC = [ "-Wall" ] : List Text }
            , cpp-options =
                [] : List Text
            , default-extensions =
                [] : List types.Extension
            , default-language =
                [ < Haskell2010 =
                      {=}
                  | UnknownLanguage :
                      { _1 : Text }
                  | Haskell98 :
                      {}
                  >
                ] : Optional types.Language
            , exposed-modules =
                [ "DhallToCabal" ]
            , extra-framework-dirs =
                [] : List Text
            , extra-ghci-libraries =
                [] : List Text
            , extra-lib-dirs =
                [] : List Text
            , frameworks =
                [] : List Text
            , hs-source-dirs =
                [ "lib" ]
            , include-dirs =
                [] : List Text
            , includes =
                [] : List Text
            , install-includes =
                [] : List Text
            , java-sources =
                [] : List Text
            , js-sources =
                [] : List Text
            , ld-options =
                [] : List Text
            , maven-depends =
                [] : List Text
            , mixins =
                [] : List types.Mixin
            , other-extensions =
                [ prelude.types.Extensions.GADTs True
                , prelude.types.Extensions.GeneralizedNewtypeDeriving True
                , prelude.types.Extensions.LambdaCase True
                , prelude.types.Extensions.OverloadedStrings True
                , prelude.types.Extensions.RecordWildCards True
                ]
            , other-languages =
                [] : List types.Language
            , other-modules =
                [ "DhallToCabal.ConfigTree"
                , "DhallToCabal.Diff"
                , "Dhall.Extra"
                ]
            , pkgconfig-depends =
                [] : List { name : Text, version : types.VersionRange }
            , profiling-options =
                prelude.defaults.CompilerOptions
            , reexported-modules =
                [] : List
                     { name :
                         Text
                     , original :
                         { name : Text, package : Optional Text }
                     }
            , shared-options =
                prelude.defaults.CompilerOptions
            , signatures =
                [] : List Text
            }
        ] : Optional (types.ConfigOptions → types.Library)
    , license =
        < MIT =
            {=}
        | GPL :
            Optional types.Version
        | AGPL :
            Optional types.Version
        | LGPL :
            Optional types.Version
        | BSD2 :
            {}
        | BSD3 :
            {}
        | BSD4 :
            {}
        | ISC :
            {}
        | MPL :
            types.Version
        | Apache :
            Optional types.Version
        | PublicDomain :
            {}
        | AllRightsReserved :
            {}
        | Unspecified :
            {}
        | Other :
            {}
        >
    , license-files =
        [ "LICENSE" ]
    , maintainer =
        "atreyu.bbb@gmail.com"
    , name =
        "dhall-to-etlas"
    , package-url =
        ""
    , source-repos =
        [ { branch =
              [] : Optional Text
          , kind =
              < RepoHead =
                  {=}
              | RepoThis :
                  {}
              | RepoKindUnknown :
                  { _1 : Text }
              >
          , location =
              [ "https://github.com/eta-lang/dhall-to-etlas" ] : Optional Text
          , module =
              [] : Optional Text
          , subdir =
              [] : Optional Text
          , tag =
              [] : Optional Text
          , type =
              [ < Git =
                    {=}
                | Darcs :
                    {}
                | SVN :
                    {}
                | CVS :
                    {}
                | Mercurial :
                    {}
                | GnuArch :
                    {}
                | Monotone :
                    {}
                | OtherRepoType :
                    { _1 : Text }
                | Bazaar :
                    {}
                >
              ] : Optional types.RepoType
          }
        ]
    , stability =
        ""
    , sub-libraries =
        [] : List { library : types.ConfigOptions → types.Library, name : Text }
    , synopsis =
        "Compile Dhall expressions to Etlas files"
    , test-suites =
        [] : List
             { name : Text, test-suite : types.ConfigOptions → types.TestSuite }
    , tested-with =
        [] : List { compiler : types.Compiler, version : types.VersionRange }
    , version =
        prelude.v "1.0.0"
    , x-fields =
        [] : List { _1 : Text, _2 : Text }
    }
