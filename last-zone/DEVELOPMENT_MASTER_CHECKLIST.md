# LAST ZONE — Master Development & Release Checklist

Audit baseline: 2026-11-23  
Repository: `dhanushkaprasad2001-max/dhanushkaprasad2001-max.github.io`  
Engine: Godot 4.4.1

This checklist separates systems present in the repository / automated CI from work that is still missing or not proven. A successful debug APK export is not a production release.

## Status key

- [x] Present in the project and/or covered by the named automated check.
- [ ] Missing, prototype-only, or not yet proven to meet release quality.
- [ ] External deployment / real-device work; cannot be completed by a repository build alone.

## 1. Core project and build pipeline

- [x] Godot project configuration and main scene.
- [x] CI imports the project and validates project configuration.
- [x] CI starts the game in a headless smoke test.
- [x] CI exports an Android ARM64 debug APK.
- [x] CI exports a Linux x86_64 dedicated-server build.
- [x] Local profile/config loading now clamps unsafe numeric values, validates mode/settings, bounds history/friends, repairs collection defaults and sanitizes malformed local career data before use (CI verification pending for commit `c9ab6dc`).
- [x] Self-test now checks alignment and safe ranges across all eight weapon stat tables (CI verification pending for commit `c9ab6dc`).
- [x] CI uploads both build artifacts.
- [ ] Production Android release export (AAB/APK) with a newly generated, securely stored signing key.
- [ ] Release signing secrets and Play Store release configuration.
- [ ] Privacy policy, store listing, age/content declarations, data-safety disclosures and legal compliance.
- [ ] Reproducible versioning, release notes and rollback procedure.

## 2. Operators, characters and animation

- [x] Roster data for 50 operators exists in the project.
- [x] 50 procedural GLTF character assets are present in `assets/characters`.
- [x] Operator-specific stat/signature profiles and 50 active-skill recipe combinations are implemented.
- [x] Automated self-test checks the 50 tactical recipe combinations for uniqueness and valid component IDs.
- [x] AnimationPlayer keyframe clip set is generated and self-tested for the authored animation states.
- [ ] Verify all 50 GLTF assets visually in-engine; automated file presence is not a visual quality check.
- [ ] Improve character models, materials, clothing, faces, hands, proportions and LODs to final production quality.
- [ ] Create and validate full bone-driven animations per operator (the current shared keyframe rig layer is not 50 bespoke bone-animation sets).
- [ ] Validate hitboxes, skeleton retargeting, weapon grip, foot placement and animation blending for all operators.
- [ ] Complete character select, preview, unlock, equip, upgrade and persistence flows.
- [ ] Test all 50 operators in real matches for skill balance and exploit cases.

## 3. Skills and combat

- [x] Existing archetype/signature skill framework.
- [x] 50 distinct tactical recipes assembled from reusable tactical components.
- [x] Automated validation of recipe count, uniqueness and component ID bounds.
- [x] Server-side skill request/cooldown validation framework exists.
- [ ] Verify every active skill's complete gameplay effect on the authoritative server and replicate all ammo, movement, cover, decoy and visual effects to all clients.
- [x] Server-authoritative immediate health/armor grants and timed regeneration sync are implemented for active skills; automated bounds coverage now iterates all 50 operators and explicitly checks FIELD ENGINEER armor.
- [ ] Ensure local-only visuals/effects cannot grant client-side combat advantages.
- [x] Gloo-wall deployment now uses server-approved charges, server-side position validation, and reliable spawn replication to all connected peers; charge state is removed on disconnect.
- [x] Two-client CI now verifies both replicated wall spawn on peers and the requesting client's authoritative charge decrement.
- [ ] Add per-skill cooldown, duration, interruption, death/respawn and edge-case tests.
- [ ] Full balance pass for damage, armor, healing, movement and skill stacking.
- [ ] Confirm skill UI, descriptions, icons, sound and cooldown feedback for every operator.
- [ ] Complete combat test matrix: headshots, body shots, armor, knock/elimination, friendly fire, latency and reconnect.

## 4. Weapons and equipment

- [x] Weapon prototype configuration and firing/reload/damage systems exist.
- [x] Server-validated weapon damage and ammo-related gameplay code exists.
- [ ] Complete intended weapon roster and verify each weapon's unique stats.
- [ ] Finish weapon models, animations, muzzle flash, impact effects and audio.
- [x] World weapon loot now exposes all 28 configured weapon entries through a common indexed pickup path; automated self-test checks complete weapon-index coverage.
- [ ] Attachments, scopes, weapon inventory, pickup/drop and equip flows: verify and complete.
- [ ] Weapon skins, cosmetics and player-facing preview/equip flows.
- [ ] Test recoil, spread, reload, range, projectile/hitscan behavior and server authority for every weapon.
- [ ] Complete grenades and other throwable/tactical equipment if included in the final design.

## 5. Player movement and survival

- [x] Third-person movement and touch camera/control prototype.
- [x] Health, armor, elimination and damage code.
- [x] Gloo-wall/tactical cover code is present.
- [x] Online gloo-wall deployment, charge deduction and wall collision/visual spawn are now server-authoritative and replicated.
- [x] Spectator camera and match results systems are described in the project README.
- [ ] Validate sprint, crouch, jump, vault/climb and movement transitions on mobile.
- [ ] Complete knockdown, revive, healing items and teammate revive rules; verify edge cases.
- [ ] Validate collision, fall damage, water/terrain boundaries and spawn protection.
- [ ] Finalize mobile HUD, aim assist, sensitivity, button layout and accessibility settings.

## 6. Battle Royale world and match flow

- [x] Procedural island terrain, ocean, roads, buildings, trees and landmarks.
- [x] Visible transport aircraft fly-by is added to the air-insertion/parachute sequence (visual prototype; not yet a networked shared plane entity).
- [x] Shared loot, inventory and safe-zone damage are described in the project README.
- [x] Solo, Duo and Squad team assignment / capacity validation.
- [x] Ready-up lobby and countdown with minimum team/player validation.
- [x] Team-aware victory checks and match results.
- [ ] Complete map art, building interiors, cover, navigation landmarks, optimization and visual polish.
- [ ] Verify spawn selection, loot distribution, match start/end and all win/lose conditions.
- [ ] Verify safe-zone phases, timing, radius, warnings, damage and final-circle behavior.
- [ ] Verify loot tables, item rarity, pickup/drop, inventory capacity and death loot.
- [ ] Add map minimap, compass, pings/markers and player navigation UI.
- [ ] Confirm all Solo/Duo/Squad edge cases, disconnects, reconnects and empty-team handling.

## 7. Vehicles

- [x] Vehicle prototype with server-authoritative online driving physics.
- [x] Server-checked driver entry/exit and replicated vehicle state.
- [x] Weapon damage / destruction and team-aware impact damage.
- [x] CI test covers vehicle entry, server movement replication and exit.
- [ ] Finish vehicle models, sounds, damage visuals, handling and mobile controls.
- [ ] Passenger seats, repair interactions and production-grade lag compensation.
- [ ] Balance vehicle durability, spawn locations, collision and damage.

## 8. Multiplayer and networking

- [x] ENet dedicated-server/client connection on UDP port 27015.
- [x] Direct server address entry in the lobby.
- [x] Server-side admission, team capacity, combat validation and movement checks.
- [x] CI integration test with two ENet clients.
- [x] CI assertion for authoritative gloo-wall spawn replication passed in the latest two-client ENet integration run (both clients observed the replicated wall).
- [x] CI capacity test has admitted 50 automated clients and rejected the 51st (connection-capacity test only).
- [ ] Global matchmaking service and public server discovery.
- [ ] Party invites, party persistence and cross-server party queue.
- [ ] Account authentication, session tokens and secure identity.
- [ ] Production server hosting, regional fleet, autoscaling, monitoring and backups.
- [ ] Real 50-human concurrent load test; automated connection test is not equivalent.
- [ ] Network abuse review, packet validation, rate limits, replay protection and authoritative state audit.
- [ ] Lag compensation, interpolation, prediction and reconnect/resume testing on real networks.
- [ ] Verify online skills, character cosmetics, vehicles, loot and match state synchronize correctly for every peer.

## 9. Progression, economy and player data

- [x] Local career progression, match history, daily missions and achievements are described in the project README.
- [ ] Verify progression persistence across restart and app update.
- [ ] Cloud save and server-side player profile.
- [ ] Secure player account creation/login and account recovery.
- [ ] Complete XP, levels, ranks, seasons, leaderboards and reward rules.
- [ ] Complete currency wallet, store, purchase validation and transaction history if monetization is included.
- [ ] Daily/weekly missions, claim validation and anti-duplication checks.
- [ ] Battle pass / cosmetic ownership / inventory persistence if included in final scope.

## 10. AI bots and enemies (excluded by design)

- [x] LAST ZONE is a human-player-only online multiplayer game.
- [x] No AI bots, AI enemies, bot-filled match slots, or offline AI training targets are included.
- [x] Training Ground uses the same online multiplayer connection model; players train individually or alongside other connected human players.
- [x] AI bot/target movement and firing prototype removed from the game code.
- [x] AI enemies are intentionally out of scope and must not be reintroduced.

## 11. UI, audio and accessibility

- [x] Core lobby, HUD, roster, kill feed and match-result UI code exists.
- [ ] Final main menu, settings, controls, profile, store and collection screens.
- [ ] Complete sound effects, weapon audio, footsteps, ambience, UI audio and music; current procedural/prototype audio and visual effects still need a full asset and mix pass.
- [ ] Voice chat / team communication decision and implementation if required.
- [ ] Localization, readable text scaling, color accessibility and safe-area handling.
- [ ] UI flow tests for back navigation, reconnect, errors, pause and app resume.

## 12. Mobile performance, quality and security

- [x] Android debug export succeeds in CI.
- [ ] Test on physical Android devices across low-, mid- and high-range hardware.
- [ ] Measure and optimize FPS, frame pacing, memory, loading, battery and thermal behavior.
- [ ] Graphics presets, resolution scaling, texture compression, LOD and draw-call optimization.
- [ ] Handle phone calls, app background/resume, low memory, orientation and network changes.
- [ ] Crash reporting, diagnostics, privacy-conscious analytics and production monitoring.
- [ ] Security review for client trust, save tampering, currency manipulation and network exploits.
- [ ] Accessibility, parental / age-rating requirements and store policy review.

## 13. Release gates

- [ ] All P0/P1 gameplay and networking defects fixed.
- [ ] All automated tests pass on the final release commit.
- [ ] Full manual QA test matrix completed.
- [ ] Real-device Android testing completed.
- [ ] Real-human multiplayer and load testing completed.
- [ ] Production dedicated servers deployed and monitored.
- [ ] Release signing configured securely; never commit keystores or passwords to the repository.
- [ ] Signed Android App Bundle generated and verified.
- [ ] Store assets, privacy policy and compliance completed.
- [ ] Staged rollout, crash monitoring and rollback plan ready.

## Current verified CI evidence

Latest fully verified code commit remains `d99156b2f3197ee61e82a83171a4fe3c1f4bb89f`; later development commits listed below still require a fresh CI run before they can be called verified.

Latest fully successful Android workflow run: [Run 45143239698](https://github.com/dhanushkaprasad2001-max/dhanushkaprasad2001-max.github.io/actions/runs/45143239698) on commit `3406c34c87abf4882bd8dce8025f27ff0d64f8ab`.

Observed result: **success** for project import, configuration validation, startup smoke test, Android debug APK export, Linux dedicated-server export, two-client ENet integration test and artifact uploads.

Gloo-wall networking and its two-client replication assertion are being validated in [Run 45143932428](https://github.com/dhanushkaprasad2001-max/dhanushkaprasad2001-max.github.io/actions/runs/45143932428); do not mark this integration test passed until that run succeeds.


## 2026-11-23 development pass (new changes; build verification pending)

- [x] Removed all Combat Academy bots and offline AI target dummies. Training Ground now connects through the online multiplayer server and is human-player-only.
- [x] Added an in-game transport aircraft fly-by to the local air-insertion/parachute sequence. It is currently a visual prototype, not a server-replicated shared aircraft.
- [x] Expanded world loot from the previous limited pickup set to include all 28 configured weapon indices plus distributed ammunition, armour and medical supplies.
- [x] Added a self-test invariant requiring every configured weapon to have a corresponding world-loot entry.
- [ ] Run Godot import, parser/self-tests, startup, Android export, Linux server export and ENet integration against the newest commits; no successful result has yet been verified for this development pass.
- [ ] Production-grade character/weapon/vehicle assets, bespoke per-operator skeletal animation sets, global matchmaking, production servers, cloud accounts, and real-device/human-player QA remain outside the verified scope. AI bots/enemies are intentionally excluded from the game design.


## Important scope note

This is a development and release checklist, not a claim that every item is implemented. The repository README explicitly describes LAST ZONE as a playable-development prototype. Global matchmaking, public server hosting, account authentication, cloud saves, production anti-cheat, real-human load testing and final-quality assets remain outstanding. A successful CI build proves the listed automated steps only; it does not prove a finished production game.

## 2026-11-23 additional development pass

- [x] Added a live tactical minimap UI to the in-game HUD.
- [x] Minimap draws the island road grid, creek, named district markers, player position and current safe-zone radius.
- [x] Minimap shows only the local human player and authored map landmarks; it does not add AI bots, AI targets or enemy tracking.
- [ ] Godot import/parser/self-tests and Android/Linux exports for commit `e152b754719cf21476e4c2e5af307690c76e7f9f` are still running / not yet verified.
