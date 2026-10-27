---
name: disney-birthday-game
description: Maintain this Flutter/GetX birthday adventure game while preserving its mobile layout, local Disney character assets, mission progression, animations, and save behavior. Use for UI, story, mission, character, inventory, animation, or asset changes in this project.
---

# Birthday Adventure Game

Keep changes consistent with the existing game and minimize network, image-generation, and repeated inspection costs.

## Efficiency

- Work from the existing Flutter/GetX implementation. Inspect only files relevant to the requested change.
- Reuse local assets. Do not browse, download, regenerate, remove backgrounds from, or re-open large images unless the user explicitly requests an asset change or the file is missing.
- Do not run image generation for layout or animation changes that Flutter widgets can implement.
- Avoid adding dependencies unless the requested behavior cannot reasonably use the current stack.
- Prefer one focused `dart analyze` during implementation and one targeted `flutter test` at the end. Do not repeatedly download dependencies or rebuild unrelated targets.

## Existing assets

- Castle: `assets/images/castle_courtyard.png`
- Princess: `assets/images/princess_cutout.png`
- Mickey: `assets/images/mickey_cutout.png`
- Pluto before receiving the bone: `assets/images/pluto_cutout.png`
- Pluto's house: `assets/images/pluto_house.png`
- Pluto carrying the bone: `assets/images/pluto_has_bone.png`

Preserve transparency and use these exact assets unless the user names replacements.

## Product invariants

- Flutter with GetX state management; persistence uses `shared_preferences`.
- Design for a portrait phone first, using approximately `390x844` as the primary QA size. Prevent overflow, keep tap targets usable, allow scrolling where necessary, and keep interactive scenery behind all text panels.
- After the player submits a name, remove the name page from navigation history. Do not allow returning to it from the game.
- Automatically save the player name, dialogue state, mission progress, stars, recruited characters, grass-search state, and inventory. A later launch resumes directly in the game.
- Use the custom royal-purple, gold, fairy-tale controls in `lib/widgets/game_widgets.dart`. Do not reintroduce default Material 3 buttons.
- The main castle initially shows only the princess and Mickey. Pluto appears there only after completing the first mission.
- Missions unlock sequentially. Show completed missions and the current mission; keep later mission details hidden behind a generic locked row.
- The mission scroll opens by moving its top and bottom rods apart while revealing parchment from the center. Closing reverses the same rolling motion before navigation.

## First mission: Pluto's bone

Preserve this order:

1. Mickey explains that Pluto is hungry and needs help finding his dog bone.
2. Opening mission one enters Pluto's house scene.
3. Show six ordinary searchable grass patches. Each can be searched once, and search progress is saved.
4. Grass and scenery must never cover the header, instructions, or speech bubbles. Text layers stay visually above scenery.
5. The real glowing grass patch remains completely hidden until all six ordinary patches have been searched.
6. Tapping the real patch reveals the bone and animates it from the grass into inventory. The bone disappears from the grass while moving and appears in inventory only after the animation finishes.
7. Tapping the inventory bone removes it from the slot and animates it to Pluto first.
8. Only after Pluto receives the bone, switch to `pluto_has_bone.png`, flip it horizontally so Pluto faces the house, and animate Pluto running into `pluto_house.png`.
9. Complete and save the mission only after the dog-house animation finishes. Then return to the castle and add Pluto to the main cast.

Do not collapse these into one immediate state change; the visible animation order is part of the game logic.

## Verification

- Maintain or update `test/widget_test.dart` to exercise the full first mission at `390x844`.
- Verify important intermediate animation states with stable keys when changing the sequence.
- Finish with `flutter test` and `dart analyze`.
