I've used Yesod to complete as much of the HEB Digital Challenge as I can.  A few notes:

1. In my code I created a quick shell script (s.sh) to make starting the server on localhost much quicker

2. I've been using Postman to test the API. 

3. There were a few things I wanted to do but couldn't quite figure out:
   
	* I wanted to modify the API to guard against the possibility that someone might submit a 0 (or negative) object id.  The Int64 type to which the object id is being bound, of course, doesn't reject 0 or negative numbers.  I couldn't quite figure out how to unify the two sides of the pattern match. One side would use Yesod's sendResponseStatus; the other side would return JSON.  As I say I couldn't quite figure out a common type to use for both types of returns.

	* For some reason that I find very puzzling, the JSON does not include the id field of the table. I would guess this is something to do with the entityVal function but I cannot seem to figure out how to get it to display the record's primary key

	*  I would normally model tags on an image as a 1::N relationship; that is 1 image would have 0, 1 or more tags.  And normally when I model data like that I'll create a second table with a foreign key relationship to the first.  The first would contain the image id and the second would have the image id as an FK and the tags associated with it.  Due to the time constraint I simply skipped that.

	* One point of interest: when specifying a query string for objects, if I call the API with quotation (") marks around the value I want to find in the objects list it doesn't work correctly. This is due to me needing to use the LIKE operator.  LIKE %"a,b,c"% is not the same to SQL as LIKE %a,b,c%.  Hence to conform to the API spec but allow for the fact that the quotes would cause issues, I simply stripped them from the query string if they're present.

	* I haven't added unit tests.  This is a major omission but honestly I wanted to try to get as much of the functionality of the API done as possible.
	