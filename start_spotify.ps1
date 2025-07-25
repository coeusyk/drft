# DESCRIPTION: Starts Spotify (if it's not open) and opens a playlist, using the playlist ID from the
#              SPOTIFY_PLAYLIST_ID environment variable.

$playlistId = $env:SPOTIFY_PLAYLIST_ID
if (-not $playlistId) {
    Write-Host "No playlist ID found in environment variable SPOTIFY_PLAYLIST_ID"
    exit 1
}

if (-not (Get-Process -Name "Spotify" -ErrorAction SilentlyContinue)) {
    Start-Process "spotify"
    Start-Sleep -Seconds 5
}

Start-Process "spotify:playlist:$playlistId"
