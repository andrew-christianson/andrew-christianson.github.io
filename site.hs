--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Hakyll
import Text.Pandoc

import           System.Process   (system)
import           Data.List        (isPrefixOf, isSuffixOf)
import           System.FilePath  (isAbsolute, normalise, takeFileName)

--------------------------------------------------------------------------------
cfg :: Configuration
cfg = Configuration {
  destinationDirectory = "_site"
  , storeDirectory       = "_cache"
  , tmpDirectory         = "_cache/tmp"
  , providerDirectory    = "."
  , ignoreFile           = ignoreFile'
  , deployCommand        = "aws s3 sync _site s3://blog.andrew.directory"
  , deploySite           = system . deployCommand
  , inMemoryCache        = True
  , previewHost          = "127.0.0.1"
  , previewPort          = 8000
  } where
  ignoreFile' path
    | "."    `isPrefixOf` fileName = True
    | "#"    `isPrefixOf` fileName = True
    | "~"    `isSuffixOf` fileName = True
    | ".swp" `isSuffixOf` fileName = True
    | otherwise                    = False
    where
      fileName = takeFileName path
main :: IO ()
main = hakyllWith cfg $ do
    match "static/*/*" $ do
      route idRoute
      compile copyFileCompiler

    match "assets/*" $ do
      route idRoute
      compile copyFileCompiler

    match "images/*" $ do
      route idRoute
      compile copyFileCompiler

    match "css/*" $ do
      route idRoute
      compile copyFileCompiler

    match (fromList ["about.md", "contact.markdown", "about.rst"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/page.html" siteCtx
            >>= loadAndApplyTemplate "templates/default.html" siteCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    siteCtx

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    siteCtx 

siteCtx :: Context String
siteCtx = 
    constField "site_description" "Uninformed Prior" `mappend`
    constField "site_title" "Uninformed Prior" `mappend`
    constField "instagram_username" "drewkristjansson" `mappend`
    constField "twitter_username" "drewkristjanson" `mappend`
    constField "github_username" "andrew-christianson" `mappend`
    constField "google_username" "kristjansson" `mappend`
    defaultContext
