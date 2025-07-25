$ngrokUrl = (Invoke-RestMethod -Uri http://127.0.0.1:4040/api/tunnels).tunnels[0].public_url;

docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e WEBHOOK_URL=$ngrokUrl docker.n8n.io/n8nio/n8n