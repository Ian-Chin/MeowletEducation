@echo off
sqlcmd -S "(localdb)\MSSQLLocalDB" -i "%~dp0MeowletEducation\App_Data\CreateDatabase.sql"
