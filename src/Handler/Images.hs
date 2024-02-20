{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Images where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Database.Persist.Sql (rawSql)
--import Text.Julius (RawJS (..))

-- Define our data that will be used for creating an "add image" form.
data AddImageForm = AddImageForm
    { imageFile :: FileInfo
    , imageDescription :: Text
    }


getImagesR :: Handler Value
getImagesR = do
    objectsValueMaybe <- lookupGetParam "objects"
    images <- selectImages objectsValueMaybe 
    returnJson (map entityVal images)

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

stripChars :: String -> String -> String
stripChars = filter . flip notElem

escapeLikeString :: Text -> Text
escapeLikeString stringToBeEscaped =
    let strings = ["%", (stripChars "\"" (unpack stringToBeEscaped)), "%"] in
    pack (concat strings)

selectImages :: Maybe Text -> Handler [Entity Image]
selectImages (Just objects) = 
    let escapedObject = escapeLikeString objects in
        runDB $ rawSql s [toPersistValue escapedObject]
        where s = "SELECT ?? FROM image WHERE object LIKE ?"
selectImages Nothing = runDB $ selectList [] []
