import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/game_widgets.dart';
import '../widgets/mission_inventory.dart';

class AladdinFlightPage extends StatefulWidget {
  const AladdinFlightPage({super.key});

  @override
  State<AladdinFlightPage> createState() => _AladdinFlightPageState();
}

class _AladdinFlightPageState extends State<AladdinFlightPage>
    with SingleTickerProviderStateMixin {
  static const _missionIndex = 4;
  static const _waveCount = 12;
  static const _jafarMaxHealth = 12;

  final GameController controller = Get.find<GameController>();
  late final AnimationController _projectile;
  Timer? _waveTimer;
  Timer? _feedbackTimer;
  Size _sceneSize = Size.zero;
  bool _waveActive = false;
  bool _hitThisWave = false;
  bool _magicHit = false;
  bool _jafarHit = false;
  int _waveSeed = 0;

  static const _story = <StoryLine>[
    StoryLine(speaker: '阿拉丁', text: '賈方把精靈封印在神燈裡，還在天空布滿了危險魔法！'),
    StoryLine(speaker: '魔毯', text: '請用上下左右控制飛行，閃開所有從右邊飛來的攻擊。'),
    StoryLine(speaker: '阿拉丁', text: '撐過全部攻擊，我們就能接近賈方並把精靈救回來！'),
  ];

  static const _waveLanes = <List<int>>[
    [0],
    [2],
    [1],
    [0, 1],
    [1, 2],
    [0, 2],
    [1],
    [0, 2],
    [0, 1],
    [2],
    [1, 2],
    [0],
  ];

  static const _magicIcons = <IconData>[
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.auto_awesome_rounded,
    Icons.flare_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _projectile =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2500),
          )
          ..addListener(_checkProjectileCollision)
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed || !_waveActive) return;
            _waveActive = false;
            if (!_hitThisWave) controller.recordAladdinDodge();
            if (mounted) setState(() {});
            _waveTimer = Timer(const Duration(milliseconds: 380), _launchWave);
          });
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    _feedbackTimer?.cancel();
    _projectile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final dialogueStep = controller.prototypeDialogueStep(_missionIndex);
    final dodged = controller.prototypeProgress(_missionIndex);
    final jafarHealth = controller.aladdinJafarHealth.value;
    final genieRescued = controller.aladdinGenieRescued.value;
    final wish = controller.aladdinWish.value;
    final column = controller.aladdinPlayerColumn.value;
    final row = controller.aladdinPlayerRow.value;
    if (dialogueStep >= _story.length && dodged < _waveCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _launchWave());
    }
    return PopScope(
      canPop: wish.isEmpty,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _AgrabahBackgroundPainter()),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: _scene(
                      dialogueStep: dialogueStep,
                      dodged: dodged,
                      jafarHealth: jafarHealth,
                      genieRescued: genieRescued,
                      column: column,
                      row: row,
                    ),
                  ),
                  _panel(
                    dialogueStep: dialogueStep,
                    dodged: dodged,
                    jafarHealth: jafarHealth,
                    genieRescued: genieRescued,
                    wish: wish,
                  ),
                  InventoryBar(controller: controller),
                ],
              ),
            ),
            if (_magicHit) const _MagicHitOverlay(),
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
          onPressed: controller.aladdinWish.value.isEmpty ? Get.back : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xEDFFF7D7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFC44D), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 9),
              ],
            ),
            child: const Text(
              '第 5 關：阿拉丁的魔毯救援',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF5D2D78),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scene({
    required int dialogueStep,
    required int dodged,
    required int jafarHealth,
    required bool genieRescued,
    required int column,
    required int row,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      _sceneSize = constraints.biggest;
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(
            left: 10,
            top: 6,
            child: _NameCard(
              name: '阿拉丁與魔毯',
              icon: Icons.air_rounded,
              color: Color(0xFF713C91),
            ),
          ),
          if (dialogueStep >= _story.length && dodged < _waveCount) ...[
            _player(column, row),
            if (_waveActive)
              AnimatedBuilder(
                animation: _projectile,
                builder: (context, child) => Stack(
                  children: _currentLanes
                      .map(
                        (lane) => _magicProjectile(lane, constraints.biggest),
                      )
                      .toList(),
                ),
              ),
          ],
          if (dodged >= _waveCount && jafarHealth > 0)
            _jafarBattle(jafarHealth),
          if (dodged >= _waveCount && jafarHealth == 0 && !genieRescued)
            const _DefeatedJafar(),
          if (genieRescued) const _FreedGenie(),
        ],
      );
    },
  );

  Widget _player(int column, int row) => AnimatedAlign(
    key: const Key('aladdin_carpet_player'),
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    alignment: _playerAlignment(column, row),
    child: const _AladdinCarpet(),
  );

  Widget _magicProjectile(int lane, Size size) {
    final center = _projectileCenter(lane, size);
    final icon = _magicIcons[(_waveSeed + lane) % _magicIcons.length];
    final colors = const [
      Color(0xFFFF4B62),
      Color(0xFF9F55E7),
      Color(0xFFFFA52D),
    ];
    return Positioned(
      key: ValueKey('aladdin_magic_${_waveSeed}_$lane'),
      left: center.dx - 25,
      top: center.dy - 25,
      child: Transform.rotate(
        angle: _projectile.value * math.pi * 5,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xEFFFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: colors[lane], width: 3),
            boxShadow: [BoxShadow(color: colors[lane], blurRadius: 18)],
          ),
          child: Icon(icon, color: colors[lane], size: 29),
        ),
      ),
    );
  }

  Widget _jafarBattle(int health) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: LinearProgressIndicator(
            value: health / _jafarMaxHealth,
            minHeight: 12,
            color: const Color(0xFFE53445),
            backgroundColor: const Color(0x55FFFFFF),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 9),
        GestureDetector(
          key: const Key('aladdin_jafar_target'),
          behavior: HitTestBehavior.opaque,
          onTap: _hitJafar,
          child: AnimatedScale(
            scale: _jafarHit ? .82 : 1,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 138,
              height: 166,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF32102E), Color(0xFF9D183D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: _jafarHit ? Colors.white : const Color(0xFFFFC44D),
                  width: _jafarHit ? 5 : 3,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0xAAE53445), blurRadius: 24),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_4_rounded, color: Colors.white, size: 78),
                  Text(
                    '賈方',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '快速點擊攻擊！',
                    style: TextStyle(color: Color(0xFFFFD88A), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _panel({
    required int dialogueStep,
    required int dodged,
    required int jafarHealth,
    required bool genieRescued,
    required String wish,
  }) {
    final inDialogue = dialogueStep < _story.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 7),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xF5FFF9E7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFC44D), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inDialogue) ...[
            Text(
              _story[dialogueStep].speaker,
              style: const TextStyle(
                color: Color(0xFF5D2D78),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _story[dialogueStep].text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
            ),
            const SizedBox(height: 8),
            MagicButton(
              key: const Key('aladdin_dialogue_next'),
              label: dialogueStep == _story.length - 1 ? '坐上魔毯出發' : '繼續',
              icon: Icons.navigate_next_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
              onPressed: () => controller.advancePrototypeDialogue(
                _missionIndex,
                _story.length,
              ),
            ),
          ] else if (dodged < _waveCount) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '閃避賈方的魔法',
                        style: TextStyle(
                          color: Color(0xFF5D2D78),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: dodged / _waveCount,
                        minHeight: 10,
                        color: const Color(0xFF8D49BE),
                        backgroundColor: const Color(0x228D49BE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 3),
                      Text('$dodged / $_waveCount 波'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _directionControls(),
              ],
            ),
          ] else if (jafarHealth > 0) ...[
            Text(
              '賈方剩餘魔力：$jafarHealth / $_jafarMaxHealth',
              style: const TextStyle(
                color: Color(0xFF9D183D),
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text('快速點擊畫面中央的賈方！'),
          ] else if (!genieRescued) ...[
            const Text(
              '賈方被打敗了！神燈的封印正在消失。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5D2D78),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            MagicButton(
              key: const Key('aladdin_rescue_genie'),
              label: '打開神燈救出精靈',
              icon: Icons.light_mode_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: controller.rescueAladdinGenie,
            ),
          ] else if (wish.isEmpty) ...[
            const Text(
              '精靈：感謝你把我救回來！我送你一個願望，選一個吧！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A5F98),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            _wishChoices(),
          ] else ...[
            Text(
              '你選擇了「$wish願望」！精靈會讓這份祝福陪著你。',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A5F98),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            MagicButton(
              key: const Key('aladdin_finish_mission'),
              label: '帶著願望回到城堡',
              icon: Icons.auto_awesome_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: controller.completeAladdinMission,
            ),
          ],
        ],
      ),
    );
  }

  Widget _directionControls() => SizedBox(
    width: 124,
    height: 112,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: _directionButton(
            key: const Key('aladdin_move_up'),
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: () => controller.moveAladdin(0, -1),
          ),
        ),
        Positioned(
          bottom: 0,
          child: _directionButton(
            key: const Key('aladdin_move_down'),
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => controller.moveAladdin(0, 1),
          ),
        ),
        Positioned(
          left: 0,
          child: _directionButton(
            key: const Key('aladdin_move_left'),
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: () => controller.moveAladdin(-1, 0),
          ),
        ),
        Positioned(
          right: 0,
          child: _directionButton(
            key: const Key('aladdin_move_right'),
            icon: Icons.keyboard_arrow_right_rounded,
            onTap: () => controller.moveAladdin(1, 0),
          ),
        ),
        const Icon(Icons.air_rounded, color: Color(0xFF8D49BE), size: 23),
      ],
    ),
  );

  Widget _directionButton({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) => GestureDetector(
    key: key,
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8D49BE), Color(0xFF45216A)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD873), width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 29),
    ),
  );

  Widget _wishChoices() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 7,
    runSpacing: 7,
    children: const ['勇氣', '幸福', '冒險', '友誼']
        .map(
          (wish) => GestureDetector(
            key: ValueKey('aladdin_wish_$wish'),
            onTap: () => controller.chooseAladdinWish(wish),
            child: Container(
              width: 116,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FB9E9), Color(0xFF3154A1)],
                ),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFFFD873), width: 2),
              ),
              child: Text(
                '$wish願望',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        )
        .toList(),
  );

  List<int> get _currentLanes => _waveLanes[_waveSeed % _waveLanes.length];

  void _launchWave() {
    if (!mounted ||
        _waveActive ||
        controller.completedMissions.value != _missionIndex ||
        controller.prototypeDialogueStep(_missionIndex) < _story.length ||
        controller.prototypeProgress(_missionIndex) >= _waveCount) {
      return;
    }
    _waveTimer?.cancel();
    setState(() {
      _waveActive = true;
      _hitThisWave = false;
      _waveSeed = controller.prototypeProgress(_missionIndex);
    });
    _projectile.forward(from: 0);
  }

  void _checkProjectileCollision() {
    if (!_waveActive || _hitThisWave || _sceneSize.isEmpty) return;
    final player = _alignmentCenter(
      _playerAlignment(
        controller.aladdinPlayerColumn.value,
        controller.aladdinPlayerRow.value,
      ),
      _sceneSize,
    );
    final hit = _currentLanes.any((lane) {
      final magic = _projectileCenter(lane, _sceneSize);
      return (magic.dx - player.dx).abs() < 54 &&
          (magic.dy - player.dy).abs() < 47;
    });
    if (!hit) return;
    _hitThisWave = true;
    _waveActive = false;
    _projectile.stop();
    _feedbackTimer?.cancel();
    if (mounted) setState(() => _magicHit = true);
    _feedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _magicHit = false);
      _launchWave();
    });
  }

  void _hitJafar() {
    if (controller.aladdinJafarHealth.value <= 0) return;
    controller.hitAladdinJafar();
    _feedbackTimer?.cancel();
    setState(() => _jafarHit = true);
    _feedbackTimer = Timer(const Duration(milliseconds: 130), () {
      if (mounted) setState(() => _jafarHit = false);
    });
  }

  Offset _projectileCenter(int lane, Size size) {
    final x = size.width + 35 - _projectile.value * (size.width + 80);
    final alignment = Alignment(0, const [-.55, 0.0, .55][lane]);
    final y = _alignmentCenter(alignment, size).dy;
    return Offset(x, y);
  }

  Alignment _playerAlignment(int column, int row) =>
      Alignment(const [-.72, 0.0, .72][column], const [-.55, 0.0, .55][row]);

  Offset _alignmentCenter(Alignment alignment, Size size) => Offset(
    (alignment.x + 1) * size.width / 2,
    (alignment.y + 1) * size.height / 2,
  );
}

class _AladdinCarpet extends StatelessWidget {
  const _AladdinCarpet();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 78,
    height: 72,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 7,
          child: Transform.rotate(
            angle: -.08,
            child: Container(
              width: 76,
              height: 31,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE14A99), Color(0xFF66399D)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD873), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x884A2B7B), blurRadius: 12),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          child: Icon(Icons.person_rounded, color: Color(0xFF51266F), size: 46),
        ),
      ],
    ),
  );
}

class _NameCard extends StatelessWidget {
  const _NameCard({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xEFFFF7D7),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _DefeatedJafar extends StatelessWidget {
  const _DefeatedJafar();

  @override
  Widget build(BuildContext context) => Center(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: .18),
      duration: const Duration(milliseconds: 1200),
      builder: (context, opacity, child) => Opacity(
        opacity: opacity,
        child: Transform.scale(scale: .65 + opacity * .35, child: child),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_4_rounded, color: Color(0xFF8E173B), size: 105),
          Text(
            '賈方的魔法消失了！',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          Icon(Icons.light_mode_rounded, color: Color(0xFFFFD873), size: 58),
        ],
      ),
    ),
  );
}

class _FreedGenie extends StatelessWidget {
  const _FreedGenie();

  @override
  Widget build(BuildContext context) => Center(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: .25, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        key: const Key('aladdin_freed_genie'),
        width: 160,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF71D9FF), Color(0xFF2875C7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(42),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xAA56CFFF), blurRadius: 28),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face_rounded, color: Colors.white, size: 82),
            Text(
              '神燈精靈',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MagicHitOverlay extends StatelessWidget {
  const _MagicHitOverlay();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: ColoredBox(
      color: Color(0x55FF274A),
      child: Center(
        child: Text(
          '被魔法擊中了！這一波重新開始',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
      ),
    ),
  );
}

class _AgrabahBackgroundPainter extends CustomPainter {
  const _AgrabahBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17184D), Color(0xFF553078), Color(0xFFFF9B57)],
        ).createShader(rect),
    );
    final moon = Paint()..color = const Color(0xFFFFE7A8);
    canvas.drawCircle(Offset(size.width * .78, size.height * .18), 35, moon);
    final skyline = Paint()..color = const Color(0xFF2B1748);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .72);
    for (var index = 0; index < 9; index++) {
      final x = size.width * index / 8;
      final top = size.height * (.66 - (index % 3) * .08);
      path
        ..lineTo(x, top)
        ..lineTo(x + size.width * .08, top)
        ..lineTo(x + size.width * .08, size.height * .75);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, skyline);
    final star = Paint()..color = const Color(0xAAFFF4C2);
    for (var index = 0; index < 24; index++) {
      final x = (index * 67 % 379) / 379 * size.width;
      final y = (index * 41 % 211) / 211 * size.height * .48;
      canvas.drawCircle(Offset(x, y), 1.5 + index % 2, star);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
