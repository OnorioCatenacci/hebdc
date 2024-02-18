{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Images where

import Import

getImagesR :: Handler Html
getImagesR =
   do
      defaultLayout $ do
--        pageTitle <- "Get Image Handler"
        setTitle "Get Image Handler"
        $(widgetFile "images-get")

postImagesR :: Handler Html
postImagesR =
   do
      defaultLayout $ do
--         pageTitle <- "Post Image Handler"
         setTitle "Post Images Handler"
         $(widgetFile "images-get")