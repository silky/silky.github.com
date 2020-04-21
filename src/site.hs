--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Control.Applicative
import qualified Data.Set as S
import           Text.Pandoc.Options
import           Control.Monad
import           Hakyll.Web.Diagrams (pandocCompilerDiagrams)
--------------------------------------------------------------------------------

pandocMathCompiler =
    let mathExtensions = [Ext_tex_math_dollars, Ext_latex_macros,
                         Ext_backtick_code_blocks]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions = foldr S.insert defaultExtensions mathExtensions
        writerOptions = defaultHakyllWriterOptions {
                          writerExtensions = newExtensions,
                          writerHTMLMathMethod = MathJax ""
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions


main :: IO ()
main = hakyll $ do
    match "images/**/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "files/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "books/*" $ do
      route $ setExtension "html"
      compile $ pandocMathCompiler
        >>= loadAndApplyTemplate "templates/book.html" defaultContext
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls
          
    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocMathCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "talks/*" $ do
        route $ setExtension "html"
        compile $ 
                (pandocCompilerDiagrams "images/diagrams" <|> pandocMathCompiler)
            >>= loadAndApplyTemplate "templates/talk.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ 
                (pandocCompilerDiagrams "images/diagrams" <|> pandocMathCompiler)
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["talks.html"] $ do
        route idRoute
        compile $ do
            talks <- recentFirst =<< loadAll "talks/*"
            let archiveCtx =
                    listField "talks" postCtx (return talks) `mappend`
                    constField "title" "Talks"               `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/talks.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match (fromList ["links.html", "about.html", "library.html"]) $ do
        route idRoute
        compile $ do
            let linksCtx = defaultContext

            getResourceBody
                >>= applyAsTemplate linksCtx
                >>= loadAndApplyTemplate "templates/default.html" linksCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- (liftM (take 10)) $ recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<<
                loadAllSnapshots "posts/*" "content"
            renderAtom feedConf feedCtx posts


feedConf :: FeedConfiguration
feedConf = FeedConfiguration
    { feedTitle         = "silky.github.io"
    , feedDescription   = "Website of Noon van der Silk"
    , feedAuthorName    = "Noon van der Silk"
    , feedAuthorEmail   = "noonsilk+-noonsilk@gmail.com"
    , feedRoot          = "https://silky.github.io"
    }


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext
