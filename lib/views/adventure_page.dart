import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class AdventurePage extends GetView<GameController> {
  const AdventurePage({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/castle_courtyard.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x22000000),
                  Colors.transparent,
                  Color(0x990C092A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Obx(
              () => Stack(
                children: [
                  if (controller.castleGlowing.value)
                    const Positioned.fill(child: _CastleMagicGlow()),
                  _topBar(),
                  _characters(),
                  if (controller.questStarted.value) _questArea(),
                  Align(alignment: Alignment.bottomCenter, child: _bottomHud()),
                  Positioned(
                    top: MediaQuery.sizeOf(context).width < 600 ? 10 : 18,
                    right: MediaQuery.sizeOf(context).width < 600 ? 10 : 18,
                    child: MagicIconButton(
                      key: const Key('home_settings_button'),
                      tooltip: '遊戲設定',
                      onPressed: _openSettings,
                      icon: Icons.settings_rounded,
                    ),
                  ),
                  if (controller.missionScrollVisible.value)
                    Positioned.fill(
                      child: MissionScrollOverlay(controller: controller),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _characters() {
    final compact = MediaQuery.sizeOf(Get.context!).width < 600;
    final speaker = controller.questStarted.value
        ? ''
        : controller.story[controller.dialogueIndex.value].speaker;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: compact
              ? controller.questStarted.value
                    ? 205
                    : 295
              : 245,
        ),
        child: IgnorePointer(
          child: AnimatedCastStage(
            princessName: controller.playerName.value,
            speaker: speaker,
            compact: compact,
            showPluto: controller.plutoRecruited.value,
          ),
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(Get.context!).width < 600 ? 10 : 18,
      MediaQuery.sizeOf(Get.context!).width < 600 ? 10 : 18,
      MediaQuery.sizeOf(Get.context!).width < 600 ? 68 : 76,
      MediaQuery.sizeOf(Get.context!).width < 600 ? 10 : 18,
    ),
    child: Row(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _pill(
              controller.playerName.value,
              false,
              icon: Icons.workspace_premium_rounded,
              compact: MediaQuery.sizeOf(Get.context!).width < 600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        MagicIconButton(
          tooltip: '查看 10 項生日任務',
          onPressed: controller.questStarted.value
              ? controller.openMissionScroll
              : null,
          icon: Icons.assignment_rounded,
          badge: '${controller.completedMissions.value}',
        ),
        const SizedBox(width: 6),
        _pill(
          '${controller.stars.value} / 3',
          true,
          icon: Icons.star_rounded,
          compact: MediaQuery.sizeOf(Get.context!).width < 600,
        ),
      ],
    ),
  );

  Widget _pill(
    String text,
    bool dark, {
    required IconData icon,
    bool compact = false,
  }) => Container(
    constraints: BoxConstraints(maxWidth: compact ? 128 : double.infinity),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 10 : 18,
      vertical: compact ? 9 : 11,
    ),
    decoration: BoxDecoration(
      color: dark ? const Color(0xEE35276D) : const Color(0xEFFFFFFF),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 16 : 18,
          color: dark ? const Color(0xFFFFDD69) : const Color(0xFF6E43A2),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF3A246D),
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  void _openSettings() {
    Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          key: const Key('game_settings_dialog'),
          constraints: const BoxConstraints(maxWidth: 390),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEC), Color(0xFFF1E5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD873), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 28)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.settings_rounded,
                size: 45,
                color: Color(0xFF6D3FA0),
              ),
              const SizedBox(height: 10),
              const Text(
                '遊戲設定',
                style: TextStyle(
                  color: Color(0xFF3A246D),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '清除後會刪除玩家名字、所有任務進度與道具，而且無法復原。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6A6078), height: 1.45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MagicButton(
                      key: const Key('cancel_clear_game_data'),
                      label: '取消',
                      icon: Icons.close_rounded,
                      style: MagicButtonStyle.parchment,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: Get.back,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MagicButton(
                      key: const Key('confirm_clear_game_data'),
                      label: '清除所有記憶',
                      icon: Icons.delete_forever_rounded,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: controller.clearAllGameData,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _questArea() => Center(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.sizeOf(Get.context!).width < 600 ? 205 : 220,
      ),
      child: MagicButton(
        onPressed: controller.allMissionsCompleted
            ? null
            : controller.performCurrentMission,
        icon: controller.allMissionsCompleted
            ? Icons.celebration_rounded
            : Icons.search_rounded,
        label: controller.allMissionsCompleted
            ? '10 項生日任務全部完成！'
            : controller.completedMissions.value == 0 &&
                  !controller.plutoRecruited.value
            ? '打開任務卷軸'
            : '開始下一個神秘任務',
        style: MagicButtonStyle.parchment,
      ),
    ),
  );

  Widget _bottomHud() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _dialogue(),
      InventoryBar(controller: controller),
    ],
  );

  Widget _dialogue() {
    final compact = MediaQuery.sizeOf(Get.context!).width < 600;
    if (controller.questStarted.value) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 8 : 18,
          compact ? 8 : 18,
          compact ? 8 : 18,
          compact ? 8 : 24,
        ),
        child: GlassPanel(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 22,
            vertical: compact ? 10 : 14,
          ),
          child: Row(
            children: [
              CharacterDialogueAvatar(speaker: '米奇', size: compact ? 42 : 54),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: Text(
                  controller.mickeyHint,
                  maxLines: compact ? 3 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final line = controller.story[controller.dialogueIndex.value];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 18,
        compact ? 8 : 18,
        compact ? 8 : 18,
        compact ? 8 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: GlassPanel(
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CharacterDialogueAvatar(
                          speaker: line.speaker,
                          size: 54,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _storyText(line, compact: true)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: MagicButton(
                        onPressed: controller.castleGlowing.value
                            ? null
                            : controller.nextDialogue,
                        label: controller.isLastDialogue ? '一起唸咒語' : '繼續',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    CharacterDialogueAvatar(speaker: line.speaker),
                    const SizedBox(width: 18),
                    Expanded(child: _storyText(line)),
                    const SizedBox(width: 12),
                    MagicButton(
                      onPressed: controller.castleGlowing.value
                          ? null
                          : controller.nextDialogue,
                      label: controller.isLastDialogue ? '一起唸咒語' : '繼續',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _storyText(StoryLine line, {bool compact = false}) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        line.speaker,
        style: const TextStyle(
          color: Color(0xFF6D4DCE),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      SizedBox(height: compact ? 3 : 7),
      Text(
        line.text,
        maxLines: compact ? 4 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
        style: TextStyle(
          color: const Color(0xFF332B40),
          fontSize: compact ? 13 : 16,
          height: compact ? 1.3 : 1.5,
        ),
      ),
    ],
  );
}

class _CastleMagicGlow extends StatefulWidget {
  const _CastleMagicGlow();

  @override
  State<_CastleMagicGlow> createState() => _CastleMagicGlowState();
}

class _CastleMagicGlowState extends State<_CastleMagicGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = .48 + _controller.value * .34;
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -.48),
                    radius: .62,
                    colors: [
                      const Color(0xFFFFF6A4).withValues(alpha: glow),
                      const Color(0xFFB08CFF).withValues(alpha: glow * .46),
                      Colors.transparent,
                    ],
                    stops: const [0, .48, 1],
                  ),
                ),
              ),
            ),
            for (final sparkle in const [
              (Alignment(-.52, -.54), 28.0),
              (Alignment(.48, -.62), 22.0),
              (Alignment(-.2, -.25), 18.0),
              (Alignment(.28, -.34), 26.0),
            ])
              Align(
                alignment: sparkle.$1,
                child: Transform.scale(
                  scale: .7 + _controller.value * .45,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: sparkle.$2,
                    color: const Color(0xFFFFE67A),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
