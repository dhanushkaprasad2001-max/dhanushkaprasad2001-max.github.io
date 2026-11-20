# LAST ZONE — Android Battle Royale Prototype

Godot 4.4.1 third-person mobile battle-royale prototype.

## Current prototype systems

- Procedural island terrain, ocean, roads, buildings, trees and landmarks
- Third-person character, touch camera and mobile movement controls
- Solo, Duo and Squad lobby modes with team assignment
- ENet multiplayer server/client connection on UDP port 27015
- Server admission limit of 50 connected players (capacity only; not proof of a 50-player load test)
- Ready-up lobby and 15-second countdown when at least two connected players are all ready
- Server-relayed player positions with movement-rate and teleport checks
- Weapon prototypes, server-validated damage, armor, elimination and kill feed
- Shared loot, inventory, safe-zone damage, spectator camera and match results
- Local career progression, match history, daily missions and achievements
- Android debug APK and Linux dedicated-server export workflows

## Important limitations

This is a playable-development prototype, not a finished Free Fire-scale game. The 50-player limit is a server-side cap; 50 concurrent real players have not been load-tested. There is no global matchmaking service, party invitation backend, account authentication, cloud save, production server hosting, or production anti-cheat. Character models, animations, vehicles, weapons, map art and effects are still prototype quality. Online play requires a reachable server; a successful APK build does not mean a public server is deployed.

## Run locally

Install Godot 4.4.1 and its export templates, open this folder, and run `Main.tscn`.

Start a local headless server:

```sh
godot --headless --path . -- --server
```

The server listens on UDP port 27015. Clients enter the server IP in the game's connection field. For internet hosting, deploy the Linux dedicated-server artifact to a Linux host, allow inbound UDP 27015 in its firewall/security group, and use that host's public IP. Do not expose a personal computer directly to the internet.

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
