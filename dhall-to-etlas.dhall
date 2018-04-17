    let prelude =
          https://raw.githubusercontent.com/eta-lang/dhall-to-etlas/1.0.0/dhall/prelude.dhall 

in  let types =
          https://raw.githubusercontent.com/eta-lang/dhall-to-etlas/1.0.0/dhall/types.dhall 

in let v = prelude.v

in let pkg =
       \(name : Text)
    -> \(version-range : types.VersionRange)
    -> { bounds = version-range, package = name }

in let pkgVer =
         \(packageName : Text) -> \(minor : Text) -> \(major : Text)
      -> package packageName
         prelude.intersectVersionRanges
            (prelude.orLaterVersion (v minor))
            (prelude.earlierVersion (v major))

in let deps =
         { etlas-cabal    = pkgVer "etlas-cabal"
		   				  		   "1.3.0.0" "1.4"
         , base           = pkgVer "base"
		   				  		   "4.5"     "5"
         , dhall          = pkgVer "dhall"
		   				  		   "1.12.0"  "1.13"
         , dhall-to-etlas = pkg    "dhall-to-etlas"
		   				  		   prelude.anyVersion
		 , optparse       = pkgVer "optparse-applicative"
		   				  		   "0.13.2"  "0.15"
		 , prettyprinter  = pkgVer "prettyprinter"
		   				  		   "1.3"     "1.2.0.1" 
		 , text			  = pkg	   "text"
		   				  		   prelude.withinVersion (v "1.2")
		 , contravariant  = pkg	   "contravariant"
		   				  		   prelude.withinVersion (v "1.4")
		 , hashable		  = pkgVer "hashable"
		   				  		   "1.2.6.1" "1.3"
		 , insert-ordered-containers =
					        pkgVer "insert-ordered-containers"
								   "0.2.1.0" "0.3"
		 }

in  { bug-reports =
        "https://github.com/eta-lang/dhall-to-etlas/issues"
    , build-type =
        [ prelude.types.BuildTypes.Simple {=} ] : Optional types.BuildType
    , cabal-version =
        v "1.10"
    , category =
        "Distribution"
    , description =
        ''
        dhall-to-etlas takes Dhall expressions and compiles them into Etlas
        files. All of the features of Dhall are supported, such as let
        bindings and imports, and all features of Etlas are supported
        (including conditional stanzas).
        ''
    , executables =
        [ { executable =
                \(config : types.ConfigOptions)
             -> { build-depends =
                    [ { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.3.0.0"))
                          (prelude.earlierVersion (v "1.4"))
                      , package =
                          "etlas-cabal"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "4.5"))
                          (prelude.earlierVersion (v "5"))
                      , package =
                          "base"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.12.0"))
                          (prelude.earlierVersion (v "1.13"))
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
                          (prelude.orLaterVersion (v "0.13.2"))
                          (prelude.earlierVersion (v "0.15"))
                      , package =
                          "optparse-applicative"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.2.0.1"))
                          (prelude.earlierVersion (v "1.3"))
                      , package =
                          "prettyprinter"
                      }
                    , { bounds =
                          prelude.withinVersion (v "1.2")
                      , package =
                          "text"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "0.2.0.0"))
                          (prelude.earlierVersion (v "0.6"))
                      , package =
                          "transformers"
                      }
                    ]
                , default-language =
                    [ Haskell2010 {=} ] : Optional types.Language
                , main-is =
                    "Main.hs"
                , other-extensions =
                    [ prelude.types.Extensions.NamedFieldPuns True ]
                }
          , name =
              "dhall-to-etlas"
          }
        , { executable =
                \(config : types.ConfigOptions)
             -> { build-depends =
                    [ { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.3.0.0"))
                          (prelude.earlierVersion (v "1.4"))
                      , package =
                          "etlas-cabal"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "4.5"))
                          (prelude.earlierVersion (v "5"))
                      , package =
                          "base"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.12.0"))
                          (prelude.earlierVersion (v "1.13"))
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
                          (prelude.orLaterVersion (v "0.13.2"))
                          (prelude.earlierVersion (v "0.15"))
                      , package =
                          "optparse-applicative"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.2.0.1"))
                          (prelude.earlierVersion (v "1.3"))
                      , package =
                          "prettyprinter"
                      }
                    , { bounds =
                          prelude.withinVersion (v "1.2")
                      , package =
                          "text"
                      }
                    , { bounds =
                          prelude.withinVersion (v "1.4")
                      , package =
                          "contravariant"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "1.2.6.1"))
                          (prelude.earlierVersion (v "1.3"))
                      , package =
                          "hashable"
                      }
                    , { bounds =
                          prelude.intersectVersionRanges
                          (prelude.orLaterVersion (v "0.2.1.0"))
                          (prelude.earlierVersion (v "0.3"))
                      , package =
                          "insert-ordered-containers"
                      }
                    ]
                , default-language =
                    [ Haskell2010 {=} ] : Optional types.Language
                , main-is =
                    "Main.hs"
                }
          , name =
              "etlas-to-dhall"
          }
        ]
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
    , homepage =
        "https://github.com/eta-lang/dhall-to-etlas"
    , library =
        [   \(config : types.ConfigOptions)
         -> { build-depends =
                [ { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "1.3.0.0"))
                      (prelude.earlierVersion (v "1.4"))
                  , package =
                      "etlas-cabal"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "4.5"))
                      (prelude.earlierVersion (v "5"))
                  , package =
                      "base"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "0.10"))
                      (prelude.earlierVersion (v "1"))
                  , package =
                      "bytestring"
                  }
                , { bounds =
                      prelude.withinVersion (v "0.5")
                  , package =
                      "containers"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "1.12.0"))
                      (prelude.earlierVersion (v "1.13"))
                  , package =
                      "dhall"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "6.3.1"))
                      (prelude.earlierVersion (v "6.4"))
                  , package =
                      "formatting"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "1.2.6.1"))
                      (prelude.earlierVersion (v "1.3"))
                  , package =
                      "hashable"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "0.2.1.0"))
                      (prelude.earlierVersion (v "0.3"))
                  , package =
                      "insert-ordered-containers"
                  }
                , { bounds =
                      prelude.withinVersion (v "1.2")
                  , package =
                      "text"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "0.2.0.0"))
                      (prelude.earlierVersion (v "0.6"))
                  , package =
                      "transformers"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "6.1.1"))
                      (prelude.earlierVersion (v "6.5"))
                  , package =
                      "megaparsec"
                  }
                , { bounds =
                      prelude.intersectVersionRanges
                      (prelude.orLaterVersion (v "0.11.0.0"))
                      (prelude.earlierVersion (v "0.13"))
                  , package =
                      "vector"
                  }
                ]
            , compiler-options =
                  prelude.defaults.compiler-options
                ⫽ { GHC = [ "-Wall" ] : List Text }
            , cpp-options =
                [] : List Text
            , default-extensions =
                [] : List types.Extension
            , default-language =
                [ Haskell2010 {=} ] : Optional types.Language
            , exposed-modules =
                [ "DhallToCabal" ]
            , hs-source-dirs =
                [ "lib" ]
            , other-extensions =
                [ prelude.types.Extensions.GADTs True
                , prelude.types.Extensions.GeneralizedNewtypeDeriving True
                , prelude.types.Extensions.LambdaCase True
                , prelude.types.Extensions.OverloadedStrings True
                , prelude.types.Extensions.RecordWildCards True
                ]
            , other-modules =
                [ "DhallToCabal.ConfigTree"
                , "DhallToCabal.Diff"
                , "Dhall.Extra"
                ]
            }
        ] : Optional (types.ConfigOptions → types.Library)
    , license = MIT = {=}
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
    , synopsis =
        "Compile Dhall expressions to Etlas files"
    , version =
        v "1.0.0"
    }
