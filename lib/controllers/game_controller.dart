import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // Example: flutter run --dart-define=START_MISSION=5
  static const developerStartMissionNumber = int.fromEnvironment(
    'START_MISSION',
    defaultValue: 1,
  );
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
  final minniePlutoAsked = false.obs;
  final minniePlutoSearching = false.obs;
  final minnieRedBowFound = false.obs;
  final minnieBowReturned = false.obs;
  final minnieRewardGiving = false.obs;
  final prototypeDialogueSteps = <int, int>{}.obs;
  final prototypeActionProgress = <int, int>{}.obs;
  final aladdinPlayerColumn = 0.obs;
  final aladdinPlayerRow = 1.obs;
  final aladdinJafarHealth = 12.obs;
  final aladdinGenieRescued = false.obs;
  final aladdinWish = ''.obs;
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
      rewardIcon: 'sock',
      rewardName: '高飛狗的綠襪子',
    ),
    Mission(
      title: '拯救三眼怪',
      description: '前往安迪的房間，擊敗札克並救回三眼怪。',
      action: '前往安迪的房間',
      rewardIcon: 'strawberry',
      rewardName: '熊抱哥的草莓',
    ),
    Mission(
      title: '米妮的紅色蝴蝶結',
      description: '前往米妮花園，幫米妮找回不見的紅色蝴蝶結。',
      action: '前往米妮花園',
      rewardIcon: 'bow',
      rewardName: '米妮的粉色蝴蝶結',
    ),
    Mission(
      title: '雪寶的胡蘿蔔鼻子',
      description: '和安娜、艾莎穿過冰雪迷宮，替雪寶找回被風吹走的胡蘿蔔鼻子。',
      action: '前往艾倫戴爾',
      rewardIcon: 'carrot',
      rewardName: '魔法雪花',
    ),
    Mission(
      title: '阿拉丁的魔毯救援',
      description: '操控阿拉丁的魔毯閃避賈方魔法，擊敗賈方並從神燈中救回精靈。',
      action: '飛往阿格拉巴',
      rewardIcon: 'wish',
      rewardName: '精靈的一個願望',
    ),
    Mission(
      title: '辛巴的勇氣試煉',
      description: '跟著拉飛奇的鼓聲前進，和丁滿、彭彭一起引導辛巴回到榮耀石。',
      action: '前往榮耀大地',
      rewardIcon: 'paw_badge',
      rewardName: '勇氣爪印徽章',
    ),
    Mission(
      title: '史迪奇的唱片派對',
      description: '幫莉蘿收集被史迪奇弄亂的唱片，依照節奏修好海灘派對。',
      action: '前往夏威夷海灘',
      rewardIcon: 'hibiscus',
      rewardName: '紅色扶桑花',
    ),
    Mission(
      title: '貝兒的魔法玫瑰',
      description: '和貝兒、燭台盧米亞、時鐘葛士華合作，解開城堡機關救回玫瑰花瓣。',
      action: '進入野獸城堡',
      rewardIcon: 'rose',
      rewardName: '魔法玫瑰花瓣',
    ),
    Mission(
      title: '小熊維尼的蜂蜜迷宮',
      description: '跳跳虎把蜂蜜罐弄亂了，和小豬一起走過百畝森林，把正確蜂蜜送給維尼。',
      action: '前往百畝森林',
      rewardIcon: 'honey',
      rewardName: '友情蜂蜜罐',
    ),
    Mission(
      title: '樂佩的生日天燈',
      description: '和樂佩、帕斯卡、尤金找回太陽徽章碎片，完成王國天燈慶典並開啟生日大獎。',
      action: '前往科洛娜王國',
      rewardIcon: 'sun_lantern',
      rewardName: '樂佩的太陽天燈',
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

  String lobbyMissionTitle(int index) => index < completedMissions.value
      ? missions[index].title
      : '神秘任務 ${index + 1}';

  String lobbyMissionDescription(int index) {
    if (index < completedMissions.value) return missions[index].description;
    if (index == completedMissions.value && !allMissionsCompleted) {
      return '進入任務場景後才會揭曉內容。';
    }
    return '完成前一項任務後解鎖。';
  }

  String get mickeyHint {
    if (allMissionsCompleted) return '米奇：太棒了！10 個生日任務全部完成！';
    return '米奇：下一個是神秘任務 ${completedMissions.value + 1}，進入任務場景後才會揭曉內容！';
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
      minniePlutoAsked.value =
          save['minniePlutoAsked'] as bool? ??
          (save['minniePlutoSearching'] as bool? ?? false);
      minniePlutoSearching.value =
          save['minniePlutoSearching'] as bool? ?? false;
      minnieRedBowFound.value = save['minnieRedBowFound'] as bool? ?? false;
      minnieBowReturned.value = save['minnieBowReturned'] as bool? ?? false;
      minnieRewardGiving.value = save['minnieRewardGiving'] as bool? ?? false;
      _restorePrototypeMap(
        save['prototypeDialogueSteps'],
        prototypeDialogueSteps,
      );
      _restorePrototypeMap(
        save['prototypeActionProgress'],
        prototypeActionProgress,
      );
      aladdinPlayerColumn.value = (save['aladdinPlayerColumn'] as int? ?? 0)
          .clamp(0, 2);
      aladdinPlayerRow.value = (save['aladdinPlayerRow'] as int? ?? 1).clamp(
        0,
        2,
      );
      aladdinJafarHealth.value = (save['aladdinJafarHealth'] as int? ?? 12)
          .clamp(0, 12);
      aladdinGenieRescued.value = save['aladdinGenieRescued'] as bool? ?? false;
      aladdinWish.value = save['aladdinWish'] as String? ?? '';
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
      'minniePlutoAsked': minniePlutoAsked.value,
      'minniePlutoSearching': minniePlutoSearching.value,
      'minnieRedBowFound': minnieRedBowFound.value,
      'minnieBowReturned': minnieBowReturned.value,
      'minnieRewardGiving': minnieRewardGiving.value,
      'prototypeDialogueSteps': prototypeDialogueSteps.map(
        (key, value) => MapEntry('$key', value),
      ),
      'prototypeActionProgress': prototypeActionProgress.map(
        (key, value) => MapEntry('$key', value),
      ),
      'aladdinPlayerColumn': aladdinPlayerColumn.value,
      'aladdinPlayerRow': aladdinPlayerRow.value,
      'aladdinJafarHealth': aladdinJafarHealth.value,
      'aladdinGenieRescued': aladdinGenieRescued.value,
      'aladdinWish': aladdinWish.value,
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
    minniePlutoAsked.value = false;
    minniePlutoSearching.value = false;
    minnieRedBowFound.value = false;
    minnieBowReturned.value = false;
    minnieRewardGiving.value = false;
    prototypeDialogueSteps.clear();
    prototypeActionProgress.clear();
    _resetAladdinState();
    inventory.assignAll(List<InventoryItem?>.filled(10, null));
    _applyDeveloperStartMission();
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
    if (index == 3) {
      Get.toNamed('/frozen-maze');
      return;
    }
    if (index == 4) {
      Get.toNamed('/aladdin-flight');
      return;
    }
    Get.toNamed('/mission/${index + 1}');
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
        icon: 'bone',
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
      icon: 'sock',
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
    _moveZurgToRandomPosition();
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
    _moveZurgToRandomPosition();
  }

  void _moveZurgToRandomPosition() {
    const positionCount = 5;
    final current = zurgDodgeIndex.value;
    var next = _random.nextInt(positionCount - 1);
    if (next >= current) next++;
    zurgDodgeIndex.value = next;
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
        icon: 'strawberry',
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
        !minniePlutoAsked.value ||
        minniePlutoSearching.value ||
        minnieRedBowFound.value) {
      return;
    }
    minniePlutoSearching.value = true;
    _saveGame();
  }

  void askMinniePlutoForHelp() {
    if (!allMinnieSpotsSearched ||
        minniePlutoAsked.value ||
        minniePlutoSearching.value ||
        minnieRedBowFound.value) {
      return;
    }
    minniePlutoAsked.value = true;
    _saveGame();
  }

  Future<void> completeMinniePlutoSearch() async {
    if (!minniePlutoSearching.value || minnieRedBowFound.value) return;
    _addItem(
      const InventoryItem(
        icon: 'red_bow',
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
        icon: 'pink_bow',
        name: '米妮的粉色蝴蝶結',
        description: '米妮為了感謝你找回紅色蝴蝶結而送的禮物。',
      ),
    );
    completedMissions.value = 3;
    minnieRewardGiving.value = false;
    await _saveGame();
    Get.back();
  }

  Future<void> clearAllGameData() async {
    _zurgHitFeedbackTimer?.cancel();
    await _preferences?.remove(_saveKey);
    nameController.clear();
    playerName.value = '';
    dialogueIndex.value = 0;
    stars.value = 0;
    questStarted.value = false;
    castleGlowing.value = false;
    missionScrollVisible.value = false;
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
    minniePlutoAsked.value = false;
    minniePlutoSearching.value = false;
    minnieRedBowFound.value = false;
    minnieBowReturned.value = false;
    minnieRewardGiving.value = false;
    prototypeDialogueSteps.clear();
    prototypeActionProgress.clear();
    _resetAladdinState();
    inventory.assignAll(List<InventoryItem?>.filled(10, null));
    Get.offAllNamed('/');
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
    if (completedMissions.value == 3) {
      Get.toNamed('/frozen-maze');
      return;
    }
    if (completedMissions.value == 4) {
      Get.toNamed('/aladdin-flight');
      return;
    }
    Get.toNamed('/mission/${completedMissions.value + 1}');
  }

  void moveAladdin(int columnDelta, int rowDelta) {
    if (completedMissions.value != 4 ||
        prototypeDialogueStep(4) < 3 ||
        prototypeProgress(4) >= 12) {
      return;
    }
    aladdinPlayerColumn.value = (aladdinPlayerColumn.value + columnDelta).clamp(
      0,
      2,
    );
    aladdinPlayerRow.value = (aladdinPlayerRow.value + rowDelta).clamp(0, 2);
    _saveGame();
  }

  void recordAladdinDodge() {
    if (completedMissions.value != 4 ||
        prototypeDialogueStep(4) < 3 ||
        prototypeProgress(4) >= 12) {
      return;
    }
    prototypeActionProgress[4] = prototypeProgress(4) + 1;
    _saveGame();
  }

  void hitAladdinJafar() {
    if (completedMissions.value != 4 ||
        prototypeProgress(4) < 12 ||
        aladdinJafarHealth.value <= 0 ||
        aladdinGenieRescued.value) {
      return;
    }
    aladdinJafarHealth.value--;
    _saveGame();
  }

  void rescueAladdinGenie() {
    if (completedMissions.value != 4 ||
        aladdinJafarHealth.value > 0 ||
        aladdinGenieRescued.value) {
      return;
    }
    aladdinGenieRescued.value = true;
    _saveGame();
  }

  void chooseAladdinWish(String wish) {
    const choices = {'勇氣', '幸福', '冒險', '友誼'};
    if (completedMissions.value != 4 ||
        !aladdinGenieRescued.value ||
        !choices.contains(wish)) {
      return;
    }
    aladdinWish.value = wish;
    _saveGame();
  }

  Future<void> completeAladdinMission() async {
    if (completedMissions.value != 4 ||
        !aladdinGenieRescued.value ||
        aladdinWish.value.isEmpty) {
      return;
    }
    _addItem(
      InventoryItem(
        icon: 'wish',
        name: '精靈的${aladdinWish.value}願望',
        description: '從神燈救回精靈後，精靈送給你的生日願望。',
      ),
    );
    completedMissions.value = 5;
    await _saveGame();
    Get.back();
  }

  void followFrozenFootstep() {
    if (completedMissions.value != 3 ||
        prototypeDialogueStep(3) < 3 ||
        prototypeProgress(3) >= 8) {
      return;
    }
    prototypeActionProgress[3] = prototypeProgress(3) + 1;
    _saveGame();
  }

  void resetFrozenMazeAfterCollision() {
    if (completedMissions.value != 3 || prototypeProgress(3) >= 8) return;
    prototypeActionProgress[3] = 0;
    _saveGame();
  }

  void collectFrozenCarrot() {
    if (completedMissions.value != 3 || prototypeProgress(3) != 8) return;
    prototypeActionProgress[3] = 9;
    _saveGame();
  }

  int prototypeDialogueStep(int missionIndex) =>
      prototypeDialogueSteps[missionIndex] ?? 0;

  int prototypeProgress(int missionIndex) =>
      prototypeActionProgress[missionIndex] ?? 0;

  void advancePrototypeDialogue(int missionIndex, int lineCount) {
    if (missionIndex != completedMissions.value || lineCount <= 0) return;
    final current = prototypeDialogueStep(missionIndex);
    prototypeDialogueSteps[missionIndex] = min(lineCount, current + 1);
    _saveGame();
  }

  void advancePrototypeAction(int missionIndex, int requiredCount) {
    if (missionIndex != completedMissions.value || requiredCount <= 0) return;
    if (prototypeDialogueStep(missionIndex) <= 0) return;
    final current = prototypeProgress(missionIndex);
    if (current >= requiredCount) return;
    prototypeActionProgress[missionIndex] = min(requiredCount, current + 1);
    _saveGame();
  }

  Future<void> completePrototypeMission(
    int missionIndex,
    int requiredCount,
  ) async {
    if (missionIndex != completedMissions.value ||
        prototypeProgress(missionIndex) < requiredCount ||
        missionIndex < 3 ||
        missionIndex >= missions.length) {
      return;
    }
    final mission = missions[missionIndex];
    _addItem(
      InventoryItem(
        icon: mission.rewardIcon,
        name: mission.rewardName,
        description: '完成「${mission.title}」後獲得的紀念品。',
      ),
    );
    completedMissions.value++;
    if (missionIndex == 6 || missionIndex == 9) {
      stars.value = min(3, stars.value + 1);
    }
    await _saveGame();
    Get.back();
  }

  void _restorePrototypeMap(dynamic raw, RxMap<int, int> target) {
    target.clear();
    if (raw is! Map) return;
    for (final entry in raw.entries) {
      final key = int.tryParse('${entry.key}');
      final value = entry.value;
      if (key != null && key >= 3 && key < missions.length && value is int) {
        target[key] = max(0, value);
      }
    }
  }

  void _resetAladdinState() {
    aladdinPlayerColumn.value = 0;
    aladdinPlayerRow.value = 1;
    aladdinJafarHealth.value = 12;
    aladdinGenieRescued.value = false;
    aladdinWish.value = '';
  }

  void _applyDeveloperStartMission() {
    final startMission = developerStartMissionNumber.clamp(1, missions.length);
    final skippedCount = startMission - 1;
    if (skippedCount <= 0) return;
    completedMissions.value = skippedCount;
    dialogueIndex.value = story.length - 1;
    questStarted.value = true;
    plutoRecruited.value = skippedCount >= 1;
    toyBattleWon.value = skippedCount >= 2;
    zurgHealth.value = skippedCount >= 2 ? 0 : 5;
    minniePlutoAsked.value = skippedCount >= 3;
    minnieRedBowFound.value = skippedCount >= 3;
    minnieBowReturned.value = skippedCount >= 3;
    if (skippedCount >= 5) {
      aladdinJafarHealth.value = 0;
      aladdinGenieRescued.value = true;
      aladdinWish.value = '冒險';
    }
    stars.value = skippedCount >= 7 ? 2 : 1;
    for (var index = 0; index < skippedCount; index++) {
      if (index >= 3) {
        prototypeDialogueSteps[index] = 99;
        prototypeActionProgress[index] = 99;
      }
      final mission = missions[index];
      final itemName = index == 4 ? '精靈的冒險願望' : mission.rewardName;
      _addItem(
        InventoryItem(
          icon: mission.rewardIcon,
          name: itemName,
          description: '使用開發起始關卡旗標自動補上的前置任務獎勵。',
        ),
      );
    }
    if (plutoRecruited.value) _ensurePlutoSockReward();
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
