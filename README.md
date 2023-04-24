# SQLServerToNodeHTTP

Project prototype which sends data from SQL Server to local node API with HTTP POST request. When a record gets inserted on the "Match" table, a trigger sends a post request containing the inserted Match with extra info from other tables as a JSON via HTTP. The Node API handles the request and sends this JSON to the "Match" collection in the local MongoDB "Voetbalcompetitiemanager" database.
