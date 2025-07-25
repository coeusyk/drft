# `ngrok` Setup

**ngrok** is the flexible API gateway for instant, secure connectivity anywhere—public or private.

`ngrok` creates a secure tunnel to your local machine. You'll get a public `https://` web address that Spotify's dashboard will accept, and `ngrok` will forward all traffic from that address to your local n8n on port `5678`.

## **1. Set Up `ngrok`**

1. Go to the [ngrok website](https://ngrok.com/download), download the program for your operating system, and unzip it.

2. Sign up for a free account.

3. On your [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken), you'll find your authentication token. Copy it.

4. Open your terminal or command prompt and connect your account using the token you just copied:

```
ngrok config add-authtoken YOUR_TOKEN
```

## 2. **Run `ngrok` as a Background Service**

This method installs `ngrok` as a service on your machine, so it starts automatically and runs in the background, independent of any terminal window. This requires defining your tunnel in the `ngrok` configuration file.

1. **Locate your `ngrok.yml` file.** It's usually in your home directory (e.g., `C:\Users\YourUser\AppData\Local\ngrok` on Windows).

2. **Edit the file** to define the tunnel you want to run. Add this `tunnels` section:

```yaml
version: "3"
agent:
    authtoken: YOUR_AUTHTOKEN_HERE
tunnels:
  n8n:
    proto: http
    addr: 5678
```

3. **Install and start the service** from your terminal:

```
# To install the service
ngrok service install --config /path/to/your/ngrok.yml

# To start the service
ngrok service start
```

Now, the `ngrok` tunnel will always be running in the background. 

> **Note**: The URL changes every time you restart your computer.

To access the URL, go to http://localhost:4040.
