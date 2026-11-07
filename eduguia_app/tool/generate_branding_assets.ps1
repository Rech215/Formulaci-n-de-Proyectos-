Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$destino = Join-Path $root 'assets\branding'
New-Item -ItemType Directory -Force -Path $destino | Out-Null

$slate900 = [System.Drawing.ColorTranslator]::FromHtml('#0F172A')
$slate800 = [System.Drawing.ColorTranslator]::FromHtml('#1E293B')
$brand900 = [System.Drawing.ColorTranslator]::FromHtml('#134E4A')
$brand600 = [System.Drawing.ColorTranslator]::FromHtml('#0D9488')
$brand400 = [System.Drawing.ColorTranslator]::FromHtml('#2DD4BF')
$blanco = [System.Drawing.Color]::White

function New-RoundedPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Ancho,
        [float]$Alto,
        [float]$Radio
    )

    $ruta = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diametro = $Radio * 2
    $ruta.AddArc($X, $Y, $diametro, $diametro, 180, 90)
    $ruta.AddArc($X + $Ancho - $diametro, $Y, $diametro, $diametro, 270, 90)
    $ruta.AddArc($X + $Ancho - $diametro, $Y + $Alto - $diametro, $diametro, $diametro, 0, 90)
    $ruta.AddArc($X, $Y + $Alto - $diametro, $diametro, $diametro, 90, 90)
    $ruta.CloseFigure()
    return $ruta
}

function New-Lienzo {
    param([int]$Ancho, [int]$Alto, [bool]$FondoOscuro)

    $bmp = New-Object System.Drawing.Bitmap $Ancho, $Alto
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    if ($FondoOscuro) {
        $rect = New-Object System.Drawing.Rectangle 0, 0, $Ancho, $Alto
        $gradiente = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $slate900, $brand900, 45.0
        $g.FillRectangle($gradiente, $rect)
        $gradiente.Dispose()
    } else {
        $g.Clear([System.Drawing.Color]::Transparent)
    }

    return @{ Bitmap = $bmp; Graphics = $g }
}

function Add-Marca {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$Lado,
        [float]$Radio,
        [float]$Fuente
    )

    $ruta = New-RoundedPath -X $X -Y $Y -Ancho $Lado -Alto $Lado -Radio $Radio
    $rect = New-Object System.Drawing.RectangleF $X, $Y, $Lado, $Lado
    $degradado = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $brand600, $brand400, 45.0
    $G.FillPath($degradado, $ruta)
    $degradado.Dispose()

    $lapiz = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(40, 255, 255, 255)), ($Lado * 0.012)
    $G.DrawPath($lapiz, $ruta)
    $lapiz.Dispose()
    $ruta.Dispose()

    $tipografia = New-Object System.Drawing.Font 'Segoe UI', $Fuente, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $formato = New-Object System.Drawing.StringFormat
    $formato.Alignment = [System.Drawing.StringAlignment]::Center
    $formato.LineAlignment = [System.Drawing.StringAlignment]::Center
    $pincel = New-Object System.Drawing.SolidBrush $blanco
    $caja = New-Object System.Drawing.RectangleF $X, $Y, $Lado, $Lado
    $G.DrawString('E', $tipografia, $pincel, $caja, $formato)
    $pincel.Dispose()
    $tipografia.Dispose()
    $formato.Dispose()
}

# Icono principal (1024x1024)
$icono = New-Lienzo -Ancho 1024 -Alto 1024 -FondoOscuro $true
Add-Marca -G $icono.Graphics -X 202 -Y 202 -Lado 620 -Radio 150 -Fuente 340
$icono.Bitmap.Save((Join-Path $destino 'app_icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$icono.Graphics.Dispose()
$icono.Bitmap.Dispose()

# Primer plano adaptativo (432x432, fondo transparente)
$foreground = New-Lienzo -Ancho 432 -Alto 432 -FondoOscuro $false
Add-Marca -G $foreground.Graphics -X 94 -Y 94 -Lado 244 -Radio 60 -Fuente 132
$foreground.Bitmap.Save((Join-Path $destino 'app_icon_foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$foreground.Graphics.Dispose()
$foreground.Bitmap.Dispose()

# Logo para splash (512x512, fondo transparente)
$splash = New-Lienzo -Ancho 512 -Alto 512 -FondoOscuro $false
Add-Marca -G $splash.Graphics -X 106 -Y 106 -Lado 300 -Radio 76 -Fuente 160
$splash.Bitmap.Save((Join-Path $destino 'splash_logo.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$splash.Graphics.Dispose()
$splash.Bitmap.Dispose()

Write-Output "Assets generados en $destino"
