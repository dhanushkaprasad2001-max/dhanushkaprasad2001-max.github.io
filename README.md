# LAST ZONE and DreamHome Plans

This repository contains two separate projects:

- **LAST ZONE** — a Godot 4.4.1 Android battle-royale game prototype with a Linux ENet dedicated-server export.
- **DreamHome Plans** — the static home-design website published through GitHub Pages.

## LAST ZONE

Project directory: `last-zone/`

### Automated builds

The GitHub Actions workflow `.github/workflows/last-zone-android.yml`:

1. Imports and starts the Godot project in headless mode.
2. Exports an Android **debug APK**.
3. Exports a Linux x86_64 dedicated-server executable.
4. Starts the server and connects two automated ENet clients to test lobby readiness and match-start replication.
5. Uploads the APK and server executable as workflow artifacts.

Open the repository's **Actions** tab, select **Build LAST ZONE Android APK**, and open the latest successful run to download:

- `last-zone-debug-apk`
- `last-zone-linux-dedicated-server`

The APK is a debug build for testing; it is not a signed Google Play production release.

### Run a dedicated server

On a compatible Linux x86_64 machine with the exported Godot server runtime:

```bash
chmod +x last-zone-server.x86_64
LAST_ZONE_PORT=27015 ./last-zone-server.x86_64 -- --server
```

Allow inbound **UDP 27015** (or the port configured with `LAST_ZONE_PORT`) in the host firewall and any cloud-network firewall. Players must enter the host's reachable IP address in the game. This repository does not provide public server hosting or matchmaking infrastructure.

### Current scope and limitations

The project includes a playable prototype foundation: a procedural island, third-person movement, mobile controls, three weapon types, loot and survival systems, safe-zone logic, airdrop/parachute and vehicle prototypes, lobby/team selection, local career progression, and ENet server/client foundations.

The automated multiplayer test currently verifies two clients joining, becoming ready, and receiving the match-start event. The server's configured admission capacity is 50; this is **not** a completed 50-player load test. Online matchmaking, hosted public servers, cloud accounts/saves, production anti-cheat, and a full custom-room service are not included. Several gameplay systems remain prototypes and require real-device and broader multiplayer testing before release.

## DreamHome Plans

The website files are maintained in the repository root and published through GitHub Pages. Website AdSense approval and ad serving are separate from the LAST ZONE game build.
