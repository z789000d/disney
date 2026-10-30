import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
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
                child: _MinnieBowExchangeAnimation(
                  onBowReturned: controller.markMinnieBowReturned,
                  onCompleted: controller.completeMinnieMission,
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
                left: compact ? 8 : constraints.maxWidth * .10,
                bottom: 0,
                child: _PlutoHelpArrival(
                  compact: compact,
                  asked: controller.minniePlutoAsked.value,
                  onAsk: controller.askMinniePlutoForHelp,
                  onStartSearch: controller.startMinniePlutoSearch,
                ),
              ),
            if (controller.minniePlutoSearching.value)
              Positioned.fill(
                child: _PlutoBowSearchAnimation(
                  compact: compact,
                  onCompleted: controller.completeMinniePlutoSearch,
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
    final plutoSpeaking =
        controller.minniePlutoSearching.value ||
        (controller.allMinnieSpotsSearched &&
            controller.minniePlutoAsked.value);
    final speaker = plutoSpeaking ? '布魯托' : '米妮';
    final text = controller.minnieRewardGiving.value
        ? '米妮正在把粉色蝴蝶結送給你…'
        : controller.minnieRedBowFound.value
        ? '紅色蝴蝶結已進入道具欄！點擊它還給米妮。'
        : controller.minniePlutoSearching.value
        ? '布魯托正在花園裡一直聞、一直聞…'
        : controller.allMinnieSpotsSearched
        ? controller.minniePlutoAsked.value
              ? '布魯托：交給我，我來聞聞看！按下一步開始尋找。'
              : '六個地方都沒有！請布魯托幫忙看看。'
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
      child: CharacterDialogueLine(
        speaker: speaker,
        text: text,
        avatarSize: 44,
        speakerColor: const Color(0xFFC03978),
        textColor: const Color(0xFF5D2947),
        textAlign: TextAlign.center,
        assetOverride: speaker == '米妮' && controller.minnieBowReturned.value
            ? 'assets/images/minnine_red.png'
            : null,
      ),
    );
  }
}

class _PlutoHelpArrival extends StatelessWidget {
  const _PlutoHelpArrival({
    required this.compact,
    required this.asked,
    required this.onAsk,
    required this.onStartSearch,
  });

  final bool compact;
  final bool asked;
  final VoidCallback onAsk;
  final VoidCallback onStartSearch;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: const Key('minnie_pluto_arrival'),
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1400),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(-70 * (1 - value), 12 * (1 - value)),
        child: child,
      ),
    ),
    child: SizedBox(
      width: compact ? 205 : 270,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xF2FFFFFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFC44F), width: 2),
            ),
            child: Text(
              asked ? '汪！交給我，我來聞聞看！' : '布魯托慢慢走過來了…',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Image.asset(
            'assets/images/pluto_cutout.png',
            width: compact ? 115 : 170,
            fit: BoxFit.contain,
          ),
          MagicButton(
            key: ValueKey(
              asked ? 'minnie_pluto_start_search' : 'minnie_ask_pluto',
            ),
            label: asked ? '下一步：開始聞聞看' : '請布魯托幫忙看看',
            icon: asked ? Icons.search_rounded : Icons.pets_rounded,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            onPressed: asked ? onStartSearch : onAsk,
          ),
        ],
      ),
    ),
  );
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
  int _pauseStep = 0;
  bool _moving = true;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _animateTo(.68, const Duration(milliseconds: 4200), nextStep: 1);
  }

  Future<void> _animateTo(
    double target,
    Duration duration, {
    int? nextStep,
  }) async {
    if (mounted) setState(() => _moving = true);
    await _animation.animateTo(
      target,
      duration: duration,
      curve: Curves.linear,
    );
    if (!mounted) return;
    if (target >= 1) {
      widget.onCompleted();
    } else {
      setState(() {
        _moving = false;
        _pauseStep = nextStep ?? _pauseStep;
      });
    }
  }

  void _continueStory() {
    if (_moving) return;
    if (_pauseStep == 1) {
      _animateTo(.86, const Duration(milliseconds: 1500), nextStep: 2);
    } else {
      _animateTo(1, const Duration(milliseconds: 1300));
    }
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
      final sniffT = Curves.easeInOut.transform((raw / .68).clamp(0.0, 1.0));
      final sniffAlignment = Alignment(
        -0.78 + sniffT * 1.30,
        .18 + math.sin(sniffT * math.pi * 5) * .42,
      );
      final approachT = Curves.easeInOutCubic.transform(
        ((raw - .68) / .18).clamp(0.0, 1.0),
      );
      final giftT = Curves.easeInOutCubic.transform(
        ((raw - .86) / .08).clamp(0.0, 1.0),
      );
      final leaveT = Curves.easeInCubic.transform(
        ((raw - .92) / .08).clamp(0.0, 1.0),
      );
      final approachAlignment = Alignment.lerp(
        const Alignment(.52, .18),
        const Alignment(-.35, .45),
        approachT,
      )!;
      final plutoAlignment = raw < .68
          ? sniffAlignment
          : Alignment.lerp(
              approachAlignment,
              const Alignment(1.35, .18),
              leaveT,
            )!;
      final carryBowAlignment = Alignment.lerp(
        const Alignment(.55, .18),
        const Alignment(-.23, .43),
        approachT,
      )!;
      final bowAlignment = Alignment.lerp(
        carryBowAlignment,
        const Alignment(-.82, .92),
        giftT,
      )!;
      return Stack(
        children: [
          Align(
            alignment: plutoAlignment,
            child: Transform.translate(
              offset: Offset(0, -math.sin(sniffT * math.pi * 10).abs() * 8),
              child: Image.asset(
                'assets/images/pluto_cutout.png',
                key: Key(
                  raw >= .92
                      ? 'pluto_leaves_after_bow'
                      : raw >= .68
                      ? 'pluto_carries_red_bow'
                      : 'pluto_sniffing',
                ),
                width: widget.compact ? 145 : 205,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (raw < .62)
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
          if (raw >= .62 && raw < .79)
            const Align(
              alignment: Alignment(0, -.75),
              child: _GardenSpeechBubble(text: '汪！我找到蝴蝶結了！'),
            ),
          if (raw >= .79 && raw < .95)
            const Align(
              alignment: Alignment(0, -.75),
              child: _GardenSpeechBubble(text: '汪！這個蝴蝶結交給你！'),
            ),
          if (raw >= .62 && raw < .95)
            Align(
              alignment: bowAlignment,
              child: Transform.translate(
                offset: Offset(0, -math.sin(giftT * math.pi) * 115),
                child: Transform.rotate(
                  angle: giftT * math.pi * 2,
                  child: GameItemArt(
                    key: Key(
                      giftT > 0 ? 'red_bow_to_inventory' : 'red_bow_found',
                    ),
                    type: GameItemArtType.redBow,
                    size: 62,
                  ),
                ),
              ),
            ),
          if (!_moving && _pauseStep > 0)
            SafeArea(
              child: Align(
                alignment: const Alignment(0, .72),
                child: MagicButton(
                  key: ValueKey(
                    _pauseStep == 1
                        ? 'minnie_bow_found_next'
                        : 'minnie_search_next',
                  ),
                  label: _pauseStep == 1 ? '請布魯托拿過來' : '收下紅色蝴蝶結',
                  icon: _pauseStep == 1
                      ? Icons.pets_rounded
                      : Icons.redeem_rounded,
                  onPressed: _continueStory,
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _GardenSpeechBubble extends StatelessWidget {
  const _GardenSpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xF2FFFFFF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFFFC44F), width: 2),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF5D3A15),
        fontWeight: FontWeight.w900,
      ),
    ),
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
  int _pauseStep = 0;
  bool _moving = true;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 4300),
        )..addListener(() {
          if (!_markedReturned && _animation.value >= .42) {
            _markedReturned = true;
            widget.onBowReturned();
          }
        });
    _animateTo(.48, const Duration(milliseconds: 2060), nextStep: 1);
  }

  Future<void> _animateTo(
    double target,
    Duration duration, {
    int? nextStep,
  }) async {
    if (mounted) setState(() => _moving = true);
    await _animation.animateTo(
      target,
      duration: duration,
      curve: Curves.linear,
    );
    if (!mounted) return;
    if (target >= 1) {
      widget.onCompleted();
      return;
    }
    setState(() {
      _moving = false;
      _pauseStep = nextStep ?? _pauseStep;
    });
  }

  void _continueStory() {
    if (_moving) return;
    if (_pauseStep == 1) {
      _animateTo(.78, const Duration(milliseconds: 1290), nextStep: 2);
    } else {
      _animateTo(1, const Duration(milliseconds: 950));
    }
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
          if (!_moving && _pauseStep > 0)
            SafeArea(
              child: Align(
                alignment: const Alignment(0, .72),
                child: MagicButton(
                  key: ValueKey('minnie_exchange_next_$_pauseStep'),
                  label: _pauseStep == 1 ? '下一步：聽米妮說' : '收下粉色蝴蝶結',
                  icon: Icons.redeem_rounded,
                  onPressed: _continueStory,
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
