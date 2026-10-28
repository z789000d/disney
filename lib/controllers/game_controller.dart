import 'dart:async';
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
  final toyDialogueIndex = 0.obs;
  final toyBattleActive = false.obs;
  final zurgHealth = 5.obs;
  final zurgDodgeIndex = 0.obs;
  final zurgHitFeedback = false.obs;
  final zurgHitSequence = 0.obs;
  final toyDefeatAnimating = false.obs;
  final toyBattleWon = false.obs;
  final toyThanksIndex = 0.obs;
  final toyRewardGiving = false.obs;
  final searchedMinnieSpots = <int>[].obs;
  final minniePlutoSearching = false.obs;
  final minnieRedBowFound = false.obs;
  final minnieBowReturned = false.obs;
  final minnieRewardGiving = false.obs;
  final inventory = <InventoryItem?>[].obs;
  final Random _random = Random();
  Timer? _zurgHitFeedbackTimer;

  bool get hasSavedGame => playerName.value.isNotEmpty;
  bool get allPlutoGrassSearched => searchedPlutoGrass.length >= 6;
  bool get allMinnieSpotsSearched => searchedMinnieSpots.length >= 6;

  static const missions = <Mission>[
    Mission(
      title: '布魯托的狗骨頭',
      description: '布魯托現在很餓，幫它在家附近找到狗骨頭。',
      action: '前往布魯托的家',
      rewardIcon: '🧦',
      rewardName: '高飛狗的綠襪子',
    ),
    Mission(
      title: '拯救三眼怪',
      description: '前往安迪的房間，擊敗札克並救回三眼怪。',
      action: '前往安迪的房間',
      rewardIcon: '🍓',
      rewardName: '熊抱哥的草莓',
    ),
    Mission(
      title: '米妮的紅色蝴蝶結',
      description: '前往米妮花園，幫米妮找回不見的紅色蝴蝶結。',
      action: '前往米妮花園',
      rewardIcon: '🎀',
      rewardName: '米妮的粉色蝴蝶結',
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

  static const toyIntroStory = <StoryLine>[
    StoryLine(speaker: '胡迪', text: '糟了！三眼怪不見了，我到處都找不到他。'),
    StoryLine(speaker: '巴斯光年', text: '我們搜尋了安迪的房間，還是沒有發現三眼怪。'),
    StoryLine(speaker: '彈簧狗', text: '我聞到一股奇怪的氣味，好像是從房間另一邊傳來的！'),
    StoryLine(speaker: '熊抱哥', text: '看起來三眼怪被札克抓走了！'),
    StoryLine(speaker: '札克', text: '想救回三眼怪？先打贏我再說！'),
  ];

  List<StoryLine> get toyThanksStory => [
    const StoryLine(speaker: '三眼怪', text: '你救了我們，我們永遠感謝你！'),
    StoryLine(speaker: '胡迪', text: '幹得好，${playerName.value}！你是我們最可靠的夥伴。'),
    const StoryLine(speaker: '巴斯光年', text: '這是一場精彩的星際救援！謝謝你。'),
    const StoryLine(speaker: '彈簧狗', text: '謝謝你把我們的朋友帶回來！'),
    const StoryLine(speaker: '熊抱哥', text: '謝謝你！這顆特別的草莓就送給你。'),
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
      toyDialogueIndex.value = (save['toyDialogueIndex'] as int? ?? 0).clamp(
        0,
        toyIntroStory.length - 1,
      );
      toyBattleActive.value = save['toyBattleActive'] as bool? ?? false;
      zurgHealth.value = (save['zurgHealth'] as int? ?? 5).clamp(0, 5);
      zurgDodgeIndex.value = (save['zurgDodgeIndex'] as int? ?? 0).clamp(0, 4);
      toyBattleWon.value = save['toyBattleWon'] as bool? ?? false;
      toyDefeatAnimating.value =
          save['toyDefeatAnimating'] as bool? ??
          (zurgHealth.value == 0 && !toyBattleWon.value);
      toyThanksIndex.value = (save['toyThanksIndex'] as int? ?? 0).clamp(
        0,
        toyThanksStory.length - 1,
      );
      final savedMinnieSpots =
          save['searchedMinnieSpots'] as List<dynamic>? ?? const [];
      searchedMinnieSpots.assignAll(
        savedMinnieSpots.whereType<int>().where(
          (index) => index >= 0 && index < 6,
        ),
      );
      minniePlutoSearching.value =
          save['minniePlutoSearching'] as bool? ?? false;
      minnieRedBowFound.value = save['minnieRedBowFound'] as bool? ?? false;
      minnieBowReturned.value = save['minnieBowReturned'] as bool? ?? false;
      minnieRewardGiving.value = save['minnieRewardGiving'] as bool? ?? false;
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
      var saveNeedsUpdate = false;
      if (plutoRecruited.value && _ensurePlutoSockReward()) {
        saveNeedsUpdate = true;
      }
      // Mission two previously used the generic completion path. If that old
      // state skipped the Andy's room story, roll it back so it can be played.
      if (completedMissions.value >= 2 && !toyBattleWon.value) {
        completedMissions.value = 1;
        for (var index = 0; index < inventory.length; index++) {
          if (inventory[index]?.name == '熊抱哥的草莓') {
            inventory[index] = null;
          }
        }
        saveNeedsUpdate = true;
      }
      if (saveNeedsUpdate) await _saveGame();
      castleGlowing.value = false;
      missionScrollVisible.value = false;
      boneGiving.value = false;
      plutoBoneCollecting.value = false;
      toyRewardGiving.value = false;
      zurgHitFeedback.value = false;
      zurgHitSequence.value = 0;
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
      'toyDialogueIndex': toyDialogueIndex.value,
      'toyBattleActive': toyBattleActive.value,
      'zurgHealth': zurgHealth.value,
      'zurgDodgeIndex': zurgDodgeIndex.value,
      'toyDefeatAnimating': toyDefeatAnimating.value,
      'toyBattleWon': toyBattleWon.value,
      'toyThanksIndex': toyThanksIndex.value,
      'searchedMinnieSpots': searchedMinnieSpots.toList(),
      'minniePlutoSearching': minniePlutoSearching.value,
      'minnieRedBowFound': minnieRedBowFound.value,
      'minnieBowReturned': minnieBowReturned.value,
      'minnieRewardGiving': minnieRewardGiving.value,
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
    toyDialogueIndex.value = 0;
    toyBattleActive.value = false;
    zurgHealth.value = 5;
    zurgDodgeIndex.value = 0;
    zurgHitFeedback.value = false;
    zurgHitSequence.value = 0;
    toyDefeatAnimating.value = false;
    toyBattleWon.value = false;
    toyThanksIndex.value = 0;
    toyRewardGiving.value = false;
    searchedMinnieSpots.clear();
    minniePlutoSearching.value = false;
    minnieRedBowFound.value = false;
    minnieBowReturned.value = false;
    minnieRewardGiving.value = false;
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
    if (index == 1) {
      Get.toNamed('/andy-room');
      return;
    }
    if (index == 2) {
      Get.toNamed('/minnie-garden');
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
    _ensurePlutoSockReward();
    plutoRecruited.value = true;
    completedMissions.value = 1;
    stars.value = min(3, stars.value + 1);
    boneGiving.value = false;
    await _saveGame();
    Get.back();
  }

  bool _ensurePlutoSockReward() {
    const sock = InventoryItem(
      icon: '🧦',
      name: '高飛狗的綠襪子',
      description: '布魯托回到狗屋後送給你的第一關紀念品。',
    );
    final existingIndex = inventory.indexWhere(
      (item) => item?.name == sock.name,
    );
    if (existingIndex == 0) return false;
    if (existingIndex > 0) {
      final firstItem = inventory[0];
      inventory[0] = inventory[existingIndex];
      inventory[existingIndex] = firstItem;
      return true;
    }
    final emptyIndex = inventory.lastIndexWhere((item) => item == null);
    if (emptyIndex < 0) return false;
    for (var index = emptyIndex; index > 0; index--) {
      inventory[index] = inventory[index - 1];
    }
    inventory[0] = sock;
    return true;
  }

  void nextToyDialogue() {
    if (toyBattleActive.value || toyBattleWon.value) return;
    if (toyDialogueIndex.value < toyIntroStory.length - 1) {
      toyDialogueIndex.value++;
    } else {
      toyBattleActive.value = true;
    }
    _saveGame();
  }

  void hitZurg() {
    if (!toyBattleActive.value || zurgHealth.value <= 0) return;
    zurgHitFeedback.value = true;
    zurgHitSequence.value++;
    _zurgHitFeedbackTimer?.cancel();
    _zurgHitFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
      zurgHitFeedback.value = false;
    });
    zurgHealth.value--;
    zurgDodgeIndex.value = (zurgDodgeIndex.value + 2) % 5;
    if (zurgHealth.value == 0) {
      toyBattleActive.value = false;
      toyDefeatAnimating.value = true;
      toyBattleWon.value = false;
      toyThanksIndex.value = 0;
    }
    _saveGame();
  }

  void completeZurgDefeat() {
    if (!toyDefeatAnimating.value) return;
    toyDefeatAnimating.value = false;
    toyBattleWon.value = true;
    toyThanksIndex.value = 0;
    _saveGame();
  }

  void dodgeZurg() {
    if (!toyBattleActive.value || zurgHealth.value <= 0) return;
    zurgDodgeIndex.value = (zurgDodgeIndex.value + 1) % 5;
  }

  void nextToyThanks() {
    if (!toyBattleWon.value || toyRewardGiving.value) return;
    if (toyThanksIndex.value < toyThanksStory.length - 1) {
      toyThanksIndex.value++;
      _saveGame();
    } else {
      toyRewardGiving.value = true;
    }
  }

  Future<void> completeToyMission() async {
    if (!toyRewardGiving.value || completedMissions.value != 1) return;
    _addItem(
      const InventoryItem(
        icon: '🍓',
        name: '熊抱哥的草莓',
        description: '救回三眼怪後，熊抱哥送給你的紀念草莓。',
      ),
    );
    completedMissions.value = 2;
    toyRewardGiving.value = false;
    await _saveGame();
    Get.back();
  }

  void searchMinnieSpot(int index) {
    if (index < 0 ||
        index >= 6 ||
        searchedMinnieSpots.contains(index) ||
        minniePlutoSearching.value ||
        minnieRedBowFound.value) {
      return;
    }
    searchedMinnieSpots.add(index);
    _saveGame();
  }

  void startMinniePlutoSearch() {
    if (!allMinnieSpotsSearched ||
        minniePlutoSearching.value ||
        minnieRedBowFound.value) {
      return;
    }
    minniePlutoSearching.value = true;
    _saveGame();
  }

  Future<void> completeMinniePlutoSearch() async {
    if (!minniePlutoSearching.value || minnieRedBowFound.value) return;
    _addItem(
      const InventoryItem(
        icon: '🎀',
        name: '米妮的紅色蝴蝶結',
        description: '布魯托在米妮花園裡聞到並找回的蝴蝶結。',
      ),
    );
    minniePlutoSearching.value = false;
    minnieRedBowFound.value = true;
    await _saveGame();
  }

  void returnRedBowToMinnie() {
    if (!minnieRedBowFound.value || minnieRewardGiving.value) return;
    final bowIndex = inventory.indexWhere((item) => item?.name == '米妮的紅色蝴蝶結');
    if (bowIndex < 0) return;
    inventory[bowIndex] = null;
    minnieRewardGiving.value = true;
    _saveGame();
  }

  void markMinnieBowReturned() {
    if (!minnieRewardGiving.value || minnieBowReturned.value) return;
    minnieBowReturned.value = true;
    _saveGame();
  }

  Future<void> completeMinnieMission() async {
    if (!minnieRewardGiving.value || completedMissions.value != 2) return;
    _addItem(
      const InventoryItem(
        icon: '🎀',
        name: '米妮的粉色蝴蝶結',
        description: '米妮為了感謝你找回紅色蝴蝶結而送的禮物。',
      ),
    );
    completedMissions.value = 3;
    minnieRewardGiving.value = false;
    await _saveGame();
    Get.back();
  }

  void performCurrentMission() {
    if (allMissionsCompleted) return;
    if (completedMissions.value == 0 && !plutoRecruited.value) {
      openMissionScroll();
      return;
    }
    if (completedMissions.value == 1) {
      Get.toNamed('/andy-room');
      return;
    }
    if (completedMissions.value == 2) {
      Get.toNamed('/minnie-garden');
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
      item.name,
      '${item.description}\n持有數量：${item.quantity}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
  }

  @override
  void onClose() {
    _zurgHitFeedbackTimer?.cancel();
    nameController.dispose();
    super.onClose();
  }
}
