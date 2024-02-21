{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Images where

import Import
import Database.Persist.Sql (rawSql, toSqlKey)
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)

-- Define our data that will be used for creating the form.
data FileForm = FileForm
    { fileInfo :: FileInfo
    , fileDescription :: Text
    }

getImagesR :: Handler Value
getImagesR = do
    objectsValueMaybe <- lookupGetParam "objects"
    images <- selectImages objectsValueMaybe 
    returnJson (map entityVal images)

getImagesByIdR :: Int64 -> Handler Value
getImagesByIdR imageId = do
    images <- selectImagesById imageId
    returnJson (map entityVal images)

getImagesAddR :: Handler Html
getImagesAddR = do
    (formWidget, formEnctype) <- generateFormPost imageForm
    let submission = Nothing :: Maybe FileForm

    defaultLayout $ do
        setTitle "Posting An Image"
        $(widgetFile "images-post")  

postImagesAddR :: Handler Html
postImagesAddR = do 
    ((result, formWidget), formEnctype) <- runFormPost imageForm
    let submission = case result of
            FormSuccess res -> Just res
            _ -> Nothing
    defaultLayout $ do
        setTitle "Posting An Image"
        $(widgetFile "images-post")        

stripChars :: Char -> String -> String
stripChars toBeStripped string = filter (\character -> character /= toBeStripped) string

escapeLikeString :: Text -> Text
escapeLikeString stringToBeEscaped =
    let strings = ["%", (stripChars '"' (unpack stringToBeEscaped)), "%"] in
    pack (concat strings)

selectImages :: Maybe Text -> Handler [Entity Image]
selectImages (Just objects) = 
    let escapedObject = escapeLikeString objects in
        runDB $ rawSql s [toPersistValue escapedObject]
        where s = "SELECT ?? FROM image WHERE object LIKE ?"
selectImages Nothing = runDB $ selectList [] []

selectImagesById :: Int64 -> Handler [Entity Image]
selectImagesById imageId =
    runDB $ selectList [ImageId ==. (toSqlKey imageId)] []

imageForm :: Form FileForm
imageForm = renderBootstrap3 BootstrapBasicForm $ FileForm
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
                , ("placeholder", "Image tags")
                ]
            }

