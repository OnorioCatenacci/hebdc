{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Images where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
--import Text.Julius (RawJS (..))

-- Define our data that will be used for creating an "add image" form.
data AddImageForm = AddImageForm
    { imageFile :: FileInfo
    , imageDescription :: Text
    }


getImagesR :: Handler Value
getImagesR = do
    objectsValueMaybe <- lookupGetParam "objects"
    let objectsForQuery = fromMaybe "*" objectsValueMaybe
    images <- runDB $ getAllImages 
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

-- like :: String -> String -> Filter
-- like field val = Filter field (Left $ Data.Text.concat ["%", val "%"]) (BackendSpecificFilter "like")

createFilter :: String -> String
createFilter filterExpression = "%" ++ filterExpression ++ "%"

getAllImages :: DB [Entity Image]
getAllImages = selectList [Filter object (createFilter "turbine") (BackendSpecificFilter "LIKE")] [Asc ImageId]