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
        setTitle "Get Image Handler Title"
        $(widgetFile "images-get")

postImagesR :: Handler Html
postImagesR =
   do
      defaultLayout $ do
         setTitle "Post Images Handler Title"
         $(widgetFile "images-post")