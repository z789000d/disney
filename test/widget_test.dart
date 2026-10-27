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
    await tester.pumpWidget(const MagicKingdomGame());
    expect(find.text('生日專屬\n迪士尼'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '小星');
    await tester.tap(find.text('開始生日冒險'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('我是米奇，歡迎來到我的城堡'), findsOneWidget);
    expect(find.text('👑 小星'), findsOneWidget);

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
    expect(find.text('布魯托的狗骨頭'), findsOneWidget);
    expect(find.text('米奇的金色鑰匙'), findsNothing);
    await tester.tap(find.text('布魯托的狗骨頭'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('🏡 布魯托的家'), findsOneWidget);

    expect(find.byKey(const Key('bone_hotspot')), findsNothing);
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
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('🏡 布魯托的家'), findsNothing);
    expect(find.text('布魯托'), findsOneWidget);

    final restored = GameController(preferences);
    await restored.restoreSavedGame();
    expect(restored.playerName.value, '小星');
    expect(restored.completedMissions.value, 1);
    expect(restored.stars.value, 1);
    expect(restored.plutoRecruited.value, isTrue);
    restored.onClose();
  });
}
