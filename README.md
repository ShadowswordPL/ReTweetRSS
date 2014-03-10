Windows Phone application that supports Twitter account management. Program downloads some news from selected RSS feeds, then share it with quotation of article fragment or randomly chosen comment.

There are some pdf files which are describing howw ReTweetRSS works. Unfortunatly all of them are written in Polish.

How to install your own ReTweetRSS? 

1. Import database_aj334557.sql to PostreSQL database (tested on version PostgreSQL 9.0.13)
2. Upload files from serwer.zip to PHP server
3. Change config in start.php (database connection url, login and password)
4. Import ReTweetRSS to Visual Studio 2012
5. In UserData.cs, line 84 (method Connect) set url adress of your php server
