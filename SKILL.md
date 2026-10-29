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
- Frozen maze: `assets/images/frozen_maze.png`, `assets/images/anna.png`, `assets/images/elsa.png`, `assets/images/olaf_no_nose.png`, and `assets/images/olaf_has_nose.png`

Preserve transparency and use these exact assets unless the user names replacements.

## Product invariants

- Flutter with GetX state management; persistence uses `shared_preferences`.
- Design for a portrait phone first, using approximately `390x844` as the primary QA size. Prevent overflow, keep tap targets usable, allow scrolling where necessary, and keep interactive scenery behind all text panels.
- After the player submits a name, remove the name page from navigation history. Do not allow returning to it from the game.
- The castle home settings button uses its own `Positioned(top, right)` layer inside `SafeArea`; it must stay pinned to the physical top-right instead of participating in the status `Row`. Clearing memory always requires an explicit confirmation, removes only this game's saved player/progress/inventory data, resets every runtime mission state, and returns to the name-entry page.
- Automatically save the player name, dialogue state, mission progress, stars, recruited characters, grass-search state, and inventory. A later launch resumes directly in the game.
- Before revealing the first route, preload and decode every local character/background image and warm up the commonly used Traditional Chinese glyphs. Show only the dedicated loading surface until preloading completes, so partially loaded game scenes never flash on screen.
- Use the custom royal-purple, gold, fairy-tale controls in `lib/widgets/game_widgets.dart`. Do not reintroduce default Material 3 buttons.
- Keep cross-platform emoji fallbacks (`Apple Color Emoji`, `Noto Color Emoji`, `Segoe UI Emoji`, and `Twemoji Mozilla`) in the app theme so decorative symbols do not render as missing-glyph boxes. Prefer Material icons or local image assets for critical controls and gameplay feedback.
- Never place Emoji, dingbat, or decorative Unicode symbols directly in visible `Text` widgets. Web fallback fonts can briefly show tofu boxes even after preloading; use bundled Material `Icon`s, `GameItemArt`, local images, or custom painting instead.
- Do not render the dog bone, Lotso strawberry, or Goofy green sock as emoji. Use the code-drawn `GameItemArt` for their animations and inventory slots so late emoji-font loading never produces a temporary missing-glyph box.
- Flying bones, socks, strawberries, and bows must be later children in the scene `Stack` (or use the outermost overlay), so reward items always render in front of every character.
- The main castle initially shows only the princess and Mickey. Pluto appears there only after completing the first mission.
- Missions unlock sequentially. Show completed missions and the current mission; keep later mission details hidden behind a generic locked row.
- The complete adventure contains exactly 10 missions. Missions 1–3 are Pluto's bone, the Toy Story alien rescue, and Minnie's bow. Missions 4–10 are Olaf's carrot, Aladdin's carpet rescue, Simba's courage trial, Stitch's record party, Belle's enchanted rose, Pooh's honey maze, and Rapunzel's birthday lantern finale. The final story uses Rapunzel, Pascal, and Eugene to recover sun-emblem fragments and light the kingdom's birthday lanterns.
- Missions 4 and 5 have dedicated implementations in `lib/views/frozen_maze_page.dart` and `lib/views/aladdin_flight_page.dart`. Missions 6–10 currently use the shared playable prototype in `lib/views/prototype_mission_page.dart`: named character placeholders, player-controlled dialogue, a mission-specific moving-target activity, visible progress, a player-triggered reward animation, inventory reward, and saved dialogue/activity progress. Missing character art must not block gameplay; replace a named placeholder with a transparent local asset later without changing mission progression. Never auto-complete a prototype mission before the required target count and the player's explicit reward action.
- Developer mission skipping uses the compile-time `START_MISSION` integer flag. Keep the default at mission 1. A fresh adventure launched with, for example, `--dart-define=START_MISSION=5` must mark missions 1–4 complete, seed their required state and rewards, and make mission 5 the next hidden mission. Existing saved games remain authoritative until game memory is cleared.
- Before entering a mission scene, the castle, Mickey hint, main action button, mission scroll, and mission list must call every unfinished mission a generic `神秘任務`; never reveal its title, location, characters, objective, or reward. Reveal the story only inside the mission scene. Completed missions may show their real title and description.
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
   The full sock reward overlay must be a later child than the inventory panel in the Pluto scene `Stack`, so the flying sock is visibly painted above the inventory bar and its slots.
10. Complete and save the mission only after the sock reaches inventory. Then return to the castle and add Pluto to the main cast. When migrating an older completed save, insert the sock at slot one and shift existing rewards right instead of overwriting them.

Do not collapse these into one immediate state change; the visible animation order is part of the game logic.
Major story animations pause at their important reveal/gift moments and expose a custom `MagicButton` next-step action. Never let a plot reveal finish automatically before the player can read it.

## Second mission: rescue the three-eyed alien

Preserve this order:

0. Both entry points—the mission-scroll row and the castle's main action button—must navigate to `/andy-room`. Never send mission two through the generic instant-completion/search path.
1. Enter the generated Andy's room background and show Woody and Buzz discussing the missing three-eyed alien.
2. Slinky Dog and Lotso appear and explain that Zurg probably captured the alien.
3. Zurg appears and challenges the player.
4. Run the mobile-safe tap battle. Start the dodge timer only while battle mode is active. Zurg chooses randomly among every position except its current one, moves at a randomized `360–720ms` interval, also jumps to a random different position immediately after a successful hit, stays inside the unobstructed battle area, and requires five successful taps. Every hit must visibly update the energy label/bar and play an unmistakable red color flash, strong scale/shake/rotation, lightning, and hit-text response; the flash and hit text disappear `700ms` after the most recent hit.
   Read reactive battle values (`zurgHealth` and `zurgDodgeIndex`) inside an active `Obx` tracking scope before passing them into `LayoutBuilder`; values read only from the deferred layout callback will not rebuild the battle UI.
5. After Zurg is defeated, first animate Zurg from its last dodge position to the exact screen center. Zurg says `啊啊啊啊啊啊！` and slowly fades away; do not reveal the alien before Zurg has faded.
6. The three-eyed alien then slowly fades/scales in and says `你救了我們，我們永遠感謝你！`. Only after that sequence, show the rescued alien with Woody, Buzz, Slinky Dog, and Lotso. Do not include Zurg in the thank-you cast. Then each remaining character thanks the player in sequence.
7. Lotso gives `熊抱哥的草莓`. Animate the strawberry into inventory, complete and save mission two, then return to the castle.

Keep dialogue, battle health, dodge position, thank-you progress, mission completion, and the strawberry reward compatible with automatic save restoration.

## Third mission: Minnie's red bow

Preserve this order:

1. Both mission entry points navigate to `/minnie-garden`. Show `minnine_pink.png`; Minnie explains that her red bow is missing and she is distressed.
2. Show six glowing search spots. Every spot is wrong, can be searched once, and search progress is saved.
3. Only after all six spots have been searched, slowly fade/slide Pluto into the scene. First ask the player to press `請布魯托幫忙看看`; Pluto then replies `汪！交給我，我來聞聞看！`, and a separate next-step button starts the search. Persist this asked/replied state.
4. Pluto follows a visible sniffing route and pauses when the code-drawn red bow is found. After the player continues, Pluto carries the bow toward the player, pauses to hand it over, then the bow animates into inventory and Pluto visibly leaves. Commit `minnieRedBowFound` only after the handoff and exit animation finishes; once the animation completes, Pluto must remain absent from the garden scene.
5. Tapping the red bow in inventory removes it and animates it to Minnie. At arrival, switch Minnie to `minnine_red.png`.
6. Minnie thanks the player and sends the code-drawn pink bow into inventory. Complete and save mission three only after the pink bow reaches inventory, then return to the castle.

Persist the six searched spots, Pluto-search state, found red bow, returned-bow state, reward animation state, mission completion, and inventory. Do not render either bow as emoji.

## Fourth mission: Olaf's carrot nose

Preserve this order:

1. Both mission entry points navigate to `/frozen-maze`. Anna explains that the wind blew Olaf's carrot nose into the ice maze; Elsa asks the player to follow the glowing footprints; Anna warns about rolling snowballs.
2. Dialogue advances only through the player's custom next-step buttons. Do not start the maze until all three lines have been read.
3. Show eight sequential footprints. Only the next footprint is active. Pressing it animates the player marker along the path instead of completing the step instantly. Three animated snowballs cross separate lanes on a forgiving `5500ms` cycle; continuously detect collision both while the marker is travelling and while it is waiting at a reached footprint.
4. Any snowball collision, whether on the route or at a reached footprint, resets the footprint progress to zero, moves the marker back to the starting position, restarts the snowball cycle from its beginning, and saves that reset. If no collision occurs, save every successfully reached footprint. Reopening the game resumes at the next saved footprint.
5. After all eight footprints, reveal a code-drawn carrot. The player must tap it to return Olaf's nose.
6. Show Olaf's success moment and wait for the player to press `收下魔法雪花`. Animate the code-drawn snowflake above the inventory bar into an inventory slot, then complete mission four and return to the castle.

Do not replace the snowflake reward with Emoji text. Keep the snowball collision area away from the story panel and inventory bar.

## Fifth mission: Aladdin's carpet rescue

Preserve this order:

1. Both mission entry points navigate to `/aladdin-flight`. Aladdin explains that Jafar sealed the Genie in the lamp and filled the sky with magic attacks.
2. The player controls Aladdin and the carpet with four explicit up/down/left/right controls on a 3-by-3 flight grid.
3. Run 12 obstacle waves from right to left. Each wave blocks one or two lanes, always leaving at least one safe lane. A collision repeats the current wave without granting progress; each successfully avoided wave is saved.
4. After all waves, Jafar appears in the center. The player must repeatedly tap Jafar 12 times; every hit visibly reacts and saves health.
5. After Jafar reaches zero health, show his magic fading and wait for the player to press the custom button that opens the lamp and rescues the Genie.
6. The Genie says `感謝你把我救回來！我送你一個願望，選一個吧！` and offers exactly four choices: courage, happiness, adventure, and friendship. Save the chosen wish.
7. Wait for the player to confirm returning to the castle, add the chosen Genie wish to inventory, complete mission five, and return to the lobby.

Persist dialogue, avoided-wave count, carpet grid position, Jafar health, Genie rescue state, chosen wish, mission completion, and inventory.

## Verification

- Maintain or update `test/widget_test.dart` to exercise the full implemented mission flow at `390x844`.
- Verify important intermediate animation states with stable keys when changing the sequence.
- Finish with `flutter test` and `dart analyze`.
