# DESCRIPTION: Cleans up any old n8n container and starts a new one,
#              automatically configured with the current public ngrok URL.
#              Also checks/creates the n8n_data Docker volume.

# --- Configuration ---
$InfoColor = "Cyan"
$SuccessColor = "Green"
$ErrorColor = "Red"
$WarningColor = "Yellow"

try {
    Write-Host "🔎 Checking for existing 'n8n' container..." -ForegroundColor $InfoColor
    $existingContainer = docker ps -a -f name=n8n -q
    if ($existingContainer) {
        Write-Host "Found old container. Stopping and removing it..." -ForegroundColor $WarningColor
        docker stop n8n
        docker rm n8n
    }
    else {
        Write-Host "No existing 'n8n' container found. Proceeding." -ForegroundColor $InfoColor
    }

    Write-Host "🔎 Checking for Docker volume 'n8n_data'..." -ForegroundColor $InfoColor
    $volumeExists = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq "n8n_data" }
    if (-not $volumeExists) {
        Write-Host "Volume 'n8n_data' does not exist. Creating it..." -ForegroundColor $WarningColor
        docker volume create n8n_data | Out-Null
        Write-Host "Volume 'n8n_data' created." -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "Volume 'n8n_data' already exists." -ForegroundColor $InfoColor
    }

    Write-Host "🔗 Fetching ngrok public URL..." -ForegroundColor $InfoColor
    $ngrokUrl = (Invoke-RestMethod -Uri http://127.0.0.1:4040/api/tunnels).tunnels[0].public_url

    if (-not $ngrokUrl) {
        throw "Failed to retrieve ngrok URL. Please ensure ngrok is running."
    }
    Write-Host "✅ Got public URL: $ngrokUrl" -ForegroundColor $SuccessColor

    Write-Host "🚀 Starting new n8n container in the background..." -ForegroundColor $InfoColor
    docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e WEBHOOK_URL=$ngrokUrl docker.n8n.io/n8nio/n8n

    Write-Host "🎉 Done! Your new n8n container is running and configured.`n" -ForegroundColor $SuccessColor
}

catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor $ErrorColor
    exit 1
}