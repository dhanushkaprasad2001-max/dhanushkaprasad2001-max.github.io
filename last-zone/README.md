# LAST ZONE — Android Battle Royale Prototype

Godot 4.4.1 third-person 3D battle-royale starter project.

## Included
- Procedurally generated island, water, trees and simple buildings
- Third-person player capsule and camera
- Keyboard controls and Android on-screen movement/jump/fire buttons
- ENet client connection on UDP port 27015
- Basic player connection and position-relay prototype
- Early safe-zone radius state
- GitHub Actions debug APK export workflow

## Important
This is an early prototype, not a finished Free Fire-scale game. Network synchronization is experimental. Authoritative combat, matchmaking, inventory, parachuting, anti-cheat, accounts, safe-zone damage, optimized realistic character models, and production hosting are not implemented yet. A public dedicated server must be deployed and its IP entered in the client. Do not expose a personal computer directly to the internet.

## Run
Install Godot 4.4.1 and its export templates, open this folder, and run Main.tscn.

Start a dedicated server with:
    godot --headless --path . -- --server

Allow inbound UDP port 27015 on the server firewall. Enter the server public IP in the game and press CONNECT.

## Android
GitHub Actions attempts to export a debug APK for arm64 Android. Debug APK is for testing only. A Play Store release requires private signing, release export configuration, privacy policy and store compliance.

Name: LAST ZONE
Package: com.lastzone.battleroyale
Engine: Godot 4.4.1
