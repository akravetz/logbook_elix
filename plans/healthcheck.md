Add two healthcheck endpoints. Both should be publicly available.
api/health - returns a json object {"status": "healthy"}
api/dbhealth - runs a SELECT 1 query to ensure the database is accessible and returns {"dbstatus": "healthy"} if it works