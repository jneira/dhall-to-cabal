   let prelude = ./dhall/prelude.dhall

in let types = ./dhall/types.dhall

in let v = prelude.v

in let defaultLang =
       [ prelude.types.Languages.Haskell2010 {=} ] : Optional types.Language

in let pkg =
       \ (name : Text) -> \ (version-range : types.VersionRange)
    -> { bounds = version-range, package = name }

in let pkgAnyVer =
       \ (packageName : Text)
    -> pkg packageName prelude.anyVersion

in let commonDeps =
       [ pkg       "base"
           ( prelude.intersectVersionRanges
              ( prelude.orLaterVersion ( v "4.8" ) )
              ( prelude.earlierVersion ( v "4.9" ) ) ) 
       , pkgAnyVer "wai"
       , pkg       "wai-servlet"
           ( prelude.orLaterVersion ( v "0.1.5" ) )
       ]

in let RepoKind = constructors types.RepoKind

in let GitHub-project = prelude.utils.GitHubWithSourceRepo-project
                        (   prelude.defaults.SourceRepo
                         // { tag = ["0.1.2.0"] : Optional Text
                            , kind = RepoKind.RepoThis {=}
                            }
                         )
                         { owner = "jneira"
                         , repo = "wai-servlet-handler-jetty"
                         }
in  GitHub-project
 // { description =
        "Wai handler to run wai applications in a embedded jetty server"
    , license =
         prelude.types.Licenses.BSD3 {=}
    , license-files =
        [ "LICENSE" ]
    , author =
        "Javier Neira Sanchez"
    , maintainer =
        "Javier Neira Sanchez <atreyu.bbb@gmail.com>"
    , version =
        v "0.1.2.0"
    , cabal-version =
        v "1.12"
    , category =
        "Web"
    , extra-source-files =
        [ "README.md" ]
    , stability =
        "Experimental"
    , library =
        prelude.unconditional.library
          (   prelude.defaults.Library
           // { exposed-modules =
                  [ "Network.Wai.Servlet.Handler.Jetty" ]
              , hs-source-dirs =
                  [ "src" ]
              , default-language =
                  defaultLang
              , build-depends =
                  commonDeps
              , maven-depends =
                  [ "javax.servlet:javax.servlet-api:3.1.0"
                  , "org.eclipse.jetty:jetty-server:9.4.5.v20170502"
                  ]
              }
          )
    , executables =
        [ prelude.unconditional.executable
          "wai-servlet-jetty-example"
          (   prelude.defaults.Executable
           // {  build-depends =
                 commonDeps
               # [ pkgAnyVer "wai-servlet-handler-jetty" ]
              , hs-source-dirs =
                  [ "examples" ]
              , main-is =
                  "Main.hs"
              , default-language =
                  defaultLang
              }
          )
        ] 
    }
 
