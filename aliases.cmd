
@ECHO OFF
REM Add an AutoRun "String" at location "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" to your alias file

ECHO Sourcing Aliases

:: Update path to GIT tools
DOSKEY addvim=set PATH=%PATH%;"C:\GIT\usr\bin 
DOSKEY addsed=set PATH=%PATH%;"C:\GIT\usr\bin
DOSKEY addgrep=set PATH=%PATH%;"C:\GIT\usr\bin


:: Update path to this file
DOSKEY aliases=notepad C:\Users\USER\aliases.cmd