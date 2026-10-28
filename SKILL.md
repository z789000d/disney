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
- Andy's room background: `assets/images/andy_room.png`
- Toy rescue cast: `assets/images/woody.png`, `assets/images/bause.png`, `assets/images/slinky_dog.png`, `assets/images/lotso.png`, `assets/images/three_eye.png`, and `assets/images/zurg.png`

Preserve transparency and use these exact assets unless the user names replacements.

## Product invariants

- Flutter with GetX state management; persistence uses `shared_preferences`.
- Design for a portrait phone first, using approximately `390x844` as the primary QA size. Prevent overflow, keep tap targets usable, allow scrolling where necessary, and keep interactive scenery behind all text panels.
- After the player submits a name, remove the name page from navigation history. Do not allow returning to it from the game.
- Automatically save the player name, dialogue state, mission progress, stars, recruited characters, grass-search state, and inventory. A later launch resumes directly in the game.
- Use the custom royal-purple, gold, fairy-tale controls in `lib/widgets/game_widgets.dart`. Do not reintroduce default Material 3 buttons.
- Keep cross-platform emoji fallbacks (`Apple Color Emoji`, `Noto Color Emoji`, `Segoe UI Emoji`, and `Twemoji Mozilla`) in the app theme so decorative symbols do not render as missing-glyph boxes. Prefer Material icons or local image assets for critical controls and gameplay feedback.
- Do not render the dog bone, Lotso strawberry, or Goofy green sock as emoji. Use the code-drawn `GameItemArt` for their animations and inventory slots so late emoji-font loading never produces a temporary missing-glyph box.
- The main castle initially shows only the princess and Mickey. Pluto appears there only after completing the first mission.
- Missions unlock sequentially. Show completed missions and the current mission; keep later mission details hidden behind a generic locked row.
- The mission scroll opens by moving its top and bottom rods apart while revealing parchment from the center. Closing reverses the same rolling motion before navigation.

## First mission: Pluto's bone

Preserve this order:

1. Mickey explains that Pluto is hungry and needs help finding his dog bone.
2. Opening mission one enters Pluto's house scene.
3. Show six ordinary searchable grass patches. Each can be searched once, and search progress is saved.
4. Grass and scenery must never cover the header, instructions, speech bubbles, or Pluto's visible/tappable character area. Text layers stay visually above scenery. At the primary `390x844` size, every ordinary grass-patch rectangle must remain separate from Pluto's rectangle.
5. The real glowing grass patch remains completely hidden until all six ordinary patches have been searched.
6. Tapping the real patch reveals the bone and animates it from the grass into inventory. The bone disappears from the grass while moving and appears in inventory only after the animation finishes.
7. Tapping the inventory bone removes it from the slot and animates it to Pluto first.
8. Only after Pluto receives the bone, switch to `pluto_has_bone.png`, flip it horizontally so Pluto faces the house, and animate Pluto running into `pluto_house.png`.
9. After Pluto enters the dog house, Pluto must walk back out visibly carrying `🧦 高飛狗的綠襪子`, announce that it is a gift, and animate the sock into inventory slot one.
10. Complete and save the mission only after the sock reaches inventory. Then return to the castle and add Pluto to the main cast. When migrating an older completed save, insert the sock at slot one and shift existing rewards right instead of overwriting them.

Do not collapse these into one immediate state change; the visible animation order is part of the game logic.

## Second mission: rescue the three-eyed alien

Preserve this order:

0. Both entry points—the mission-scroll row and the castle's main action button—must navigate to `/andy-room`. Never send mission two through the generic instant-completion/search path.
1. Enter the generated Andy's room background and show Woody and Buzz discussing the missing three-eyed alien.
2. Slinky Dog and Lotso appear and explain that Zurg probably captured the alien.
3. Zurg appears and challenges the player.
4. Run the mobile-safe tap battle. Start the dodge timer only while battle mode is active. Zurg automatically moves to a clearly different position about every `520ms`, also jumps immediately after a successful hit, stays inside the unobstructed battle area, and requires five successful taps. Every hit must visibly update the energy label/bar and play an unmistakable red color flash, strong scale/shake/rotation, lightning, and hit-text response; the flash and hit text disappear `700ms` after the most recent hit.
   Read reactive battle values (`zurgHealth` and `zurgDodgeIndex`) inside an active `Obx` tracking scope before passing them into `LayoutBuilder`; values read only from the deferred layout callback will not rebuild the battle UI.
5. After Zurg is defeated, first animate Zurg from its last dodge position to the exact screen center. Zurg says `啊啊啊啊啊啊！` and slowly fades away; do not reveal the alien before Zurg has faded.
6. The three-eyed alien then slowly fades/scales in and says `你救了我們，我們永遠感謝你！`. Only after that sequence, show the rescued alien with Woody, Buzz, Slinky Dog, and Lotso. Do not include Zurg in the thank-you cast. Then each remaining character thanks the player in sequence.
7. Lotso gives `熊抱哥的草莓`. Animate the strawberry into inventory, complete and save mission two, then return to the castle.

Keep dialogue, battle health, dodge position, thank-you progress, mission completion, and the strawberry reward compatible with automatic save restoration.

## Third mission: Minnie's red bow

Preserve this order:

1. Both mission entry points navigate to `/minnie-garden`. Show `minnine_pink.png`; Minnie explains that her red bow is missing and she is distressed.
2. Show six glowing search spots. Every spot is wrong, can be searched once, and search progress is saved.
3. Only after all six spots have been searched, reveal Pluto with a clear tap prompt.
4. Tapping Pluto starts a visible sniffing route around the scene. Pluto repeatedly sniffs, finds the code-drawn red bow, and the bow animates into inventory before `minnieRedBowFound` is committed.
5. Tapping the red bow in inventory removes it and animates it to Minnie. At arrival, switch Minnie to `minnine_red.png`.
6. Minnie thanks the player and sends the code-drawn pink bow into inventory. Complete and save mission three only after the pink bow reaches inventory, then return to the castle.

Persist the six searched spots, Pluto-search state, found red bow, returned-bow state, reward animation state, mission completion, and inventory. Do not render either bow as emoji.

## Verification

- Maintain or update `test/widget_test.dart` to exercise the full implemented mission flow at `390x844`.
- Verify important intermediate animation states with stable keys when changing the sequence.
- Finish with `flutter test` and `dart analyze`.
