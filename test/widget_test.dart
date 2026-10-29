import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:disney_t/controllers/game_controller.dart';
import 'package:disney_t/main.dart';

void main() {
  testWidgets('player can enter a name and start the adventure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Get.put(GameController(preferences));
    expect(GameController.missions.length, 10);
    expect(GameController.developerStartMissionNumber, 1);
    expect(GameController.missions.last.title, '樂佩的生日天燈');
    expect(GameController.missions.last.rewardName, '樂佩的太陽天燈');
    await tester.pumpWidget(const MagicKingdomGame(preloadAssets: false));
    expect(find.text('生日專屬\n迪士尼'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '小星');
    await tester.tap(find.text('開始生日冒險'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('我是米奇，歡迎來到我的城堡'), findsOneWidget);
    expect(find.text('小星'), findsWidgets);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('繼續'));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('米斯嘎、穆斯嘎、米老鼠～'), findsOneWidget);
    await tester.tap(find.text('一起唸咒語'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('米奇的生日任務卷軸'), findsOneWidget);
    expect(find.text('神秘任務 1'), findsOneWidget);
    expect(find.text('布魯托的狗骨頭'), findsNothing);
    expect(find.textContaining('狗骨頭'), findsNothing);
    expect(find.text('拯救三眼怪'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('mission_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('布魯托的家'), findsOneWidget);

    expect(find.byKey(const Key('bone_hotspot')), findsNothing);
    final plutoYardRect = tester.getRect(
      find.byKey(const Key('pluto_yard_character')),
    );
    for (var i = 0; i < 6; i++) {
      expect(
        tester
            .getRect(find.byKey(ValueKey('grass_patch_$i')))
            .overlaps(plutoYardRect),
        isFalse,
      );
    }
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byKey(ValueKey('grass_patch_$i')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('新的發光草叢出現'), findsOneWidget);
    expect(find.byKey(const Key('bone_hotspot')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bone_hotspot')));
    await tester.pump();
    expect(find.byKey(const Key('bone_to_inventory')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();
    expect(find.textContaining('骨頭已放進道具欄'), findsOneWidget);
    expect(find.text('生日冒險道具欄'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('inventory_slot_0')));
    await tester.pump();
    expect(find.byKey(const Key('bone_to_pluto')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.byKey(const Key('pluto_has_bone')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2700));
    expect(find.byKey(const ValueKey('pluto_story_next_1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pluto_story_next_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1950));
    await tester.pump();
    expect(find.byKey(const ValueKey('pluto_story_next_2')), findsOneWidget);
    expect(find.byKey(const Key('pluto_returns_with_sock')), findsOneWidget);
    expect(find.byKey(const Key('pluto_sock_return')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pluto_story_next_2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('sock_to_inventory')), findsOneWidget);
    final plutoSceneStack = tester.widget<Stack>(
      find.byKey(const Key('pluto_scene_stack')),
    );
    final inventoryLayerIndex = plutoSceneStack.children.indexWhere(
      (child) => child.key == const Key('pluto_inventory_layer'),
    );
    final rewardOverlayIndex = plutoSceneStack.children.indexWhere(
      (child) => child.key == const Key('pluto_reward_overlay'),
    );
    expect(rewardOverlayIndex, greaterThan(inventoryLayerIndex));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('布魯托的家'), findsNothing);
    expect(find.text('布魯托'), findsOneWidget);
    expect(Get.find<GameController>().inventory.first?.name, '高飛狗的綠襪子');

    expect(find.text('開始下一個神秘任務'), findsOneWidget);
    expect(find.textContaining('安迪'), findsNothing);
    expect(find.textContaining('三眼怪'), findsNothing);
    await tester.tap(find.text('開始下一個神秘任務'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第二關：安迪的房間'), findsOneWidget);
    expect(find.textContaining('三眼怪不見了'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('繼續'));
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.textContaining('先打贏我再說'), findsOneWidget);
    await tester.tap(find.text('迎戰札克'));
    await tester.pump();
    expect(find.textContaining('命中 5 次'), findsOneWidget);
    final firstDodgePosition = Get.find<GameController>().zurgDodgeIndex.value;
    for (
      var wait = 0;
      wait < 8 &&
          Get.find<GameController>().zurgDodgeIndex.value == firstDodgePosition;
      wait++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      Get.find<GameController>().zurgDodgeIndex.value,
      isNot(firstDodgePosition),
    );
    for (var i = 0; i < 10; i++) {
      final previous = Get.find<GameController>().zurgDodgeIndex.value;
      Get.find<GameController>().dodgeZurg();
      expect(Get.find<GameController>().zurgDodgeIndex.value, isNot(previous));
    }

    await tester.tap(find.byKey(const Key('zurg_target')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(Get.find<GameController>().zurgHealth.value, 4);
    expect(find.byKey(const Key('zurg_damage_flash')), findsOneWidget);
    expect(find.byKey(const ValueKey('zurg_hit_feedback_4')), findsOneWidget);
    expect(find.text('命中札克！剩餘 4'), findsOneWidget);
    expect(find.text('札克能量 4 / 5'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 720));
    expect(find.byKey(const ValueKey('zurg_hit_feedback_4')), findsNothing);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('zurg_target')));
      await tester.pump(const Duration(milliseconds: 350));
    }
    expect(find.byKey(const Key('zurg_defeat_center')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2650));
    expect(find.byKey(const Key('zurg_scream')), findsOneWidget);
    expect(find.text('啊啊啊啊啊啊！'), findsOneWidget);
    expect(find.byKey(const ValueKey('zurg_defeat_next_1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zurg_defeat_next_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byKey(const ValueKey('zurg_defeat_next_2')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zurg_defeat_next_2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byKey(const Key('three_eye_reveal')), findsOneWidget);
    expect(find.text('你救了我們，我們永遠感謝你！'), findsOneWidget);
    expect(find.byKey(const ValueKey('zurg_defeat_next_3')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zurg_defeat_next_3')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('繼續聽夥伴說'));
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text('收下草莓'), findsOneWidget);
    await tester.tap(find.text('收下草莓'));
    await tester.pump();
    expect(find.byKey(const Key('strawberry_reward')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第二關：安迪的房間'), findsNothing);
    expect(Get.find<GameController>().completedMissions.value, 2);
    expect(
      Get.find<GameController>().inventory.any(
        (item) => item?.name == '熊抱哥的草莓',
      ),
      isTrue,
    );

    expect(find.text('開始下一個神秘任務'), findsOneWidget);
    expect(find.textContaining('米妮'), findsNothing);
    expect(find.textContaining('蝴蝶結'), findsNothing);
    await tester.tap(find.text('開始下一個神秘任務'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第三關：米妮的花園'), findsOneWidget);
    expect(find.byKey(const ValueKey('minnie_pink')), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byKey(ValueKey('minnie_spot_$i')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('六個地方都沒有'), findsOneWidget);
    expect(find.byKey(const Key('minnie_pluto_arrival')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1450));
    expect(find.byKey(const ValueKey('minnie_ask_pluto')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('minnie_ask_pluto')));
    await tester.pump();
    expect(find.text('汪！交給我，我來聞聞看！'), findsOneWidget);
    expect(Get.find<GameController>().minniePlutoAsked.value, isTrue);
    expect(
      find.byKey(const ValueKey('minnie_pluto_start_search')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('minnie_pluto_start_search')));
    await tester.pump();
    expect(find.byKey(const Key('pluto_sniffing')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 4250));
    expect(find.byKey(const Key('red_bow_found')), findsOneWidget);
    expect(find.byKey(const Key('minnie_bow_found_next')), findsOneWidget);
    await tester.tap(find.byKey(const Key('minnie_bow_found_next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1550));
    expect(find.byKey(const Key('pluto_carries_red_bow')), findsOneWidget);
    expect(find.byKey(const Key('minnie_search_next')), findsOneWidget);
    await tester.tap(find.byKey(const Key('minnie_search_next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const Key('red_bow_to_inventory')), findsOneWidget);
    expect(find.byKey(const Key('pluto_leaves_after_bow')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    expect(
      Get.find<GameController>().inventory.any(
        (item) => item?.name == '米妮的紅色蝴蝶結',
      ),
      isTrue,
    );
    expect(find.byKey(const Key('minnie_pluto_arrival')), findsNothing);
    expect(find.byKey(const Key('pluto_sniffing')), findsNothing);
    expect(find.byKey(const Key('pluto_carries_red_bow')), findsNothing);
    expect(find.byKey(const Key('pluto_leaves_after_bow')), findsNothing);

    final redBowSlot = Get.find<GameController>().inventory.indexWhere(
      (item) => item?.name == '米妮的紅色蝴蝶結',
    );
    await tester.tap(find.byKey(ValueKey('inventory_slot_$redBowSlot')));
    await tester.pump();
    expect(find.byKey(const Key('red_bow_to_minnie')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();
    expect(find.byKey(const ValueKey('minnie_red')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('minnie_exchange_next_1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('minnie_exchange_next_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1350));
    expect(find.byKey(const Key('pink_bow_reward')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('minnie_exchange_next_2')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('minnie_exchange_next_2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第三關：米妮的花園'), findsNothing);
    expect(Get.find<GameController>().completedMissions.value, 3);
    expect(
      Get.find<GameController>().inventory.any(
        (item) => item?.name == '米妮的粉色蝴蝶結',
      ),
      isTrue,
    );
    expect(
      Get.find<GameController>().inventory.any(
        (item) => item?.name == '米妮的紅色蝴蝶結',
      ),
      isFalse,
    );

    await tester.tap(find.text('開始下一個神秘任務'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第 4 關：雪寶的胡蘿蔔鼻子'), findsOneWidget);
    expect(find.text('安娜'), findsWidgets);
    expect(find.text('艾莎'), findsOneWidget);
    expect(find.text('雪寶'), findsOneWidget);
    expect(find.byKey(const Key('frozen_maze_background')), findsOneWidget);
    expect(find.byKey(const Key('frozen_anna')), findsOneWidget);
    expect(find.byKey(const Key('frozen_elsa')), findsOneWidget);
    expect(find.byKey(const Key('frozen_olaf_no_nose')), findsOneWidget);

    for (var step = 0; step < 3; step++) {
      await tester.tap(find.byKey(const ValueKey('frozen_dialogue_next')));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('frozen_snowball_0')), findsOneWidget);
    expect(find.byKey(const Key('frozen_maze_traveler')), findsOneWidget);
    final frozenController = Get.find<GameController>();
    for (var target = 0; target < 4; target++) {
      frozenController.followFrozenFootstep();
    }
    expect(frozenController.prototypeProgress(3), 4);
    frozenController.resetFrozenMazeAfterCollision();
    expect(frozenController.prototypeProgress(3), 0);
    for (var target = 0; target < 8; target++) {
      frozenController.followFrozenFootstep();
    }
    await tester.pump();
    expect(find.byKey(const Key('frozen_carrot')), findsOneWidget);
    await tester.tap(find.byKey(const Key('frozen_carrot')));
    await tester.pump();
    expect(find.byKey(const Key('frozen_olaf_found')), findsOneWidget);
    expect(find.byKey(const Key('frozen_olaf_has_nose')), findsOneWidget);
    expect(find.byKey(const Key('frozen_olaf_no_nose')), findsNothing);
    await tester.tap(find.byKey(const Key('frozen_reward_button')));
    await tester.pump();
    expect(find.byKey(const Key('frozen_snowflake_reward')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump(const Duration(milliseconds: 500));
    expect(Get.find<GameController>().completedMissions.value, 4);
    expect(
      Get.find<GameController>().inventory.any((item) => item?.name == '魔法雪花'),
      isTrue,
    );

    await tester.tap(find.text('開始下一個神秘任務'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第 5 關：阿拉丁的魔毯救援'), findsOneWidget);
    for (var step = 0; step < 3; step++) {
      await tester.tap(find.byKey(const Key('aladdin_dialogue_next')));
      await tester.pump();
    }
    expect(find.byKey(const Key('aladdin_carpet_player')), findsOneWidget);
    expect(find.byKey(const Key('aladdin_move_up')), findsOneWidget);
    final aladdinController = Get.find<GameController>();
    await tester.tap(find.byKey(const Key('aladdin_move_right')));
    await tester.pump();
    expect(aladdinController.aladdinPlayerColumn.value, 1);
    await tester.tap(find.byKey(const Key('aladdin_move_left')));
    await tester.pump();
    expect(aladdinController.aladdinPlayerColumn.value, 0);
    for (var wave = 0; wave < 12; wave++) {
      aladdinController.recordAladdinDodge();
    }
    await tester.pump();
    expect(find.byKey(const Key('aladdin_jafar_target')), findsOneWidget);
    for (var hit = 0; hit < 12; hit++) {
      await tester.tap(find.byKey(const Key('aladdin_jafar_target')));
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(aladdinController.aladdinJafarHealth.value, 0);
    await tester.tap(find.byKey(const Key('aladdin_rescue_genie')));
    await tester.pump();
    expect(find.byKey(const Key('aladdin_freed_genie')), findsOneWidget);
    for (final wish in ['勇氣', '幸福', '冒險', '友誼']) {
      expect(find.byKey(ValueKey('aladdin_wish_$wish')), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('aladdin_wish_冒險')));
    await tester.pump();
    expect(aladdinController.aladdinWish.value, '冒險');
    await tester.tap(find.byKey(const Key('aladdin_finish_mission')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(aladdinController.completedMissions.value, 5);
    expect(
      aladdinController.inventory.any((item) => item?.name == '精靈的冒險願望'),
      isTrue,
    );

    final restored = GameController(preferences);
    await restored.restoreSavedGame();
    expect(restored.playerName.value, '小星');
    expect(restored.completedMissions.value, 5);
    expect(restored.stars.value, 1);
    expect(restored.plutoRecruited.value, isTrue);
    expect(restored.minniePlutoAsked.value, isTrue);
    expect(restored.inventory.first?.name, '高飛狗的綠襪子');
    expect(restored.inventory.any((item) => item?.name == '熊抱哥的草莓'), isTrue);
    expect(restored.inventory.any((item) => item?.name == '米妮的粉色蝴蝶結'), isTrue);
    expect(restored.inventory.any((item) => item?.name == '魔法雪花'), isTrue);
    expect(restored.inventory.any((item) => item?.name == '精靈的冒險願望'), isTrue);
    expect(restored.prototypeDialogueStep(3), 3);
    expect(restored.prototypeProgress(3), 9);
    expect(restored.prototypeDialogueStep(4), 3);
    expect(restored.prototypeProgress(4), 12);
    restored.onClose();

    final settingsRect = tester.getRect(
      find.byKey(const Key('home_settings_button')),
    );
    expect(settingsRect.right, closeTo(380, .1));
    expect(settingsRect.top, closeTo(10, .1));
    await tester.tap(find.byKey(const Key('home_settings_button')));
    await tester.pump();
    expect(find.byKey(const Key('game_settings_dialog')), findsOneWidget);
    expect(find.textContaining('無法復原'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_clear_game_data')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('生日專屬\n迪士尼'), findsOneWidget);
    expect(Get.find<GameController>().playerName.value, isEmpty);
    expect(preferences.getString('birthday_disney_save_v1'), isNull);
    expect(
      Get.find<GameController>().inventory.whereType<InventoryItem>(),
      isEmpty,
    );
    expect(Get.find<GameController>().prototypeDialogueSteps, isEmpty);
    expect(Get.find<GameController>().prototypeActionProgress, isEmpty);
  });
}
