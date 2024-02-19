{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Images where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
--import Text.Julius (RawJS (..))

-- Define our data that will be used for creating an "add image" form.
data AddImageForm = AddImageForm
    { imageFile :: FileInfo
    , imageDescription :: Text
    }


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

getImagesAddR :: Handler Html
getImagesAddR =
      do
      (formWidget, formEnctype) <- generateFormPost addImageForm
      let submission = Nothing :: Maybe AddImageForm

      defaultLayout $ do
        setTitle "Add New Image"
        $(widgetFile "images-add")

postImagesAddR :: Handler Html
postImagesAddR =
   do
      defaultLayout $ do
         setTitle "Post Images Handler Title"
         $(widgetFile "images-post")

addImageForm :: Form AddImageForm
addImageForm = renderBootstrap3 BootstrapBasicForm $ AddImageForm
    <$> fileAFormReq "Choose an image"
    <*> areq textField textSettings Nothing
    -- Add attributes like the placeholder and CSS classes.
    where textSettings = FieldSettings
            { fsLabel = "What's in the image?"
            , fsTooltip = Nothing
            , fsId = Nothing
            , fsName = Nothing
            , fsAttrs =
                [ ("class", "form-control")
                , ("placeholder", "Objects in image")
                ]
            }         

getAllImages :: DB [Entity Image]
getAllImages = selectList [] [Asc ImageId]