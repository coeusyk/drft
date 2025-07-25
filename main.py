import requests
import subprocess
import os


N8N_WEBHOOK_PATH = "/webhook/drft"


def get_ngrok_url():
    """Fetches the public URL from the local ngrok API."""

    try:
        response = requests.get("http://127.0.0.1:4040/api/tunnels")
        response.raise_for_status()
        tunnels_data = response.json()

        public_url = tunnels_data["tunnels"][0]["public_url"]
        return public_url

    except requests.exceptions.RequestException:
        return None


def create_playlist(prompt_text, webhook_url):
    """Sends a prompt to the n8n workflow and prints the result."""

    print(f"\n▶️ Sending prompt: '{prompt_text}'")

    payload = {
        "prompt": prompt_text
    }

    try:
        response = requests.post(webhook_url, json=payload, timeout=180)
        response.raise_for_status()

        response_json = response.json()
        playlist_data = response_json["playlist"]

        print(f"\n{response_json.get("message")}")
        print(f"   ID: {playlist_data.get('id')}")
        print(f"   Name: {playlist_data.get('name')}")
        print(f"   URL:  {playlist_data.get('url')}")

        os.environ["SPOTIFY_PLAYLIST_ID"] = playlist_data.get("id")
        run_spotify_path = r'.\start_spotify.ps1'

        subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass", "-File", run_spotify_path],
            check=True,
            env=os.environ
        )

    except requests.exceptions.RequestException as e:
        print(f"\n❌ ERROR: An error occurred while contacting the n8n workflow.")
        print(f"   Details: {e}")


if __name__ == "__main__":
    print("🔗 Fetching ngrok public URL...")
    ngrok_base_url = get_ngrok_url()

    if ngrok_base_url:
        full_webhook_url = ngrok_base_url + N8N_WEBHOOK_PATH
        print(f"✅ Found webhook URL: {full_webhook_url}")

        user_prompt = input("\nEnter your music mood/playlist description: ").strip()

        if not user_prompt:
            print("No description provided. Exiting.")
            exit(1)

        create_playlist(user_prompt, full_webhook_url)

    else:
        print("\n❌ ERROR: Could not get ngrok URL.")
        print("   Please make sure the ngrok tunnel is running before executing this script.")
