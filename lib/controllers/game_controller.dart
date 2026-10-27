import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/game_widgets.dart';

class StoryLine {
  const StoryLine({required this.speaker, required this.text});
  final String speaker;
  final String text;
}

class Mission {
  const Mission({
    required this.title,
    required this.description,
    required this.action,
    required this.rewardIcon,
    required this.rewardName,
  });

  final String title;
  final String description;
  final String action;
  final String rewardIcon;
  final String rewardName;
}

class InventoryItem {
  const InventoryItem({
    required this.icon,
    required this.name,
    required this.description,
    this.quantity = 1,
  });

  final String icon;
  final String name;
  final String description;
  final int quantity;

  InventoryItem copyWith({int? quantity}) => InventoryItem(
    icon: icon,
    name: name,
    description: description,
    quantity: quantity ?? this.quantity,
  );

  Map<String, Object> toJson() => {
    'icon': icon,
    'name': name,
    'description': description,
    'quantity': quantity,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    icon: json['icon'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 1,
  );
}

class GameController extends GetxController {
  GameController([this._preferences]);

  static const _saveKey = 'birthday_disney_save_v1';
  final SharedPreferences? _preferences;
  final nameController = TextEditingController();
  final playerName = ''.obs;
  final dialogueIndex = 0.obs;
  final stars = 0.obs;
  final questStarted = false.obs;
  final castleGlowing = false.obs;
  final missionScrollVisible = false.obs;
  final completedMissions = 0.obs;
  final searchedPlutoGrass = <int>[].obs;
  final plutoBoneFound = false.obs;
  final plutoBoneCollecting = false.obs;
  final boneGiving = false.obs;
  final plutoRecruited = false.obs;
  final inventory = <InventoryItem?>[].obs;
  final Random _random = Random();

  bool get hasSavedGame => playerName.value.isNotEmpty;
  bool get allPlutoGrassSearched => searchedPlutoGrass.length >= 6;

  static const missions = <Mission>[
    Mission(
      title: '布魯托的狗骨頭',
      description: '布魯托現在很餓，幫它在家附近找到狗骨頭。',
      action: '前往布魯托的家',
      rewardIcon: '🦴',
      rewardName: '狗骨頭',
    ),
    Mission(
      title: '米奇的金色鑰匙',
      description: '幫米奇在花園小徑尋找遺失的鑰匙。',
      action: '搜索花園',
      rewardIcon: '🗝️',
      rewardName: '金色鑰匙',
    ),
    Mission(
      title: '噴水池的星光',
      description: '調查城堡噴水池旁閃爍的光芒。',
      action: '搜索噴水池',
      rewardIcon: '✨',
      rewardName: '魔法星屑',
    ),
    Mission(
      title: '城堡生日彩帶',
      description: '收集散落在廣場的紫色生日彩帶。',
      action: '收集彩帶',
      rewardIcon: '🎀',
      rewardName: '皇家彩帶',
    ),
    Mission(
      title: '唐老鴨的水手帽',
      description: '到湖畔找回被風吹走的水手帽。',
      action: '前往湖畔',
      rewardIcon: '🧢',
      rewardName: '水手帽',
    ),
    Mission(
      title: '黛西的蝴蝶結',
      description: '在玫瑰花園找出最漂亮的蝴蝶結。',
      action: '搜索玫瑰園',
      rewardIcon: '🎀',
      rewardName: '粉紅蝴蝶結',
    ),
    Mission(
      title: '第一座星光門',
      description: '使用收集到的魔力開啟星光門。',
      action: '開啟星光門',
      rewardIcon: '⭐',
      rewardName: '星光徽章',
    ),
    Mission(
      title: '高飛的釣魚竿',
      description: '在河岸協助高飛修好釣魚竿。',
      action: '修理釣竿',
      rewardIcon: '🎣',
      rewardName: '魔法釣竿',
    ),
    Mission(
      title: '森林中的音符',
      description: '聆聽森林，找出三個躲起來的音符。',
      action: '聆聽森林',
      rewardIcon: '🎵',
      rewardName: '快樂音符',
    ),
    Mission(
      title: '茶杯迷宮',
      description: '通過旋轉茶杯組成的奇妙迷宮。',
      action: '挑戰迷宮',
      rewardIcon: '☕',
      rewardName: '迷你茶杯',
    ),
    Mission(
      title: '小飛象的羽毛',
      description: '在雲朵步道尋找閃亮的幸運羽毛。',
      action: '搜索雲端',
      rewardIcon: '🪶',
      rewardName: '幸運羽毛',
    ),
    Mission(
      title: '海盜藏寶圖',
      description: '拼好四張碎片，找出海盜寶藏位置。',
      action: '拼合地圖',
      rewardIcon: '🗺️',
      rewardName: '藏寶圖',
    ),
    Mission(
      title: '幽靈宅邸的蠟燭',
      description: '點亮宅邸入口三根熄滅的蠟燭。',
      action: '點亮蠟燭',
      rewardIcon: '🕯️',
      rewardName: '幽光蠟燭',
    ),
    Mission(
      title: '仙女的魔法粉',
      description: '在月光花叢中收集閃亮的魔法粉。',
      action: '採集魔法粉',
      rewardIcon: '🧚',
      rewardName: '仙女粉末',
    ),
    Mission(
      title: '第二座星光門',
      description: '解開城牆上的星座排列謎題。',
      action: '排列星座',
      rewardIcon: '🌟',
      rewardName: '星座寶石',
    ),
    Mission(
      title: '冰雪水晶',
      description: '在冰晶洞穴中找到不會融化的水晶。',
      action: '探索冰洞',
      rewardIcon: '💎',
      rewardName: '冰雪水晶',
    ),
    Mission(
      title: '魔法地毯競速',
      description: '乘上魔法地毯飛越三個金色圓環。',
      action: '開始競速',
      rewardIcon: '🪄',
      rewardName: '飛行徽章',
    ),
    Mission(
      title: '獅子王的勇氣',
      description: '登上榮耀石，通過勇氣的考驗。',
      action: '接受考驗',
      rewardIcon: '🦁',
      rewardName: '勇氣徽章',
    ),
    Mission(
      title: '生日蛋糕材料',
      description: '收集糖霜、莓果與一顆魔法櫻桃。',
      action: '製作蛋糕',
      rewardIcon: '🎂',
      rewardName: '生日蛋糕',
    ),
    Mission(
      title: '城堡生日煙火',
      description: '和米奇一起點亮最終星星與生日煙火。',
      action: '點亮煙火',
      rewardIcon: '🏰',
      rewardName: '夢幻皇冠',
    ),
  ];

  List<StoryLine> get story => [
    StoryLine(speaker: '米奇', text: '嗨，${playerName.value}！我是米奇，歡迎來到我的城堡！'),
    const StoryLine(
      speaker: '米奇',
      text: '啊！今天是你的生日！在我的樂園裡面，你必須完成多個任務，才能得到最終大獎。',
    ),
    const StoryLine(speaker: '米奇', text: '準備好了嗎？'),
    const StoryLine(speaker: '米奇', text: '首先，先來跟我唸個咒語。'),
    const StoryLine(speaker: '米奇', text: '米斯嘎、穆斯嘎、米老鼠～'),
  ];

  bool get isLastDialogue => dialogueIndex.value >= story.length - 1;
  bool get allMissionsCompleted => completedMissions.value >= missions.length;
  Mission get currentMission =>
      missions[completedMissions.value.clamp(0, missions.length - 1)];

  String get mickeyHint {
    if (allMissionsCompleted) return '米奇：太棒了！20 個生日任務全部完成！';
    if (completedMissions.value == 0 && !plutoRecruited.value) {
      return '米奇：布魯托現在很餓，需要你幫它找到它的狗骨頭。打開任務卷軸開始吧！';
    }
    return '米奇：下一步「${currentMission.title}」— ${currentMission.description}';
  }

  Future<void> restoreSavedGame() async {
    final raw = _preferences?.getString(_saveKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final save = jsonDecode(raw) as Map<String, dynamic>;
      final savedName = save['playerName'] as String? ?? '';
      if (savedName.trim().isEmpty) return;
      playerName.value = savedName;
      nameController.text = savedName;
      dialogueIndex.value = (save['dialogueIndex'] as int? ?? 0).clamp(
        0,
        story.length - 1,
      );
      stars.value = (save['stars'] as int? ?? 0).clamp(0, 3);
      questStarted.value = save['questStarted'] as bool? ?? false;
      completedMissions.value = (save['completedMissions'] as int? ?? 0).clamp(
        0,
        missions.length,
      );
      plutoBoneFound.value = save['plutoBoneFound'] as bool? ?? false;
      plutoRecruited.value = save['plutoRecruited'] as bool? ?? false;
      final savedGrass =
          save['searchedPlutoGrass'] as List<dynamic>? ?? const [];
      searchedPlutoGrass.assignAll(
        savedGrass.whereType<int>().where((index) => index >= 0 && index < 6),
      );
      final savedInventory = save['inventory'] as List<dynamic>? ?? const [];
      inventory.assignAll(
        List<InventoryItem?>.generate(10, (index) {
          if (index >= savedInventory.length || savedInventory[index] == null) {
            return null;
          }
          return InventoryItem.fromJson(
            Map<String, dynamic>.from(savedInventory[index] as Map),
          );
        }),
      );
      castleGlowing.value = false;
      missionScrollVisible.value = false;
      boneGiving.value = false;
      plutoBoneCollecting.value = false;
    } catch (_) {
      await _preferences?.remove(_saveKey);
    }
  }

  Future<void> _saveGame() async {
    if (_preferences == null || playerName.value.isEmpty) return;
    final save = <String, dynamic>{
      'playerName': playerName.value,
      'dialogueIndex': dialogueIndex.value,
      'stars': stars.value,
      'questStarted': questStarted.value,
      'completedMissions': completedMissions.value,
      'plutoBoneFound': plutoBoneFound.value,
      'plutoRecruited': plutoRecruited.value,
      'searchedPlutoGrass': searchedPlutoGrass.toList(),
      'inventory': inventory.map((item) => item?.toJson()).toList(),
    };
    await _preferences.setString(_saveKey, jsonEncode(save));
  }

  void startAdventure() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        '還差一步',
        '請先告訴我們你的名字喔！',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }
    playerName.value = name;
    dialogueIndex.value = 0;
    questStarted.value = false;
    castleGlowing.value = false;
    missionScrollVisible.value = false;
    stars.value = 0;
    completedMissions.value = 0;
    searchedPlutoGrass.clear();
    plutoBoneFound.value = false;
    plutoBoneCollecting.value = false;
    boneGiving.value = false;
    plutoRecruited.value = false;
    inventory.assignAll(List<InventoryItem?>.filled(10, null));
    _saveGame();
    Get.offNamed('/adventure');
  }

  Future<void> nextDialogue() async {
    if (!isLastDialogue) {
      dialogueIndex.value++;
      _saveGame();
      return;
    }
    if (castleGlowing.value) return;
    castleGlowing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    missionScrollVisible.value = true;
    _saveGame();
  }

  void openMissionScroll() {
    if (!questStarted.value || missionScrollVisible.value) return;
    missionScrollVisible.value = true;
  }

  void closeMissionScroll() {
    missionScrollVisible.value = false;
    castleGlowing.value = false;
    questStarted.value = true;
    _saveGame();
  }

  void enterMission(int index) {
    if (index != completedMissions.value || allMissionsCompleted) return;
    missionScrollVisible.value = false;
    castleGlowing.value = false;
    questStarted.value = true;
    if (index == 0 && !plutoRecruited.value) {
      Get.toNamed('/pluto-home');
      return;
    }
    Get.snackbar('任務已開啟', missions[index].description);
  }

  void findPlutoBone() {
    if (plutoBoneFound.value ||
        plutoBoneCollecting.value ||
        !allPlutoGrassSearched) {
      return;
    }
    plutoBoneFound.value = true;
    plutoBoneCollecting.value = true;
  }

  Future<void> completeBoneCollection() async {
    if (!plutoBoneCollecting.value) return;
    _addItem(
      const InventoryItem(
        icon: '🦴',
        name: '狗骨頭',
        description: '在布魯托家院子的草叢裡找到的。',
      ),
    );
    plutoBoneCollecting.value = false;
    await _saveGame();
  }

  void searchPlutoGrass(int index) {
    if (index < 0 || index >= 6 || searchedPlutoGrass.contains(index)) return;
    searchedPlutoGrass.add(index);
    _saveGame();
  }

  void giveBoneToPluto() {
    if (boneGiving.value || plutoRecruited.value) return;
    final boneIndex = inventory.indexWhere((item) => item?.name == '狗骨頭');
    if (boneIndex < 0) return;
    inventory[boneIndex] = null;
    boneGiving.value = true;
  }

  Future<void> completePlutoMission() async {
    if (!boneGiving.value || plutoRecruited.value) return;
    plutoRecruited.value = true;
    completedMissions.value = 1;
    stars.value = min(3, stars.value + 1);
    boneGiving.value = false;
    await _saveGame();
    Get.back();
  }

  void performCurrentMission() {
    if (allMissionsCompleted) return;
    if (completedMissions.value == 0 && !plutoRecruited.value) {
      openMissionScroll();
      return;
    }
    final missionIndex = completedMissions.value;
    final mission = missions[missionIndex];
    final foundItem = missionIndex == 0 || _random.nextDouble() < .65;
    var itemStored = false;
    if (foundItem) {
      itemStored = _addItem(
        InventoryItem(
          icon: mission.rewardIcon,
          name: mission.rewardName,
          description: '完成「${mission.title}」時獲得。',
        ),
      );
    }
    completedMissions.value++;
    if (missionIndex == 0 || missionIndex == 6 || missionIndex == 14) {
      stars.value = min(3, stars.value + 1);
    }
    _saveGame();

    final rewardText = !foundItem
        ? '這次沒有發現道具，但任務已完成。'
        : itemStored
        ? '找到 ${mission.rewardIcon} ${mission.rewardName}，已放進道具欄！'
        : '找到 ${mission.rewardName}，但道具欄已滿。';
    Get.dialog(
      AlertDialog(
        title: Text('✅ 完成：${mission.title}'),
        content: Text(
          '$rewardText\n\n${allMissionsCompleted ? '所有生日任務完成！' : mickeyHint}',
        ),
        actions: [
          MagicButton(
            onPressed: Get.back,
            label: '繼續冒險',
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
        ],
      ),
    );
  }

  bool _addItem(InventoryItem item) {
    final existing = inventory.indexWhere((slot) => slot?.name == item.name);
    if (existing >= 0) {
      inventory[existing] = inventory[existing]!.copyWith(
        quantity: inventory[existing]!.quantity + 1,
      );
      return true;
    }
    final empty = inventory.indexWhere((slot) => slot == null);
    if (empty < 0) return false;
    inventory[empty] = item;
    return true;
  }

  void inspectItem(int index) {
    final item = inventory[index];
    if (item == null) return;
    Get.snackbar(
      '${item.icon} ${item.name}',
      '${item.description}\n持有數量：${item.quantity}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
