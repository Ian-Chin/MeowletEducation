# Downloads MindAR (image tracking for the Meowlet card) into assets/js/vendor/mindar,
# so AR card tracking works without internet (e.g. during a presentation).
# Without this copy the site loads MindAR from the jsDelivr CDN instead.
#
# Run from the project folder (where MeowletEducation.csproj is):
#   powershell -ExecutionPolicy Bypass -File tools\get-mindar.ps1

$ErrorActionPreference = 'Stop'
$version = '1.2.5'
$base = "https://cdn.jsdelivr.net/npm/mind-ar@$version/dist/"
$outDir = Join-Path $PSScriptRoot '..\assets\js\vendor\mindar'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# mindar-image.prod.js imports a few shared chunk files; follow them all.
$queue = New-Object System.Collections.Generic.Queue[string]
$seen = New-Object System.Collections.Generic.HashSet[string]
$queue.Enqueue('mindar-image.prod.js')

while ($queue.Count -gt 0) {
    $name = $queue.Dequeue()
    if (-not $seen.Add($name)) { continue }
    $target = Join-Path $outDir $name
    Write-Host "Downloading $name"
    Invoke-WebRequest -UseBasicParsing -Uri ($base + $name) -OutFile $target
    $text = Get-Content -Raw -LiteralPath $target
    foreach ($m in [regex]::Matches($text, '(?:from|import)\s*\(?\s*["'']\./([A-Za-z0-9_.\-]+\.js)["'']')) {
        $queue.Enqueue($m.Groups[1].Value)
    }
}

Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/hiukim/mind-ar-js/v$version/LICENSE" -OutFile (Join-Path $outDir 'LICENSE') -ErrorAction SilentlyContinue
Write-Host "Done. MindAR $version is in assets\js\vendor\mindar ($($seen.Count) file(s))."
