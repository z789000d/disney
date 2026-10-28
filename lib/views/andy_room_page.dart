import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/game_item_art.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class AndyRoomPage extends StatefulWidget {
  const AndyRoomPage({super.key});

  @override
  State<AndyRoomPage> createState() => _AndyRoomPageState();
}

class _AndyRoomPageState extends State<AndyRoomPage> {
  final GameController controller = Get.find<GameController>();
  Timer? _dodgeTimer;
  late final Worker _battleWorker;

  @override
  void initState() {
    super.initState();
    _battleWorker = ever<bool>(controller.toyBattleActive, (active) {
      if (active) {
        _startDodgeTimer();
      } else {
        _dodgeTimer?.cancel();
      }
    });
    if (controller.toyBattleActive.value) _startDodgeTimer();
  }

  void _startDodgeTimer() {
    _dodgeTimer?.cancel();
    _dodgeTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      controller.dodgeZurg();
    });
  }

  @override
  void dispose() {
    _dodgeTimer?.cancel();
    _battleWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop:
          !controller.toyRewardGiving.value &&
          !controller.toyDefeatAnimating.value,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/andy_room.png', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x330B2850),
                    Colors.transparent,
                    Color(0xB3121838),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(child: _scene()),
                  _storyPanel(),
                  InventoryBar(controller: controller),
                ],
              ),
            ),
            if (controller.toyRewardGiving.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: _StrawberryRewardAnimation(
                    onCompleted: controller.completeToyMission,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
    child: Row(
      children: [
        MagicIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: '回到城堡',
          onPressed:
              controller.toyRewardGiving.value ||
                  controller.toyDefeatAnimating.value
              ? null
              : Get.back,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xF2FFFFFF), Color(0xE8EAF6FF)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFD873), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: const Text(
              '🧸 第二關：安迪的房間',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF312468),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scene() {
    if (controller.toyBattleActive.value) return _battleScene();
    if (controller.toyDefeatAnimating.value) {
      return _ZurgDefeatSequence(
        startIndex: controller.zurgDodgeIndex.value,
        onCompleted: controller.completeZurgDefeat,
      );
    }
    if (controller.toyBattleWon.value) return _rescuedScene();
    return _introScene();
  }

  Widget _introScene() => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final index = controller.toyDialogueIndex.value;
      return Stack(
        children: [
          Positioned(
            left: compact ? 12 : constraints.maxWidth * .16,
            bottom: 5,
            child: _ToyCharacter(
              asset: 'assets/images/woody.png',
              name: '胡迪',
              height: compact ? 185 : 250,
              active: GameController.toyIntroStory[index].speaker == '胡迪',
            ),
          ),
          Positioned(
            right: compact ? 12 : constraints.maxWidth * .16,
            bottom: 5,
            child: _ToyCharacter(
              asset: 'assets/images/bause.png',
              name: '巴斯光年',
              height: compact ? 180 : 245,
              active: GameController.toyIntroStory[index].speaker == '巴斯光年',
            ),
          ),
          if (index >= 2)
            Positioned(
              left: compact ? 86 : constraints.maxWidth * .32,
              top: 5,
              child: _ToyCharacter(
                asset: 'assets/images/slinky_dog.png',
                name: '彈簧狗',
                height: compact ? 105 : 145,
                active: GameController.toyIntroStory[index].speaker == '彈簧狗',
              ),
            ),
          if (index >= 3)
            Positioned(
              right: compact ? 82 : constraints.maxWidth * .32,
              top: 5,
              child: _ToyCharacter(
                asset: 'assets/images/lotso.png',
                name: '熊抱哥',
                height: compact ? 112 : 150,
                active: GameController.toyIntroStory[index].speaker == '熊抱哥',
              ),
            ),
          if (index >= 4)
            Center(
              child: _ToyCharacter(
                asset: 'assets/images/zurg.png',
                name: '札克',
                height: compact ? 190 : 260,
                active: true,
              ),
            ),
        ],
      );
    },
  );

  Widget _battleScene() {
    // Read battle observables before entering LayoutBuilder. Its builder runs
    // outside the surrounding Obx tracking callback, so reading them only
    // inside it would update the controller without rebuilding the scene.
    final health = controller.zurgHealth.value;
    final dodgeIndex = controller.zurgDodgeIndex.value;
    final showHitFeedback = controller.zurgHitFeedback.value;
    final hitSequence = controller.zurgHitSequence.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        const positions = <(double, double)>[
          (.03, .05),
          (.94, .10),
          (.08, .82),
          (.92, .78),
          (.50, .42),
        ];
        final compact = constraints.maxWidth < 600;
        final targetWidth = compact ? 125.0 : 175.0;
        final targetHeight = compact ? 170.0 : 240.0;
        final position = positions[dodgeIndex];
        final travelWidth = math.max(0.0, constraints.maxWidth - targetWidth);
        final travelHeight = math.max(
          0.0,
          constraints.maxHeight - targetHeight - 75,
        );
        return Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              top: 8,
              child: Column(
                children: [
                  Text(
                    '札克能量 $health / 5',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: health / 5,
                    minHeight: 12,
                    color: const Color(0xFF9C4DD2),
                    backgroundColor: const Color(0x55FFFFFF),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              left: travelWidth * position.$1,
              top: 48 + travelHeight * position.$2,
              width: targetWidth,
              height: targetHeight,
              child: _ZurgBattleTarget(
                key: const Key('zurg_target'),
                onHit: controller.hitZurg,
                hitSequence: hitSequence,
                isHit: showHitFeedback,
              ),
            ),
            if (showHitFeedback && health < 5 && health > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: .65, end: 1),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: Center(child: child),
                    ),
                    child: Container(
                      key: ValueKey('zurg_hit_feedback_$health'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE6B51F2E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFE16B),
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCCFFCC33),
                            blurRadius: 24,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        '⚡ 命中札克！剩餘 $health',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const Positioned(
              left: 20,
              right: 20,
              bottom: 8,
              child: Text(
                '🎯 點擊閃避中的札克，命中 5 次！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rescuedScene() {
    const cast = <(String, String)>[
      ('assets/images/woody.png', '胡迪'),
      ('assets/images/bause.png', '巴斯光年'),
      ('assets/images/slinky_dog.png', '彈簧狗'),
      ('assets/images/lotso.png', '熊抱哥'),
      ('assets/images/three_eye.png', '三眼怪'),
    ];
    final speaker =
        controller.toyThanksStory[controller.toyThanksIndex.value].speaker;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .74,
        mainAxisSpacing: 2,
        crossAxisSpacing: 5,
      ),
      itemCount: cast.length,
      itemBuilder: (context, index) => _ToyCharacter(
        asset: cast[index].$1,
        name: cast[index].$2,
        height: 115,
        active: cast[index].$2 == speaker,
      ),
    );
  }

  Widget _storyPanel() {
    if (controller.toyBattleActive.value) {
      return _messagePanel(
        icon: Icons.flash_on_rounded,
        text: '札克會不斷換位置，看準後點擊它！',
      );
    }
    if (controller.toyDefeatAnimating.value) {
      return _messagePanel(
        icon: Icons.auto_awesome_rounded,
        text: '札克被打敗了，正在失去力量…',
      );
    }
    final won = controller.toyBattleWon.value;
    final line = won
        ? controller.toyThanksStory[controller.toyThanksIndex.value]
        : GameController.toyIntroStory[controller.toyDialogueIndex.value];
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xF4FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD873), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _speakerAvatar(line.speaker),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.speaker,
                      style: const TextStyle(
                        color: Color(0xFF5D328A),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      line.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF322B3D),
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: MagicButton(
              onPressed: controller.toyRewardGiving.value
                  ? null
                  : won
                  ? controller.nextToyThanks
                  : controller.nextToyDialogue,
              icon:
                  won &&
                      controller.toyThanksIndex.value ==
                          controller.toyThanksStory.length - 1
                  ? Icons.card_giftcard_rounded
                  : Icons.navigate_next_rounded,
              label: won
                  ? controller.toyThanksIndex.value ==
                            controller.toyThanksStory.length - 1
                        ? '收下草莓'
                        : '繼續聽夥伴說'
                  : controller.toyDialogueIndex.value ==
                        GameController.toyIntroStory.length - 1
                  ? '迎戰札克'
                  : '繼續',
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagePanel({required IconData icon, required String text}) =>
      Container(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD873), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6E38A1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );

  Widget _speakerAvatar(String speaker) {
    final asset = switch (speaker) {
      '胡迪' => 'assets/images/woody.png',
      '巴斯光年' => 'assets/images/bause.png',
      '彈簧狗' => 'assets/images/slinky_dog.png',
      '熊抱哥' => 'assets/images/lotso.png',
      '三眼怪' => 'assets/images/three_eye.png',
      _ => 'assets/images/zurg.png',
    };
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEADFFF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD873), width: 2),
      ),
      child: ClipOval(child: Image.asset(asset, fit: BoxFit.contain)),
    );
  }
}

class _ZurgBattleTarget extends StatefulWidget {
  const _ZurgBattleTarget({
    super.key,
    required this.onHit,
    required this.hitSequence,
    required this.isHit,
  });

  final VoidCallback onHit;
  final int hitSequence;
  final bool isHit;

  @override
  State<_ZurgBattleTarget> createState() => _ZurgBattleTargetState();
}

class _ZurgBattleTargetState extends State<_ZurgBattleTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hitAnimation;

  @override
  void initState() {
    super.initState();
    _hitAnimation =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
          reverseDuration: const Duration(milliseconds: 300),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _hitAnimation.reverse();
        });
  }

  @override
  void dispose() {
    _hitAnimation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ZurgBattleTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hitSequence != oldWidget.hitSequence) {
      _hitAnimation.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: widget.onHit,
    child: AnimatedBuilder(
      animation: _hitAnimation,
      builder: (context, child) {
        final value = Curves.easeOut.transform(_hitAnimation.value);
        final hitValue = math.max(value, widget.isHit ? .72 : 0.0);
        return Transform.translate(
          offset: Offset(math.sin(value * math.pi * 6) * 15, -hitValue * 5),
          child: Transform.rotate(
            angle: math.sin(value * math.pi * 5) * .075,
            child: Transform.scale(
              scale: 1 - hitValue * .32,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        const Color(0x226F35AA),
                        const Color(0xEEFF2727),
                        hitValue,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0x779D5DDB),
                            const Color(0xFFFFE14D),
                            hitValue,
                          )!,
                          blurRadius: 10 + hitValue * 36,
                          spreadRadius: hitValue * 9,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Color.lerp(
                          const Color(0x00FFFFFF),
                          const Color(0xE6FF3030),
                          hitValue,
                        )!,
                        BlendMode.srcATop,
                      ),
                      child: Image.asset(
                        'assets/images/zurg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (hitValue > .04) ...[
                    Positioned(
                      top: 2,
                      left: 4,
                      child: Opacity(
                        opacity: hitValue,
                        child: const Icon(
                          Icons.bolt_rounded,
                          key: Key('zurg_damage_flash'),
                          color: Color(0xFFFFEB3B),
                          size: 46,
                          shadows: [Shadow(color: Colors.red, blurRadius: 10)],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 18,
                      child: Opacity(
                        opacity: hitValue,
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 35,
                          shadows: [
                            Shadow(color: Colors.orange, blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _ZurgDefeatSequence extends StatefulWidget {
  const _ZurgDefeatSequence({
    required this.startIndex,
    required this.onCompleted,
  });

  final int startIndex;
  final VoidCallback onCompleted;

  @override
  State<_ZurgDefeatSequence> createState() => _ZurgDefeatSequenceState();
}

class _ZurgDefeatSequenceState extends State<_ZurgDefeatSequence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 5200),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onCompleted();
          })
          ..forward();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const starts = <Alignment>[
        Alignment(-.82, -.65),
        Alignment(.82, -.58),
        Alignment(-.76, .58),
        Alignment(.78, .54),
        Alignment(0, 0),
      ];
      final start = starts[widget.startIndex.clamp(0, starts.length - 1)];
      final compact = constraints.maxWidth < 600;
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final raw = _animation.value;
          final moveT = Curves.easeInOutCubic.transform(
            (raw / .28).clamp(0.0, 1.0),
          );
          final zurgAlignment = Alignment.lerp(start, Alignment.center, moveT)!;
          final fadeT = Curves.easeIn.transform(
            ((raw - .40) / .28).clamp(0.0, 1.0),
          );
          final alienT = Curves.easeOutBack.transform(
            ((raw - .70) / .30).clamp(0.0, 1.0),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0x4410092A)),
              if (raw < .70)
                Align(
                  alignment: zurgAlignment,
                  child: Opacity(
                    opacity: (1 - fadeT).clamp(0, 1),
                    child: Transform.scale(
                      scale: 1 - fadeT * .35,
                      child: Image.asset(
                        'assets/images/zurg.png',
                        key: const Key('zurg_defeat_center'),
                        height: compact ? 205 : 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              if (raw >= .28 && raw < .69)
                Align(
                  alignment: const Alignment(0, -.80),
                  child: Opacity(
                    opacity: math
                        .sin(((raw - .28) / .41) * math.pi)
                        .clamp(0, 1),
                    child: Container(
                      key: const Key('zurg_scream'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xF2FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8E42B4),
                          width: 3,
                        ),
                      ),
                      child: const Text(
                        '啊啊啊啊啊啊！',
                        style: TextStyle(
                          color: Color(0xFF56207B),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              if (raw >= .70)
                Center(
                  child: Opacity(
                    opacity: ((raw - .70) / .18).clamp(0, 1),
                    child: Transform.scale(
                      scale: .35 + alienT * .65,
                      child: Column(
                        key: const Key('three_eye_reveal'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 270),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xF2FFFFFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF69B84F),
                                width: 3,
                              ),
                            ),
                            child: const Text(
                              '你救了我們，我們永遠感謝你！',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF31562B),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Image.asset(
                            'assets/images/three_eye.png',
                            height: compact ? 145 : 205,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

class _ToyCharacter extends StatelessWidget {
  const _ToyCharacter({
    required this.asset,
    required this.name,
    required this.height,
    required this.active,
  });

  final String asset;
  final String name;
  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    duration: const Duration(milliseconds: 260),
    scale: active ? 1.07 : .94,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          constraints: BoxConstraints(maxWidth: height * .72),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: active
                ? const [BoxShadow(color: Color(0xBBFFE168), blurRadius: 20)]
                : const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6D3AA0) : const Color(0xCC302454),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD873)),
          ),
          child: Text(
            name,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StrawberryRewardAnimation extends StatefulWidget {
  const _StrawberryRewardAnimation({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_StrawberryRewardAnimation> createState() =>
      _StrawberryRewardAnimationState();
}

class _StrawberryRewardAnimationState extends State<_StrawberryRewardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1550),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onCompleted();
          })
          ..forward();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      final t = Curves.easeInOutCubic.transform(_animation.value);
      final position = Alignment.lerp(
        const Alignment(.45, .10),
        const Alignment(-.82, .91),
        t,
      )!;
      final arc = math.sin(t * math.pi) * 120;
      return Stack(
        children: [
          const ColoredBox(color: Color(0x330F092A)),
          Align(
            alignment: position,
            child: Transform.translate(
              offset: Offset(0, -arc),
              child: Transform.rotate(
                angle: t * math.pi * 2,
                child: const GameItemArt(
                  key: Key('strawberry_reward'),
                  type: GameItemArtType.strawberry,
                  size: 70,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -.55),
            child: Opacity(
              opacity: (1 - t).clamp(0, 1),
              child: const Text(
                '熊抱哥的草莓已放進道具欄！',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
