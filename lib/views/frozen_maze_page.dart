import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
import '../widgets/game_item_art.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class FrozenMazePage extends StatefulWidget {
  const FrozenMazePage({super.key});

  @override
  State<FrozenMazePage> createState() => _FrozenMazePageState();
}

class _FrozenMazePageState extends State<FrozenMazePage>
    with TickerProviderStateMixin {
  static const _missionIndex = 3;
  static const _footstepCount = 8;
  static const _rewardProgress = 9;

  final GameController controller = Get.find<GameController>();
  late final AnimationController _snowballs;
  late final AnimationController _traveler;
  late final AnimationController _reward;
  Timer? _hitTimer;
  bool _snowballHit = false;
  bool _collisionLocked = false;
  bool _rewardAnimating = false;
  int? _movingTo;
  Alignment _travelStart = _mazeStart;
  Alignment _travelEnd = _mazeStart;
  Size _sceneSize = Size.zero;

  static const _story = <StoryLine>[
    StoryLine(speaker: '安娜', text: '雪寶的胡蘿蔔鼻子被大風吹進冰雪迷宮了！'),
    StoryLine(speaker: '艾莎', text: '雪地上還留著腳印。跟著發光的下一步走，就能找到雪寶。'),
    StoryLine(speaker: '安娜', text: '不過要小心滾動的雪球！等雪球離開腳印，再安全地前進。'),
  ];

  @override
  void initState() {
    super.initState();
    _snowballs = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..addListener(_monitorSnowballCollision);
    _snowballs.repeat();
    _traveler =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 720),
          )
          ..addListener(_monitorSnowballCollision)
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed || _movingTo == null) {
              return;
            }
            controller.followFrozenFootstep();
            if (mounted) {
              setState(() => _movingTo = null);
            }
          });
    _reward =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            controller.completePrototypeMission(_missionIndex, _rewardProgress);
          }
        });
  }

  @override
  void dispose() {
    _hitTimer?.cancel();
    _snowballs.dispose();
    _traveler.dispose();
    _reward.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final dialogueStep = controller.prototypeDialogueStep(_missionIndex);
    final progress = controller.prototypeProgress(_missionIndex);
    return PopScope(
      canPop: !_rewardAnimating,
      child: Scaffold(
        body: Stack(
          key: const Key('frozen_maze_scene'),
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/frozen_maze.png',
              key: const Key('frozen_maze_background'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const CustomPaint(painter: _FrozenBackgroundPainter()),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x44315D9E),
                    Color(0x188FD8F4),
                    Color(0x55E9FAFF),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: _mazeScene(
                      dialogueStep: dialogueStep,
                      progress: progress,
                    ),
                  ),
                  _storyPanel(dialogueStep: dialogueStep, progress: progress),
                  InventoryBar(controller: controller),
                ],
              ),
            ),
            if (_snowballHit) const _SnowballHitOverlay(),
            if (_rewardAnimating)
              Positioned.fill(
                child: _SnowflakeRewardOverlay(animation: _reward),
              ),
          ],
        ),
      ),
    );
  });

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
    child: Row(
      children: [
        MagicIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: '回到城堡',
          onPressed: _rewardAnimating ? null : Get.back,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xEBFFFFFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF4BB8E8), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 9),
              ],
            ),
            child: const Text(
              '第 4 關：雪寶的胡蘿蔔鼻子',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF174F82),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _mazeScene({required int dialogueStep, required int progress}) =>
      LayoutBuilder(
        builder: (context, constraints) {
          final sceneSize = constraints.biggest;
          _sceneSize = sceneSize;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned(
                left: 5,
                top: 3,
                child: _FrozenCharacterArt(
                  name: '安娜',
                  color: Color(0xFF8B4B93),
                  asset: 'assets/images/anna.png',
                  imageKey: Key('frozen_anna'),
                  width: 100,
                  height: 168,
                ),
              ),
              const Positioned(
                right: 5,
                top: 3,
                child: _FrozenCharacterArt(
                  name: '艾莎',
                  color: Color(0xFF2D8BC0),
                  asset: 'assets/images/elsa.png',
                  imageKey: Key('frozen_elsa'),
                  width: 94,
                  height: 168,
                ),
              ),
              if (progress < _rewardProgress)
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: _FrozenCharacterArt(
                      name: '雪寶',
                      color: Color(0xFF397B9D),
                      asset: 'assets/images/olaf_no_nose.png',
                      imageKey: Key('frozen_olaf_no_nose'),
                      width: 84,
                      height: 120,
                    ),
                  ),
                ),
              if (dialogueStep >= _story.length) ...[
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MazePathPainter(
                      completedSteps: progress.clamp(0, _footstepCount),
                    ),
                  ),
                ),
                for (var index = 0; index < _footstepCount; index++)
                  _footstep(index, progress, sceneSize),
                if (progress < _footstepCount)
                  AnimatedBuilder(
                    animation: _snowballs,
                    builder: (context, child) => Stack(
                      children: List.generate(
                        3,
                        (index) => _snowball(index, sceneSize),
                      ),
                    ),
                  ),
                if (progress < _footstepCount) _travelerMarker(progress),
                if (progress == _footstepCount) _carrotReveal(),
                if (progress >= _rewardProgress) const _OlafCelebration(),
              ],
            ],
          );
        },
      );

  Widget _footstep(int index, int progress, Size sceneSize) {
    final alignment = _footsteps[index];
    final isCurrent = index == progress;
    final completed = index < progress;
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: completed || isCurrent ? 1 : .2,
        child: GestureDetector(
          key: ValueKey('frozen_footstep_$index'),
          behavior: HitTestBehavior.opaque,
          onTap: isCurrent && _movingTo == null
              ? () => _startTravel(index)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: isCurrent ? 55 : 44,
            height: isCurrent ? 55 : 44,
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xF2FFFFFF)
                  : const Color(0xA8D7F4FF),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFF21B7ED)
                    : const Color(0xFF78BFD8),
                width: isCurrent ? 4 : 2,
              ),
              boxShadow: isCurrent
                  ? const [
                      BoxShadow(
                        color: Color(0xAA42D8FF),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.directions_walk_rounded,
              color: const Color(0xFF176F9C),
              size: isCurrent ? 31 : 25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _snowball(int index, Size sceneSize) {
    final center = _snowballCenter(index, sceneSize);
    final diameter = index == 1 ? 48.0 : 42.0;
    return Positioned(
      key: ValueKey('frozen_snowball_$index'),
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      child: Transform.rotate(
        angle: (_snowballs.value * math.pi * 6) * (index.isEven ? 1 : -1),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-.35, -.4),
              colors: [Colors.white, Color(0xFFC2EAFA), Color(0xFF78B9D5)],
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x663779A2), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _travelerMarker(int progress) => AnimatedBuilder(
    animation: _traveler,
    builder: (context, child) {
      final alignment = _movingTo == null
          ? _restingAlignment(progress)
          : Alignment.lerp(
              _travelStart,
              _travelEnd,
              Curves.easeInOutCubic.transform(_traveler.value),
            )!;
      return Align(
        alignment: alignment,
        child: Container(
          key: const Key('frozen_maze_traveler'),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF6E3D9E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x8842D8FF), blurRadius: 11),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      );
    },
  );

  Widget _carrotReveal() => Center(
    child: GestureDetector(
      key: const Key('frozen_carrot'),
      behavior: HitTestBehavior.opaque,
      onTap: controller.collectFrozenCarrot,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .35, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xF5FFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF9B35), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAAFFD270),
                blurRadius: 25,
                spreadRadius: 7,
              ),
            ],
          ),
          child: const CustomPaint(painter: _CarrotPainter()),
        ),
      ),
    ),
  );

  Widget _storyPanel({required int dialogueStep, required int progress}) {
    final inDialogue = dialogueStep < _story.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
      decoration: BoxDecoration(
        color: const Color(0xF4FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF4BB8E8), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inDialogue) ...[
            CharacterDialogueLine(
              speaker: _story[dialogueStep].speaker,
              text: _story[dialogueStep].text,
              avatarSize: 50,
              speakerColor: const Color(0xFF174F82),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            MagicButton(
              key: const ValueKey('frozen_dialogue_next'),
              label: dialogueStep == _story.length - 1 ? '進入冰雪迷宮' : '繼續',
              icon: Icons.navigate_next_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
              onPressed: () => controller.advancePrototypeDialogue(
                _missionIndex,
                _story.length,
              ),
            ),
          ] else if (progress < _footstepCount) ...[
            const Text(
              '跟著發光腳印前進，雪球靠近時先不要點！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF174F82),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress / _footstepCount,
              minHeight: 9,
              color: const Color(0xFF28B9E8),
              backgroundColor: const Color(0x3328B9E8),
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 3),
            Text('腳印 $progress / $_footstepCount'),
          ] else if (progress == _footstepCount) ...[
            const Text(
              '找到了！點擊發光的胡蘿蔔，把鼻子還給雪寶。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB85A14),
                fontWeight: FontWeight.w900,
              ),
            ),
          ] else ...[
            const CharacterDialogueLine(
              speaker: '雪寶',
              text: '我的鼻子回來了！這片魔法雪花送給你！',
              avatarSize: 50,
              speakerColor: Color(0xFF174F82),
              textAlign: TextAlign.center,
              assetOverride: 'assets/images/olaf_has_nose.png',
            ),
            const SizedBox(height: 8),
            MagicButton(
              key: const Key('frozen_reward_button'),
              label: '收下魔法雪花',
              icon: Icons.ac_unit_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
              onPressed: _startReward,
            ),
          ],
        ],
      ),
    );
  }

  void _startTravel(int index) {
    final progress = controller.prototypeProgress(_missionIndex);
    if (_movingTo != null || index != progress || _collisionLocked) return;
    setState(() {
      _movingTo = index;
      _travelStart = _restingAlignment(progress);
      _travelEnd = _footsteps[index];
    });
    _traveler.forward(from: 0);
  }

  void _monitorSnowballCollision() {
    if (_collisionLocked ||
        _rewardAnimating ||
        _sceneSize.isEmpty ||
        controller.prototypeDialogueStep(_missionIndex) < _story.length) {
      return;
    }
    final progress = controller.prototypeProgress(_missionIndex);
    if (progress >= _footstepCount) return;
    final travelerAlignment = _movingTo == null
        ? _restingAlignment(progress)
        : Alignment.lerp(
            _travelStart,
            _travelEnd,
            Curves.easeInOutCubic.transform(_traveler.value),
          )!;
    final traveler = _alignmentCenter(travelerAlignment, _sceneSize);
    final collided = List.generate(
      3,
      (index) => _snowballCenter(index, _sceneSize),
    ).any((snowball) => (snowball - traveler).distance < 42);
    if (collided) _resetMazeAfterHit();
  }

  void _resetMazeAfterHit() {
    if (_collisionLocked) return;
    _collisionLocked = true;
    _traveler.stop();
    _movingTo = null;
    controller.resetFrozenMazeAfterCollision();
    _snowballs
      ..stop()
      ..value = 0
      ..repeat();
    _hitTimer?.cancel();
    if (mounted) setState(() => _snowballHit = true);
    _hitTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _snowballHit = false;
        _collisionLocked = false;
      });
    });
  }

  void _startReward() {
    if (_rewardAnimating || controller.prototypeProgress(_missionIndex) < 9) {
      return;
    }
    setState(() => _rewardAnimating = true);
    _snowballs.stop();
    _reward.forward(from: 0);
  }

  Offset _snowballCenter(int index, Size size) {
    final phase = (_snowballs.value + index * .31) % 1;
    final reverse = index == 1;
    final x = reverse ? 1.16 - phase * 2.32 : -1.16 + phase * 2.32;
    const lanes = [.42, -.02, -.48];
    return _alignmentCenter(Alignment(x, lanes[index]), size);
  }

  Offset _alignmentCenter(Alignment alignment, Size size) => Offset(
    (alignment.x + 1) * size.width / 2,
    (alignment.y + 1) * size.height / 2,
  );

  Alignment _restingAlignment(int progress) =>
      progress <= 0 ? _mazeStart : _footsteps[progress - 1];
}

const _mazeStart = Alignment(-.88, .91);
const _footsteps = <Alignment>[
  Alignment(-.72, .72),
  Alignment(-.58, .35),
  Alignment(-.18, .48),
  Alignment(.18, .17),
  Alignment(-.12, -.18),
  Alignment(.38, -.38),
  Alignment(.72, -.08),
  Alignment(.55, -.69),
];

class _FrozenCharacterArt extends StatelessWidget {
  const _FrozenCharacterArt({
    required this.name,
    required this.color,
    required this.asset,
    required this.imageKey,
    required this.width,
    required this.height,
  });

  final String name;
  final Color color;
  final String asset;
  final Key imageKey;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            bottom: 21,
            child: Image.asset(
              asset,
              key: imageKey,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _OlafCelebration extends StatelessWidget {
  const _OlafCelebration();

  @override
  Widget build(BuildContext context) => Center(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: .2, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        key: const Key('frozen_olaf_found'),
        width: 164,
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xF4FFFFFF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF4BB8E8), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0x8842D8FF), blurRadius: 24),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/olaf_has_nose.png',
              key: const Key('frozen_olaf_has_nose'),
              height: 112,
              fit: BoxFit.contain,
            ),
            const Text(
              '雪寶找回鼻子了！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF174F82),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SnowballHitOverlay extends StatelessWidget {
  const _SnowballHitOverlay();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ColoredBox(
      color: const Color(0x4439C9FF),
      child: Center(
        child: Container(
          key: const Key('frozen_snowball_hit'),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xF2FFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF3AAED8), width: 3),
          ),
          child: const Text(
            '被雪球撞到了！回到起點，雪球重新開始',
            style: TextStyle(
              color: Color(0xFF174F82),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SnowflakeRewardOverlay extends StatelessWidget {
  const _SnowflakeRewardOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(animation.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black.withValues(alpha: .2 * (1 - t))),
            Align(
              alignment: Alignment.lerp(
                const Alignment(0, -.05),
                const Alignment(-.82, .91),
                t,
              )!,
              child: Transform.translate(
                offset: Offset(0, -math.sin(t * math.pi) * 115),
                child: Transform.rotate(
                  angle: t * math.pi * 2,
                  child: Container(
                    key: const Key('frozen_snowflake_reward'),
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF37BDEB),
                        width: 4,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0xAA42D8FF), blurRadius: 24),
                      ],
                    ),
                    child: const GameItemArt(
                      type: GameItemArtType.magicSnowflake,
                      size: 55,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _CarrotPainter extends CustomPainter {
  const _CarrotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final carrot = Path()
      ..moveTo(size.width * .28, size.height * .32)
      ..quadraticBezierTo(
        size.width * .56,
        size.height * .25,
        size.width * .75,
        size.height * .40,
      )
      ..quadraticBezierTo(
        size.width * .60,
        size.height * .72,
        size.width * .32,
        size.height * .91,
      )
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .56,
        size.width * .28,
        size.height * .32,
      )
      ..close();
    canvas.save();
    canvas.rotate(-.22);
    canvas.drawShadow(carrot, Colors.black45, 4, false);
    canvas.drawPath(carrot, Paint()..color = const Color(0xFFFF8B2B));
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .09;
    for (final end in const [
      Offset(.20, .05),
      Offset(.38, .02),
      Offset(.49, .11),
    ]) {
      canvas.drawLine(
        Offset(size.width * .34, size.height * .33),
        Offset(size.width * end.dx, size.height * end.dy),
        leafPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MazePathPainter extends CustomPainter {
  const _MazePathPainter({required this.completedSteps});

  final int completedSteps;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var index = 0; index < _footsteps.length; index++) {
      final alignment = _footsteps[index];
      final point = Offset(
        (alignment.x + 1) * size.width / 2,
        (alignment.y + 1) * size.height / 2,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x88FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MazePathPainter oldDelegate) =>
      oldDelegate.completedSteps != completedSteps;
}

class _FrozenBackgroundPainter extends CustomPainter {
  const _FrozenBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF315D9E), Color(0xFF8FD8F4), Color(0xFFE9FAFF)],
        ).createShader(rect),
    );
    final mountain = Paint()..color = const Color(0x99E7F8FF);
    for (var index = 0; index < 5; index++) {
      final x = size.width * (index * .25 - .1);
      final peak = size.height * (.12 + (index.isEven ? .03 : .12));
      final path = Path()
        ..moveTo(x - size.width * .24, size.height * .58)
        ..lineTo(x + size.width * .12, peak)
        ..lineTo(x + size.width * .43, size.height * .58)
        ..close();
      canvas.drawPath(path, mountain);
    }
    canvas.drawOval(
      Rect.fromLTRB(
        -size.width * .12,
        size.height * .48,
        size.width * 1.1,
        size.height * 1.12,
      ),
      Paint()..color = const Color(0xDDF7FDFF),
    );
    final ice = Paint()
      ..color = const Color(0x4468D4F2)
      ..strokeWidth = 2;
    for (var index = 0; index < 34; index++) {
      final x = (index * 71 % 389) / 389 * size.width;
      final y = (index * 113 % 701) / 701 * size.height;
      canvas.drawCircle(Offset(x, y), 2 + index % 3, ice);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
