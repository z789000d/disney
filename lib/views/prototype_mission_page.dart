import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class PrototypeMissionPage extends StatefulWidget {
  const PrototypeMissionPage({super.key});

  @override
  State<PrototypeMissionPage> createState() => _PrototypeMissionPageState();
}

class _PrototypeMissionPageState extends State<PrototypeMissionPage> {
  final GameController controller = Get.find<GameController>();
  bool _rewardAnimating = false;

  int get _missionIndex {
    final number = int.tryParse(Get.parameters['number'] ?? '') ?? 4;
    return (number - 1).clamp(3, GameController.missions.length - 1);
  }

  _PrototypeMissionConfig get _config =>
      _prototypeMissions.firstWhere((item) => item.index == _missionIndex);

  @override
  Widget build(BuildContext context) => Obx(() {
    final config = _config;
    final mission = GameController.missions[config.index];
    final dialogueStep = controller.prototypeDialogueStep(config.index);
    final progress = controller.prototypeProgress(config.index);
    return PopScope(
      canPop: !_rewardAnimating,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _PrototypeBackground(config: config),
            SafeArea(
              child: Column(
                children: [
                  _header(config, mission),
                  Expanded(
                    child: _scene(
                      config,
                      dialogueStep: dialogueStep,
                      progress: progress,
                    ),
                  ),
                  _storyPanel(
                    config,
                    dialogueStep: dialogueStep,
                    progress: progress,
                  ),
                  InventoryBar(controller: controller),
                ],
              ),
            ),
            if (_rewardAnimating)
              Positioned.fill(
                child: _PrototypeRewardAnimation(
                  rewardName: mission.rewardName,
                  color: config.accent,
                  onCompleted: () => controller.completePrototypeMission(
                    config.index,
                    config.requiredCount,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  });

  Widget _header(_PrototypeMissionConfig config, Mission mission) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
    child: Row(
      children: [
        MagicIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: '回到城堡',
          onPressed: _rewardAnimating ? null : Get.back,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: config.accent, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 9),
              ],
            ),
            child: Text(
              '第 ${config.index + 1} 關：${mission.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: config.dark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scene(
    _PrototypeMissionConfig config, {
    required int dialogueStep,
    required int progress,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      return Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 4,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 5,
              children: config.characters
                  .map(
                    (name) => _CharacterPlaceholder(
                      name: name,
                      accent: config.accent,
                      compact: compact,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (dialogueStep >= config.lines.length &&
              progress < config.requiredCount)
            AnimatedAlign(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
              alignment: _targetAlignments[progress % _targetAlignments.length],
              child: GestureDetector(
                key: ValueKey('prototype_target_${config.index}_$progress'),
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.advancePrototypeAction(
                  config.index,
                  config.requiredCount,
                ),
                child: Container(
                  width: compact ? 82 : 108,
                  height: compact ? 82 : 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xEEFFFFFF),
                    border: Border.all(color: config.accent, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: config.accent.withValues(alpha: .65),
                        blurRadius: 24,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    config.targetIcon,
                    color: config.dark,
                    size: compact ? 42 : 58,
                  ),
                ),
              ),
            ),
          if (progress >= config.requiredCount)
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xEFFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: config.accent, width: 4),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  key: ValueKey('prototype_complete_${config.index}'),
                  color: config.dark,
                  size: compact ? 72 : 100,
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _storyPanel(
    _PrototypeMissionConfig config, {
    required int dialogueStep,
    required int progress,
  }) {
    final inDialogue = dialogueStep < config.lines.length;
    final completed = progress >= config.requiredCount;
    final line = inDialogue ? config.lines[dialogueStep] : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 11),
      decoration: BoxDecoration(
        color: const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: config.accent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inDialogue) ...[
            CharacterDialogueLine(
              speaker: line!.speaker,
              text: line.text,
              avatarSize: 48,
              speakerColor: config.dark,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 9),
            MagicButton(
              key: ValueKey('prototype_dialogue_next_${config.index}'),
              label: dialogueStep == config.lines.length - 1 ? '開始挑戰' : '繼續',
              icon: Icons.navigate_next_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              onPressed: () => controller.advancePrototypeDialogue(
                config.index,
                config.lines.length,
              ),
            ),
          ] else if (!completed) ...[
            Text(
              config.activityPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: config.dark, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: progress / config.requiredCount,
              minHeight: 10,
              color: config.accent,
              backgroundColor: config.accent.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 5),
            Text('$progress / ${config.requiredCount}'),
          ] else ...[
            Text(
              config.successText,
              textAlign: TextAlign.center,
              style: TextStyle(color: config.dark, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            MagicButton(
              key: ValueKey('prototype_reward_${config.index}'),
              label: '收下任務獎勵',
              icon: Icons.redeem_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              onPressed: () => setState(() => _rewardAnimating = true),
            ),
          ],
        ],
      ),
    );
  }
}

class _CharacterPlaceholder extends StatelessWidget {
  const _CharacterPlaceholder({
    required this.name,
    required this.accent,
    required this.compact,
  });

  final String name;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 12,
      vertical: compact ? 5 : 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xEFFFFFFF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.account_circle_rounded,
          color: accent,
          size: compact ? 20 : 25,
        ),
        const SizedBox(width: 4),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _PrototypeBackground extends StatelessWidget {
  const _PrototypeBackground({required this.config});

  final _PrototypeMissionConfig config;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: config.background,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Center(
      child: Icon(
        config.sceneIcon,
        size: 260,
        color: Colors.white.withValues(alpha: .16),
      ),
    ),
  );
}

class _PrototypeRewardAnimation extends StatefulWidget {
  const _PrototypeRewardAnimation({
    required this.rewardName,
    required this.color,
    required this.onCompleted,
  });

  final String rewardName;
  final Color color;
  final VoidCallback onCompleted;

  @override
  State<_PrototypeRewardAnimation> createState() =>
      _PrototypeRewardAnimationState();
}

class _PrototypeRewardAnimationState extends State<_PrototypeRewardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1700),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onCompleted();
        });
    _animation.forward();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_animation.value);
        final alignment = Alignment.lerp(
          const Alignment(0, -.05),
          const Alignment(-.82, .91),
          t,
        )!;
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black.withValues(alpha: .18 * (1 - t))),
            Align(
              alignment: alignment,
              child: Transform.translate(
                offset: Offset(0, -math.sin(t * math.pi) * 120),
                child: Transform.rotate(
                  angle: t * math.pi * 2,
                  child: Container(
                    key: const Key('prototype_reward_flying'),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color, width: 4),
                      boxShadow: [
                        BoxShadow(color: widget.color, blurRadius: 22),
                      ],
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: widget.color,
                      size: 37,
                    ),
                  ),
                ),
              ),
            ),
            if (_animation.value < .62)
              Align(
                alignment: const Alignment(0, -.42),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '獲得：${widget.rewardName}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _PrototypeMissionConfig {
  const _PrototypeMissionConfig({
    required this.index,
    required this.characters,
    required this.lines,
    required this.activityPrompt,
    required this.successText,
    required this.requiredCount,
    required this.sceneIcon,
    required this.targetIcon,
    required this.background,
    required this.accent,
    required this.dark,
  });

  final int index;
  final List<String> characters;
  final List<_PrototypeLine> lines;
  final String activityPrompt;
  final String successText;
  final int requiredCount;
  final IconData sceneIcon;
  final IconData targetIcon;
  final List<Color> background;
  final Color accent;
  final Color dark;
}

class _PrototypeLine {
  const _PrototypeLine(this.speaker, this.text);
  final String speaker;
  final String text;
}

const _targetAlignments = <Alignment>[
  Alignment(-.72, -.20),
  Alignment(.68, -.10),
  Alignment(-.48, .55),
  Alignment(.55, .50),
  Alignment(0, .12),
  Alignment(-.05, .70),
  Alignment(.18, -.42),
];

const _prototypeMissions = <_PrototypeMissionConfig>[
  _PrototypeMissionConfig(
    index: 3,
    characters: ['安娜', '艾莎', '雪寶'],
    lines: [
      _PrototypeLine('安娜', '一陣大風吹過，雪寶的胡蘿蔔鼻子不見了！'),
      _PrototypeLine('雪寶', '沒有鼻子，我連最喜歡的味道都聞不到了。'),
      _PrototypeLine('艾莎', '跟著冰雪裡的亮光前進，真正的線索會留下魔法光芒。'),
    ],
    activityPrompt: '點擊移動中的冰雪線索，找出雪寶的胡蘿蔔鼻子。',
    successText: '雪寶找回鼻子了！艾莎把魔法雪花送給你。',
    requiredCount: 6,
    sceneIcon: Icons.ac_unit_rounded,
    targetIcon: Icons.ac_unit_rounded,
    background: [Color(0xFF78C9F4), Color(0xFFDDF6FF), Color(0xFF6589C8)],
    accent: Color(0xFF3A91D1),
    dark: Color(0xFF174F82),
  ),
  _PrototypeMissionConfig(
    index: 4,
    characters: ['阿拉丁', '魔毯', '精靈'],
    lines: [
      _PrototypeLine('阿拉丁', '賈方把精靈封印在神燈裡，天空也布滿危險魔法。'),
      _PrototypeLine('魔毯', '控制飛行方向，閃過所有攻擊才能接近賈方。'),
      _PrototypeLine('阿拉丁', '打敗賈方，我們就能救回精靈！'),
    ],
    activityPrompt: '閃避魔法並擊敗賈方。',
    successText: '精靈自由了！他送給你一個願望。',
    requiredCount: 12,
    sceneIcon: Icons.nightlight_round,
    targetIcon: Icons.air_rounded,
    background: [Color(0xFF311B72), Color(0xFF7A3AA7), Color(0xFFE59A45)],
    accent: Color(0xFFFFC84A),
    dark: Color(0xFF5A3200),
  ),
  _PrototypeMissionConfig(
    index: 5,
    characters: ['辛巴', '拉飛奇', '丁滿', '彭彭'],
    lines: [
      _PrototypeLine('拉飛奇', '榮耀石的道路被迷霧遮住，只有勇氣之鼓能指出方向。'),
      _PrototypeLine('辛巴', '我必須記住父親的勇氣，才能帶大家回家。'),
      _PrototypeLine('丁滿', '跟著鼓聲走！彭彭，你可別踩錯節拍。'),
    ],
    activityPrompt: '依序追上勇氣之鼓，帶辛巴走向榮耀石。',
    successText: '辛巴通過了試煉，將勇氣爪印徽章送給你。',
    requiredCount: 6,
    sceneIcon: Icons.landscape_rounded,
    targetIcon: Icons.music_note_rounded,
    background: [Color(0xFFFFB84D), Color(0xFFD98132), Color(0xFF654321)],
    accent: Color(0xFFB75A1B),
    dark: Color(0xFF60300E),
  ),
  _PrototypeMissionConfig(
    index: 6,
    characters: ['莉蘿', '史迪奇', '娜妮'],
    lines: [
      _PrototypeLine('莉蘿', '史迪奇為了準備派對，把我的唱片散得到處都是。'),
      _PrototypeLine('史迪奇', '史迪奇不是故意的！我們一起把音樂找回來。'),
      _PrototypeLine('娜妮', '收集所有唱片，海灘生日派對就能準時開始。'),
    ],
    activityPrompt: '追上跳動的唱片節拍，收集派對音樂。',
    successText: '唱片全部找回來了！史迪奇送你一朵紅色扶桑花。',
    requiredCount: 6,
    sceneIcon: Icons.beach_access_rounded,
    targetIcon: Icons.album_rounded,
    background: [Color(0xFF4FC3C7), Color(0xFFFFD88A), Color(0xFFEA7F67)],
    accent: Color(0xFFCB4E7A),
    dark: Color(0xFF76304E),
  ),
  _PrototypeMissionConfig(
    index: 7,
    characters: ['貝兒', '盧米亞', '葛士華'],
    lines: [
      _PrototypeLine('貝兒', '魔法玫瑰少了幾片花瓣，城堡的光也變得越來越弱。'),
      _PrototypeLine('盧米亞', '點亮正確的燭火，花瓣就會回應你的光。'),
      _PrototypeLine('葛士華', '時間不多了，請跟著城堡機關的順序前進。'),
    ],
    activityPrompt: '啟動移動中的城堡機關，喚回魔法玫瑰花瓣。',
    successText: '玫瑰再次綻放！貝兒送你一片魔法花瓣。',
    requiredCount: 6,
    sceneIcon: Icons.castle_rounded,
    targetIcon: Icons.local_florist_rounded,
    background: [Color(0xFF253B73), Color(0xFF77528F), Color(0xFFD9A54A)],
    accent: Color(0xFFE9B63E),
    dark: Color(0xFF5F3D08),
  ),
  _PrototypeMissionConfig(
    index: 8,
    characters: ['小熊維尼', '小豬', '跳跳虎'],
    lines: [
      _PrototypeLine('小熊維尼', '我聞得到蜂蜜，可是每一條小路看起來都一樣。'),
      _PrototypeLine('跳跳虎', '我只是跳了幾下，蜂蜜罐就全部滾進森林啦！'),
      _PrototypeLine('小豬', '我們一起沿著蜂蜜亮光前進，一定能找回正確的罐子。'),
    ],
    activityPrompt: '追蹤蜂蜜亮光，穿過百畝森林迷宮。',
    successText: '維尼找回蜂蜜了！他把友情蜂蜜罐送給你。',
    requiredCount: 6,
    sceneIcon: Icons.forest_rounded,
    targetIcon: Icons.hive_rounded,
    background: [Color(0xFF9BCB65), Color(0xFFFFD96A), Color(0xFFB36B36)],
    accent: Color(0xFFD78B16),
    dark: Color(0xFF6A3C08),
  ),
  _PrototypeMissionConfig(
    index: 9,
    characters: ['樂佩', '帕斯卡', '尤金'],
    lines: [
      _PrototypeLine('樂佩', '生日天燈就要升空了，但太陽徽章碎片散落在王國各處。'),
      _PrototypeLine('帕斯卡', '我看到亮晶晶的碎片了！它們正在屋頂之間移動。'),
      _PrototypeLine('尤金', '找回所有碎片，我們就能點亮今晚最特別的生日天燈。'),
    ],
    activityPrompt: '收集移動中的太陽徽章碎片，完成最後的天燈儀式。',
    successText: '太陽徽章完成了！樂佩點亮生日天燈，最終大獎也已開啟。',
    requiredCount: 7,
    sceneIcon: Icons.wb_sunny_rounded,
    targetIcon: Icons.lightbulb_rounded,
    background: [Color(0xFF6F4AA8), Color(0xFFFFB6D5), Color(0xFFFFC85A)],
    accent: Color(0xFFFFB43B),
    dark: Color(0xFF6A3A08),
  ),
];
