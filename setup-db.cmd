@echo off
rem Builds the MeowletEducation database on (localdb)\MSSQLLocalDB and loads sample data.
rem   setup-db.cmd         create missing tables/columns, add missing sample rows
rem   setup-db.cmd reset   drop the database first and start clean (deletes all local data)

setlocal
set SERVER=(localdb)\MSSQLLocalDB
set DATA=%~dp0MeowletEducation\App_Data

sqllocaldb start MSSQLLocalDB >nul

if /i "%~1"=="reset" (
    echo Dropping MeowletEducation...
    sqlcmd -S "%SERVER%" -E -b -Q "IF DB_ID('MeowletEducation') IS NOT NULL BEGIN ALTER DATABASE MeowletEducation SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE MeowletEducation; END" || goto :fail
)

echo Creating schema...
sqlcmd -S "%SERVER%" -E -b -I -i "%DATA%\CreateDatabase.sql" || goto :fail

echo Loading sample data...
sqlcmd -S "%SERVER%" -E -b -I -i "%DATA%\SeedData.sql" || goto :fail

echo Done. Connection string: Data Source=%SERVER%;Initial Catalog=MeowletEducation
exit /b 0

:fail
echo Database setup failed.
exit /b 1
