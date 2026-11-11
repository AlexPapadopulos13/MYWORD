# MYWORD Notebook - tiny local web server (no installs needed).
# Usage:  powershell -ExecutionPolicy Bypass -File serve.ps1 [-Port 8080] [-NoBrowser]
# The microphone only works on http://localhost or https, so open the site through this server.
param(
  [int]$Port = 8080,
  [switch]$NoBrowser
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootFull = [System.IO.Path]::GetFullPath($root)
$mime = @{
  '.html' = 'text/html; charset=utf-8'; '.css' = 'text/css; charset=utf-8'; '.js' = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'; '.svg' = 'image/svg+xml'; '.png' = 'image/png'; '.jpg' = 'image/jpeg'
  '.ico' = 'image/x-icon'; '.webmanifest' = 'application/manifest+json'; '.txt' = 'text/plain; charset=utf-8'
}

function Send-Bytes($res, [int]$code, [string]$type, [byte[]]$bytes, [bool]$head) {
  $res.StatusCode = $code
  $res.ContentType = $type
  $res.Headers.Add('Cache-Control', 'no-cache')
  $res.ContentLength64 = $bytes.Length
  if (-not $head) { $res.OutputStream.Write($bytes, 0, $bytes.Length) }
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
try { $listener.Start() } catch {
  Write-Host "Could not start on port $Port. Is it already in use? Try: serve.ps1 -Port 8081" -ForegroundColor Red
  exit 1
}
Write-Host "MYWORD Notebook running at $prefix  (press Ctrl+C to stop)" -ForegroundColor Green
if (-not $NoBrowser) { Start-Process $prefix }

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request; $res = $ctx.Response
    $code = 500
    try {
      $path = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath).TrimStart('/')
      if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }
      $file = [System.IO.Path]::GetFullPath((Join-Path $rootFull $path))
      if (Test-Path $file -PathType Container) { $file = Join-Path $file 'index.html' }
      $inside = $file.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)
      $hidden = ($path -split '[\\/]') | Where-Object { $_.StartsWith('.') }
      if ($inside -and -not $hidden -and (Test-Path $file -PathType Leaf) -and ($file -notlike '*.ps1')) {
        $ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
        $type = 'application/octet-stream'
        if ($mime.ContainsKey($ext)) { $type = $mime[$ext] }
        Send-Bytes $res 200 $type ([System.IO.File]::ReadAllBytes($file)) ($req.HttpMethod -eq 'HEAD')
        $code = 200
      } else {
        Send-Bytes $res 404 'text/plain; charset=utf-8' ([System.Text.Encoding]::UTF8.GetBytes('Not found')) $false
        $code = 404
      }
      Write-Host ("{0} {1} {2}" -f $code, $req.HttpMethod, $req.Url.AbsolutePath)
    } catch {
      Write-Host "Error: $_" -ForegroundColor Yellow
      try { $res.StatusCode = 500 } catch {}
    } finally {
      try { $res.Close() } catch {}
    }
  }
} finally {
  $listener.Stop(); $listener.Close()
}
