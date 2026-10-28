import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/game_item_art.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class MinnieGardenPage extends GetView<GameController> {
  const MinnieGardenPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop:
          !controller.minniePlutoSearching.value &&
          !controller.minnieRewardGiving.value,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _MinnieGardenBackground(),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(child: _scene()),
                  _instructionPanel(),
                  InventoryBar(
                    controller: controller,
                    onItemTap: (index, item) {
                      if (item.name == '米妮的紅色蝴蝶結') {
                        controller.returnRedBowToMinnie();
                      } else {
                        controller.inspectItem(index);
                      }
                    },
                  ),
                ],
              ),
            ),
            if (controller.minnieRewardGiving.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: _MinnieBowExchangeAnimation(
                    onBowReturned: controller.markMinnieBowReturned,
                    onCompleted: controller.completeMinnieMission,
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
              controller.minniePlutoSearching.value ||
                  controller.minnieRewardGiving.value
              ? null
              : Get.back,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xF2FFFFFF), Color(0xFFFCE4F1)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFB7D7), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: const Text(
              '第三關：米妮的花園',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF772852),
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
    final bowReturned = controller.minnieBowReturned.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Stack(
          children: [
            Positioned(
              right: compact ? 7 : constraints.maxWidth * .12,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  bowReturned
                      ? 'assets/images/minnine_red.png'
                      : 'assets/images/minnine_pink.png',
                  key: ValueKey(bowReturned ? 'minnie_red' : 'minnie_pink'),
                  height: compact ? 265 : 350,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (!controller.allMinnieSpotsSearched &&
                !controller.minnieRedBowFound.value)
              ..._searchSpots(constraints),
            if (controller.allMinnieSpotsSearched &&
                !controller.minniePlutoSearching.value &&
                !controller.minnieRedBowFound.value)
              Positioned(
                left: compact ? 16 : constraints.maxWidth * .14,
                bottom: 4,
                child: GestureDetector(
                  key: const Key('minnie_pluto_hint'),
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.startMinniePlutoSearch,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xF2FFFFFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFC44F),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          '點我，我來聞聞看！',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Image.asset(
                        'assets/images/pluto_cutout.png',
                        width: compact ? 145 : 205,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            if (controller.minnieRedBowFound.value &&
                !controller.minnieRewardGiving.value)
              Positioned(
                left: compact ? 18 : constraints.maxWidth * .16,
                bottom: 10,
                child: Image.asset(
                  'assets/images/pluto_cutout.png',
                  width: compact ? 125 : 180,
                  fit: BoxFit.contain,
                ),
              ),
            if (controller.minniePlutoSearching.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: _PlutoBowSearchAnimation(
                    compact: compact,
                    onCompleted: controller.completeMinniePlutoSearch,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _searchSpots(BoxConstraints constraints) {
    const positions = <(double, double)>[
      (.03, .07),
      (.37, .04),
      (.76, .07),
      (.03, .40),
      (.36, .36),
      (.04, .68),
    ];
    return List.generate(positions.length, (index) {
      final position = positions[index];
      return Positioned(
        left: constraints.maxWidth * position.$1,
        top: constraints.maxHeight * position.$2,
        child: _SearchGlowSpot(
          index: index,
          searched: controller.searchedMinnieSpots.contains(index),
          onTap: () => controller.searchMinnieSpot(index),
        ),
      );
    });
  }

  Widget _instructionPanel() {
    final text = controller.minnieRewardGiving.value
        ? '米妮正在把粉色蝴蝶結送給你…'
        : controller.minnieRedBowFound.value
        ? '紅色蝴蝶結已進入道具欄！點擊它還給米妮。'
        : controller.minniePlutoSearching.value
        ? '布魯托正在花園裡一直聞、一直聞…'
        : controller.allMinnieSpotsSearched
        ? '六個地方都沒有！布魯托來了，點擊它幫忙尋找。'
        : controller.searchedMinnieSpots.isEmpty
        ? '米妮：我的紅色蝴蝶結不見了，我好苦惱…幫我找找這 6 個發光的地方好嗎？'
        : '這裡也沒有。繼續尋找（${controller.searchedMinnieSpots.length}/6）。';
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB7D7), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFFC03978)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5D2947),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchGlowSpot extends StatefulWidget {
  const _SearchGlowSpot({
    required this.index,
    required this.searched,
    required this.onTap,
  });

  final int index;
  final bool searched;
  final VoidCallback onTap;

  @override
  State<_SearchGlowSpot> createState() => _SearchGlowSpotState();
}

class _SearchGlowSpotState extends State<_SearchGlowSpot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('minnie_spot_${widget.index}'),
    behavior: HitTestBehavior.opaque,
    onTap: widget.searched ? null : widget.onTap,
    child: AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.searched
              ? const Color(0x998E6B83)
              : Color.lerp(
                  const Color(0x99FFF4A8),
                  const Color(0xEEFFFFFF),
                  _pulse.value,
                ),
          border: Border.all(
            color: widget.searched ? Colors.white54 : const Color(0xFFFFD54F),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.searched
                  ? Colors.transparent
                  : const Color(0xCCFFF176),
              blurRadius: 12 + _pulse.value * 16,
              spreadRadius: _pulse.value * 4,
            ),
          ],
        ),
        child: Icon(
          widget.searched ? Icons.close_rounded : Icons.auto_awesome_rounded,
          color: widget.searched ? Colors.white : const Color(0xFFCB8A18),
          size: 31,
        ),
      ),
    ),
  );
}

class _PlutoBowSearchAnimation extends StatefulWidget {
  const _PlutoBowSearchAnimation({
    required this.compact,
    required this.onCompleted,
  });

  final bool compact;
  final VoidCallback onCompleted;

  @override
  State<_PlutoBowSearchAnimation> createState() =>
      _PlutoBowSearchAnimationState();
}

class _PlutoBowSearchAnimationState extends State<_PlutoBowSearchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 5500),
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
      final raw = _animation.value;
      final sniffT = Curves.easeInOut.transform((raw / .74).clamp(0.0, 1.0));
      final plutoAlignment = Alignment(
        -0.78 + sniffT * 1.30,
        .18 + math.sin(sniffT * math.pi * 5) * .42,
      );
      final bowT = Curves.easeInOutCubic.transform(
        ((raw - .76) / .24).clamp(0.0, 1.0),
      );
      final bowAlignment = Alignment.lerp(
        const Alignment(.55, .18),
        const Alignment(-.82, .92),
        bowT,
      )!;
      return Stack(
        children: [
          Align(
            alignment: plutoAlignment,
            child: Transform.translate(
              offset: Offset(0, -math.sin(sniffT * math.pi * 10).abs() * 8),
              child: Image.asset(
                'assets/images/pluto_cutout.png',
                key: const Key('pluto_sniffing'),
                width: widget.compact ? 145 : 205,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (raw < .76)
            Align(
              alignment: Alignment(0, -.75 + math.sin(raw * math.pi * 8) * .05),
              child: const Text(
                '聞聞…聞聞…',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
              ),
            ),
          if (raw >= .68)
            Align(
              alignment: bowAlignment,
              child: Transform.translate(
                offset: Offset(0, -math.sin(bowT * math.pi) * 115),
                child: Transform.rotate(
                  angle: bowT * math.pi * 2,
                  child: const GameItemArt(
                    key: Key('red_bow_to_inventory'),
                    type: GameItemArtType.redBow,
                    size: 62,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _MinnieBowExchangeAnimation extends StatefulWidget {
  const _MinnieBowExchangeAnimation({
    required this.onBowReturned,
    required this.onCompleted,
  });

  final VoidCallback onBowReturned;
  final VoidCallback onCompleted;

  @override
  State<_MinnieBowExchangeAnimation> createState() =>
      _MinnieBowExchangeAnimationState();
}

class _MinnieBowExchangeAnimationState
    extends State<_MinnieBowExchangeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  bool _markedReturned = false;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 4300),
          )
          ..addListener(() {
            if (!_markedReturned && _animation.value >= .42) {
              _markedReturned = true;
              widget.onBowReturned();
            }
          })
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
      final raw = _animation.value;
      final redT = Curves.easeInOutCubic.transform((raw / .42).clamp(0.0, 1.0));
      final pinkT = Curves.easeInOutCubic.transform(
        ((raw - .58) / .42).clamp(0.0, 1.0),
      );
      final redPosition = Alignment.lerp(
        const Alignment(-.82, .92),
        const Alignment(.62, -.02),
        redT,
      )!;
      final pinkPosition = Alignment.lerp(
        const Alignment(.62, -.02),
        const Alignment(-.82, .92),
        pinkT,
      )!;
      return Stack(
        children: [
          const ColoredBox(color: Color(0x441F0920)),
          if (raw < .48)
            Align(
              alignment: redPosition,
              child: Transform.translate(
                offset: Offset(0, -math.sin(redT * math.pi) * 125),
                child: Transform.rotate(
                  angle: redT * math.pi * 2,
                  child: const GameItemArt(
                    key: Key('red_bow_to_minnie'),
                    type: GameItemArtType.redBow,
                    size: 65,
                  ),
                ),
              ),
            ),
          if (raw >= .42)
            Align(
              alignment: const Alignment(0, -.62),
              child: Opacity(
                opacity: ((raw - .42) / .14).clamp(0, 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF8FC4),
                      width: 3,
                    ),
                  ),
                  child: const Text(
                    '謝謝你！這個粉色蝴蝶結送給你！',
                    style: TextStyle(
                      color: Color(0xFF7A2852),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          if (raw >= .58)
            Align(
              alignment: pinkPosition,
              child: Transform.translate(
                offset: Offset(0, -math.sin(pinkT * math.pi) * 125),
                child: Transform.rotate(
                  angle: pinkT * math.pi * 2,
                  child: const GameItemArt(
                    key: Key('pink_bow_reward'),
                    type: GameItemArtType.pinkBow,
                    size: 65,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _MinnieGardenBackground extends StatelessWidget {
  const _MinnieGardenBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _MinnieGardenPainter(),
    child: const SizedBox.expand(),
  );
}

class _MinnieGardenPainter extends CustomPainter {
  const _MinnieGardenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height * .66);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF91D9F4), Color(0xFFFFD7E8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(sky),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .58, size.width, size.height * .42),
      Paint()..color = const Color(0xFF72B95F),
    );
    final path = Path()
      ..moveTo(size.width * .34, size.height)
      ..lineTo(size.width * .47, size.height * .56)
      ..lineTo(size.width * .62, size.height * .56)
      ..lineTo(size.width * .78, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFE2B0));
    final house = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .57,
        size.height * .18,
        size.width * .35,
        size.height * .42,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(house, Paint()..color = const Color(0xFFF08DB8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .68,
          size.height * .38,
          size.width * .12,
          size.height * .22,
        ),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xFF8A4C72),
    );
    final flowerPaint = Paint()..color = const Color(0xFFFFF176);
    final centerPaint = Paint()..color = const Color(0xFFF06A9D);
    for (var index = 0; index < 12; index++) {
      final x = (index * 47.0 + 18) % size.width;
      final y = size.height * (.64 + (index % 3) * .08);
      for (var petal = 0; petal < 5; petal++) {
        final angle = petal * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(x + math.cos(angle) * 7, y + math.sin(angle) * 7),
          5,
          flowerPaint,
        );
      }
      canvas.drawCircle(Offset(x, y), 4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
