REM Simple bat file to run the server
REM Run with -p to run production (note, not a real production server, just uses webrick)
if "%1"=="-p" (goto PRODUCTION)

ruby bin\rails server 
goto END

:PRODUCTION
REM May need to first run
REM bundle exec rake assets:precompile

REM Note also that to run production, you must have %SECRET_KEY_BASE% defined in your environment.
REM Create a file called SECRET_KEY_BASE.bat which just sets that one variable (it is excluded from git commits)
call SECRET_KEY_BASE.bat
set RAILS_SERVE_STATIC_FILES=true
ruby bin\rails server -e production

:END
