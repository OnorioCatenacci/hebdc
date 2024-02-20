{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Images where

import Import
import Database.Persist.Sql (rawSql, toSqlKey)

getImagesR :: Handler Value
getImagesR = do
    objectsValueMaybe <- lookupGetParam "objects"
    images <- selectImages objectsValueMaybe 
    returnJson (map entityVal images)

getImagesByIdR :: Int64 -> Handler Value
getImagesByIdR imageId = do
    images <- selectImagesById imageId
    returnJson (map entityVal images)

postImagesR :: Handler Value
postImagesR =
   do
      return $ object
        [ "name" .= name
        , "age" .= age
        ]
  where
    name = "Michael" :: Text
    age = 28 :: Int

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

selectImagesById :: Int64 -> Handler [Entity Image]
selectImagesById imageId =
    runDB $ selectList [ImageId ==. (toSqlKey imageId)] []
