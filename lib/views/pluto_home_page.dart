import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class PlutoHomePage extends GetView<GameController> {
  const PlutoHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const _YardBackground(),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Obx(() {
              final compact = constraints.maxWidth < 650;
              return Stack(
                children: [
                  Positioned(
                    left: compact ? 12 : constraints.maxWidth * .07,
                    bottom: compact ? 190 : 165,
                    child: Image.asset(
                      'assets/images/pluto_house.png',
                      key: const Key('pluto_house'),
                      width: compact ? 245 : 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (!controller.boneGiving.value)
                    ..._searchGrassPatches(constraints),
                  if (!controller.boneGiving.value)
                    Positioned(
                      right: compact ? 20 : constraints.maxWidth * .1,
                      bottom: compact ? 185 : 165,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!controller.plutoBoneFound.value)
                            const _SpeechBubble(text: '好餓啊…我的骨頭去哪裡了？'),
                          if (controller.plutoBoneCollecting.value)
                            const _SpeechBubble(text: '汪！找到我的骨頭了！')
                          else if (controller.plutoBoneFound.value)
                            const _SpeechBubble(text: '汪！你找到了！點一下骨頭給我吧！'),
                          AnimatedPlutoCharacter(
                            width: compact ? 150 : 220,
                            talking: true,
                          ),
                        ],
                      ),
                    ),
                  if (!controller.boneGiving.value &&
                      controller.allPlutoGrassSearched)
                    Positioned(
                      left: compact
                          ? constraints.maxWidth * .38
                          : constraints.maxWidth * .43,
                      bottom: compact ? 205 : 185,
                      child: _BoneHotspot(controller: controller),
                    ),
                  if (controller.plutoBoneCollecting.value)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _BoneToInventoryAnimation(
                          compact: compact,
                          onCompleted: controller.completeBoneCollection,
                        ),
                      ),
                    ),
                  if (controller.boneGiving.value)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _PlutoRunHomeAnimation(
                          compact: compact,
                          onCompleted: controller.completePlutoMission,
                        ),
                      ),
                    ),
                  _header(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _bottomPanel(),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        MagicIconButton(
          tooltip: '回到城堡',
          onPressed:
              controller.boneGiving.value ||
                  controller.plutoBoneCollecting.value
              ? null
              : Get.back,
          icon: Icons.arrow_back_rounded,
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xEFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: const Text(
            '🏡 布魯托的家',
            style: TextStyle(
              color: Color(0xFF51300D),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _searchGrassPatches(BoxConstraints constraints) {
    const positions = <(double, double)>[
      (.07, .22),
      (.31, .17),
      (.55, .24),
      (.79, .18),
      (.23, .52),
      (.69, .51),
    ];
    return List<Widget>.generate(positions.length, (index) {
      final position = positions[index];
      return Positioned(
        left: constraints.maxWidth * position.$1,
        top: constraints.maxHeight * position.$2,
        child: _SearchGrassPatch(
          index: index,
          searched: controller.searchedPlutoGrass.contains(index),
          onTap: () => controller.searchPlutoGrass(index),
        ),
      );
    });
  }

  Widget _bottomPanel() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.boneGiving.value
                  ? Icons.home_rounded
                  : controller.plutoBoneCollecting.value
                  ? Icons.backpack_rounded
                  : controller.plutoBoneFound.value
                  ? Icons.backpack_rounded
                  : Icons.touch_app_rounded,
              color: const Color(0xFF7A4B16),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                controller.boneGiving.value
                    ? '先把骨頭交給布魯托，然後它會跑回狗屋…'
                    : controller.plutoBoneCollecting.value
                    ? '找到骨頭了！正在放進道具欄…'
                    : controller.plutoBoneFound.value
                    ? '骨頭已放進道具欄！點擊 🦴 交給布魯托。'
                    : controller.allPlutoGrassSearched
                    ? '六處都找過了！新的發光草叢出現了，快點它看看。'
                    : '先搜索院子裡的 6 叢草（${controller.searchedPlutoGrass.length}/6）。',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4A331D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      InventoryBar(
        controller: controller,
        onItemTap: (index, item) {
          if (item.name == '狗骨頭') {
            controller.giveBoneToPluto();
          } else {
            controller.inspectItem(index);
          }
        },
      ),
    ],
  );
}

class _SearchGrassPatch extends StatelessWidget {
  const _SearchGrassPatch({
    required this.index,
    required this.searched,
    required this.onTap,
  });

  final int index;
  final bool searched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '搜索第 ${index + 1} 叢草',
    child: GestureDetector(
      key: ValueKey('grass_patch_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: searched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 82,
        height: 74,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: searched ? const Color(0x554E772F) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: searched ? .42 : 1,
              child: const Text('🌿', style: TextStyle(fontSize: 66)),
            ),
            if (searched)
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF5B9D55),
                child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    ),
  );
}

class _BoneHotspot extends StatefulWidget {
  const _BoneHotspot({required this.controller});

  final GameController controller;

  @override
  State<_BoneHotspot> createState() => _BoneHotspotState();
}

class _BoneHotspotState extends State<_BoneHotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: const Key('bone_hotspot'),
    onTap: widget.controller.findPlutoBone,
    child: AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => SizedBox(
        width: 155,
        height: 120,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 98)),
            if (!widget.controller.plutoBoneFound.value)
              Positioned(
                top: 5 + _pulse.value * 5,
                right: 16,
                child: Opacity(
                  opacity: .45 + _pulse.value * .55,
                  child: const Text('✨', style: TextStyle(fontSize: 25)),
                ),
              )
            else
              const Positioned(
                top: 8,
                right: 12,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF58A76A),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _BoneToInventoryAnimation extends StatefulWidget {
  const _BoneToInventoryAnimation({
    required this.compact,
    required this.onCompleted,
  });

  final bool compact;
  final VoidCallback onCompleted;

  @override
  State<_BoneToInventoryAnimation> createState() =>
      _BoneToInventoryAnimationState();
}

class _BoneToInventoryAnimationState extends State<_BoneToInventoryAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1250),
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
        Alignment(widget.compact ? -.02 : -.05, .30),
        const Alignment(-.82, .90),
        t,
      )!;
      final arc = math.sin(t * math.pi) * 105;
      final scale = 1 - t * .42;
      return Stack(
        children: [
          Align(
            alignment: position,
            child: Transform.translate(
              offset: Offset(0, -arc),
              child: Transform.rotate(
                angle: t * math.pi * 2,
                child: Transform.scale(
                  scale: scale,
                  child: const Text(
                    '🦴',
                    key: Key('bone_to_inventory'),
                    style: TextStyle(fontSize: 52),
                  ),
                ),
              ),
            ),
          ),
          if (t > .78)
            const Align(
              alignment: Alignment(-.82, .78),
              child: Text('✨', style: TextStyle(fontSize: 30)),
            ),
        ],
      );
    },
  );
}

class _PlutoRunHomeAnimation extends StatefulWidget {
  const _PlutoRunHomeAnimation({
    required this.compact,
    required this.onCompleted,
  });

  final bool compact;
  final VoidCallback onCompleted;

  @override
  State<_PlutoRunHomeAnimation> createState() => _PlutoRunHomeAnimationState();
}

class _PlutoRunHomeAnimationState extends State<_PlutoRunHomeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 4000),
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
      const giftEnd = .30;
      final raw = _animation.value;
      final giftT = Curves.easeInOutCubic.transform(
        (raw / giftEnd).clamp(0.0, 1.0),
      );
      final runT = Curves.easeInOutCubic.transform(
        ((raw - giftEnd) / (1 - giftEnd)).clamp(0.0, 1.0),
      );
      final alignment = Alignment.lerp(
        const Alignment(.68, .08),
        Alignment(widget.compact ? -.38 : -.42, .12),
        runT,
      )!;
      final enteringHouse = ((runT - .72) / .28).clamp(0.0, 1.0);
      final scale = 1 - enteringHouse * .72;
      final bounce = math.sin(runT * math.pi * 8).abs() * (1 - runT) * 18;
      final bonePosition = Alignment.lerp(
        const Alignment(-.82, .90),
        const Alignment(.66, .10),
        giftT,
      )!;
      final boneArc = math.sin(giftT * math.pi) * 120;
      return Stack(
        children: [
          if (raw < giftEnd) ...[
            Align(
              alignment: const Alignment(.68, .08),
              child: Image.asset(
                'assets/images/pluto_cutout.png',
                width: widget.compact ? 150 : 220,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: bonePosition,
              child: Transform.translate(
                offset: Offset(0, -boneArc),
                child: Transform.rotate(
                  angle: giftT * math.pi * 2,
                  child: const Text(
                    '🦴',
                    key: Key('bone_to_pluto'),
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
          ] else
            Align(
              alignment: alignment,
              child: Transform.translate(
                offset: Offset(0, -bounce),
                child: Opacity(
                  opacity: 1 - enteringHouse,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(-scale, scale, 1),
                    child: Image.asset(
                      'assets/images/pluto_has_bone.png',
                      key: const Key('pluto_has_bone'),
                      width: widget.compact ? 175 : 245,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          if (raw >= giftEnd && runT < .20)
            Align(
              alignment: const Alignment(.66, -.42),
              child: Opacity(
                opacity: (1 - runT / .20).clamp(0, 1),
                child: const Text('❤️ 汪！', style: TextStyle(fontSize: 34)),
              ),
            ),
          if (runT > .76)
            Align(
              alignment: Alignment(widget.compact ? -.4 : -.44, -.14),
              child: Opacity(
                opacity: math.sin(enteringHouse * math.pi).clamp(0, 1),
                child: const Text('✨', style: TextStyle(fontSize: 42)),
              ),
            ),
        ],
      );
    },
  );
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 9)],
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF4B3018),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _YardBackground extends StatelessWidget {
  const _YardBackground();

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8DD8FF), Color(0xFFEAF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      const Align(
        alignment: Alignment(0, .65),
        child: SizedBox(
          height: 360,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8DCB55), Color(0xFF3F8E3D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      for (final cloud in const [
        (Alignment(-.72, -.78), 55.0),
        (Alignment(.08, -.86), 42.0),
        (Alignment(.7, -.72), 62.0),
      ])
        Align(
          alignment: cloud.$1,
          child: Text(
            '☁️',
            style: TextStyle(fontSize: cloud.$2, color: Colors.white),
          ),
        ),
    ],
  );
}
