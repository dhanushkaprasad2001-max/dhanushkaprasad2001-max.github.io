# LAST ZONE — Android Battle Royale Prototype

Godot 4.4.1 third-person mobile battle-royale prototype.

## Current prototype systems

- Procedural island terrain, ocean, roads, buildings, trees and landmarks
- Third-person character, touch camera and mobile movement controls
- Solo, Duo and Squad lobby modes with team assignment
- Lobby field for saving a dedicated-server IP/hostname locally, then direct ENet connection on UDP 27015
- Separate server-locked CASUAL and RANKED Battle Royale queues (queue and team mode must match)
- Human-only online combat: no AI enemies or AI filler players are spawned in online matches
- ENet multiplayer server/client connection on UDP port 27015
- CI-tested ENet admission of 50 automated test clients with the 51st rejected; this is a connection-capacity test, not a real-human load test
- Ready-up lobby and 15-second countdown after all players are ready and at least two full teams are present (Solo: 2, Duo: 4, Squad: 8)
- Server-relayed player positions with movement-rate and teleport checks
- Weapon prototypes, server-validated damage, armor, elimination and kill feed
- Team-aware victory checks: Duo/Squad matches end when only one team remains alive, and all members of the winning team receive the win reward
- Shared loot, inventory, safe-zone damage, spectator camera and match results
- Local career progression, match history, daily missions and achievements
- Android debug APK and Linux dedicated-server export workflows

## Important limitations

This is a playable-development prototype, not a finished Free Fire-scale game. The server cap is 50 connected peers. CI has admitted 50 automated ENet test clients and rejected the 51st, but 50 concurrent real human players have not been load-tested. There is no global cross-region matchmaking service, public server directory, party invitation backend, account authentication, cloud save, production server hosting, or production anti-cheat. The lobby accepts a manually supplied server address; it does not discover servers or automatically match players. Casual and Ranked queue separation currently happens inside one dedicated server; it is not yet a global matchmaking pool. Character models, animations, vehicles, weapons, map art and effects are still prototype quality. Online play requires a reachable server; a successful APK build does not mean a public server is deployed.

## Run locally

Install Godot 4.4.1 and its export templates, open this folder, and run `Main.tscn`.

Start a local headless server:

```sh
godot --headless --path . -- --server
```

The server listens on UDP port 27015 by default. Set the `LAST_ZONE_PORT` environment variable to use a different valid UDP port (1–65535). Clients enter the server IP in the game's connection field. For internet hosting, deploy the Linux dedicated-server artifact to a Linux host, allow inbound UDP on the configured port in its firewall/security group, and use that host's public IP. Do not expose a personal computer directly to the internet.

## Build artifacts

GitHub Actions exports:
- `last-zone-debug-apk`: Android ARM64 debug APK for device testing
- `last-zone-linux-dedicated-server`: Linux x86_64 dedicated-server executable

The Linux server artifact still needs to be deployed and configured on a host. No hosting provider or public IP is configured by this repository.

A Play Store release requires a private release-signing setup, release export configuration, privacy policy and store compliance.

## App identity

- Name: LAST ZONE
- Package: `com.lastzone.battleroyale`
- Engine: Godot 4.4.1
