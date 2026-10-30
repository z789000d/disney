import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedPrincessCharacter extends StatefulWidget {
  const AnimatedPrincessCharacter({
    super.key,
    this.width = 170,
    this.talking = false,
  });

  final double width;
  final bool talking;

  @override
  State<AnimatedPrincessCharacter> createState() =>
      _AnimatedPrincessCharacterState();
}

class _AnimatedPrincessCharacterState extends State<AnimatedPrincessCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final wave = math.sin(_controller.value * math.pi * 2);
      return Transform.translate(
        offset: Offset(0, wave * 3),
        child: Transform.scale(
          scaleY: 1 + wave * .008,
          child: _CharacterGlow(
            active: widget.talking,
            child: _CharacterImage(
              asset: 'assets/images/princess_cutout.png',
              width: widget.width,
              height: widget.width * 1.55,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      );
    },
  );
}

class AnimatedMickeyCharacter extends StatefulWidget {
  const AnimatedMickeyCharacter({
    super.key,
    this.width = 155,
    this.talking = false,
  });

  final double width;
  final bool talking;

  @override
  State<AnimatedMickeyCharacter> createState() =>
      _AnimatedMickeyCharacterState();
}

class _AnimatedMickeyCharacterState extends State<AnimatedMickeyCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final wave = math.sin(_controller.value * math.pi * 2);
      return Transform.translate(
        offset: Offset(0, wave.abs() * -5),
        child: _CharacterGlow(
          active: widget.talking,
          child: Transform.rotate(
            angle: wave * .018,
            child: _CharacterImage(
              asset: 'assets/images/mickey_cutout.png',
              width: widget.width,
              height: widget.width * 1.48,
            ),
          ),
        ),
      );
    },
  );
}

class AnimatedPlutoCharacter extends StatefulWidget {
  const AnimatedPlutoCharacter({
    super.key,
    this.width = 175,
    this.talking = false,
  });

  final double width;
  final bool talking;

  @override
  State<AnimatedPlutoCharacter> createState() => _AnimatedPlutoCharacterState();
}

class _AnimatedPlutoCharacterState extends State<AnimatedPlutoCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final bounce = Curves.easeInOut.transform(_controller.value);
      return Transform.translate(
        offset: Offset(0, -bounce * 5),
        child: Transform.rotate(
          angle: (bounce - .5) * .035,
          child: _CharacterGlow(
            active: widget.talking,
            child: _CharacterImage(
              asset: 'assets/images/pluto_cutout.png',
              width: widget.width,
              height: widget.width * .92,
            ),
          ),
        ),
      );
    },
  );
}

class AnimatedCastStage extends StatelessWidget {
  const AnimatedCastStage({
    super.key,
    required this.princessName,
    required this.speaker,
    this.compact = false,
    this.showPluto = false,
  });

  final String princessName;
  final String speaker;
  final bool compact;
  final bool showPluto;

  @override
  Widget build(BuildContext context) {
    final princessWidth = compact ? 105.0 : 155.0;
    final mickeyWidth = compact ? 94.0 : 140.0;
    final plutoWidth = compact ? 100.0 : 150.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedPrincessCharacter(
              width: princessWidth,
              talking: speaker == princessName,
            ),
            _nameTag(princessName),
          ],
        ),
        SizedBox(width: compact ? 20 : 72),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedMickeyCharacter(
              width: mickeyWidth,
              talking: speaker == '米奇',
            ),
            _nameTag('米奇'),
          ],
        ),
        if (showPluto) ...[
          SizedBox(width: compact ? 10 : 34),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedPlutoCharacter(
                width: plutoWidth,
                talking: speaker == '布魯托',
              ),
              _nameTag('布魯托'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _nameTag(String name) => Container(
    margin: const EdgeInsets.only(top: 2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xD92A2157),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white70),
    ),
    child: Text(
      name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _CharacterImage extends StatelessWidget {
  const _CharacterImage({
    required this.asset,
    required this.width,
    required this.height,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double width;
  final double height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(width * .18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x440E0A42),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(width * .15),
      child: Image.asset(asset, fit: BoxFit.contain, alignment: alignment),
    ),
  );
}

class CharacterDialogueAvatar extends StatelessWidget {
  const CharacterDialogueAvatar({
    super.key,
    required this.speaker,
    this.size = 76,
    this.assetOverride,
  });

  final String speaker;
  final double size;
  final String? assetOverride;

  @override
  Widget build(BuildContext context) {
    final asset = assetOverride ?? _assetForSpeaker(speaker);
    return Container(
      key: ValueKey('dialogue_avatar_$speaker'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8E68C7), width: 3),
        boxShadow: const [BoxShadow(color: Color(0x330E0A42), blurRadius: 10)],
      ),
      child: ClipOval(
        child: asset == null
            ? ColoredBox(
                color: const Color(0xFFE9DFFF),
                child: Center(
                  child: Text(
                    speaker.isEmpty ? '?' : speaker.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF5D328A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
      ),
    );
  }

  String? _assetForSpeaker(String speaker) => switch (speaker) {
    '米奇' => 'assets/images/mickey_cutout.png',
    '布魯托' => 'assets/images/pluto_cutout.png',
    '米妮' => 'assets/images/minnine_pink.png',
    '胡迪' => 'assets/images/woody.png',
    '巴斯光年' => 'assets/images/bause.png',
    '彈簧狗' => 'assets/images/slinky_dog.png',
    '熊抱哥' => 'assets/images/lotso.png',
    '三眼怪' => 'assets/images/three_eye.png',
    '札克' => 'assets/images/zurg.png',
    '安娜' => 'assets/images/anna.png',
    '艾莎' => 'assets/images/elsa.png',
    '雪寶' => 'assets/images/olaf_no_nose.png',
    '阿拉丁' || '魔毯' || '阿拉丁與魔毯' => 'assets/images/aladdin_carpet.png',
    '賈方' => 'assets/images/jafar.png',
    '精靈' || '神燈精靈' => 'assets/images/genie.png',
    _ => null,
  };
}

class CharacterDialogueLine extends StatelessWidget {
  const CharacterDialogueLine({
    super.key,
    required this.speaker,
    required this.text,
    this.avatarSize = 52,
    this.speakerColor = const Color(0xFF6D4DCE),
    this.textColor = const Color(0xFF332B40),
    this.maxLines = 3,
    this.textAlign = TextAlign.left,
    this.assetOverride,
  });

  final String speaker;
  final String text;
  final double avatarSize;
  final Color speakerColor;
  final Color textColor;
  final int maxLines;
  final TextAlign textAlign;
  final String? assetOverride;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CharacterDialogueAvatar(
        speaker: speaker,
        size: avatarSize,
        assetOverride: assetOverride,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: textAlign == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              speaker,
              style: TextStyle(
                color: speakerColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _CharacterGlow extends StatelessWidget {
  const _CharacterGlow({required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 280),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(90),
      boxShadow: active
          ? const [
              BoxShadow(
                color: Color(0xB3FFF19B),
                blurRadius: 28,
                spreadRadius: 7,
              ),
            ]
          : const [],
    ),
    child: child,
  );
}

class PrincessPainter extends CustomPainter {
  const PrincessPainter({required this.breath});
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 248);
    final outline = Paint()..color = const Color(0xFF633969);
    final hair = Paint()..color = const Color(0xFFFFD85C);
    final hairShade = Paint()..color = const Color(0xFFE8A83B);
    final skin = Paint()..color = const Color(0xFFFFF6F0);
    final purple = Paint()..color = const Color(0xFF8B58BC);
    final lavender = Paint()..color = const Color(0xFFC795DE);
    final pink = Paint()..color = const Color(0xFFF0B5D3);

    // Rapunzel-like signature: an enormous golden braid flowing to the ground.
    final hairMass = Path()
      ..moveTo(49, 45)
      ..cubicTo(17, 75, 31, 136, 14, 178)
      ..cubicTo(2, 208, 25, 237, 54, 226)
      ..cubicTo(72, 219, 70, 190, 80, 167)
      ..cubicTo(91, 195, 104, 230, 137, 230)
      ..cubicTo(154, 207, 130, 169, 139, 125)
      ..cubicTo(146, 86, 122, 48, 107, 42)
      ..close();
    canvas.drawPath(hairMass, hairShade);
    canvas.drawPath(
      hairMass,
      Paint()
        ..color = const Color(0xFFFFD85C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < 6; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(30 + i * 19, 202 + (i.isEven ? -5 : 5)),
          width: 30,
          height: 19,
        ),
        i.isEven ? hair : hairShade,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(80, 62), width: 70, height: 77),
      outline,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(80, 63), width: 64, height: 71),
      skin,
    );
    canvas.drawArc(
      const Rect.fromLTWH(46, 25, 68, 58),
      math.pi * .86,
      math.pi * 1.48,
      true,
      hair,
    );
    canvas.drawArc(
      const Rect.fromLTWH(53, 30, 35, 50),
      math.pi * 1.18,
      math.pi * 1.0,
      true,
      hairShade,
    );

    // Oversized green eyes and freckles make the face much more recognizable.
    canvas.drawOval(
      const Rect.fromLTWH(55, 52, 22, 17),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      const Rect.fromLTWH(84, 52, 22, 17),
      Paint()..color = Colors.white,
    );
    for (final eye in const [Offset(68, 61), Offset(93, 61)]) {
      canvas.drawCircle(eye, 7, Paint()..color = const Color(0xFF68A449));
      canvas.drawCircle(eye, 3.3, Paint()..color = const Color(0xFF243723));
      canvas.drawCircle(
        eye.translate(1, -2),
        1.6,
        Paint()..color = Colors.white,
      );
    }
    canvas.drawArc(
      const Rect.fromLTWH(54, 45, 23, 13),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF8D6534)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      const Rect.fromLTWH(84, 45, 23, 13),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF8D6534)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final freckle in const [
      Offset(70, 72),
      Offset(75, 73),
      Offset(90, 72),
    ]) {
      canvas.drawCircle(freckle, .8, Paint()..color = const Color(0xFFD99C81));
    }
    canvas.drawArc(
      const Rect.fromLTWH(68, 72, 25, 15),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFC95776)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Flower details woven into the hair.
    for (final flower in const [
      Offset(46, 45),
      Offset(116, 72),
      Offset(128, 118),
      Offset(32, 173),
      Offset(72, 211),
    ]) {
      for (var p = 0; p < 5; p++) {
        final angle = p * math.pi * 2 / 5;
        canvas.drawCircle(
          flower + Offset(math.cos(angle) * 4, math.sin(angle) * 4),
          2.7,
          pink,
        );
      }
      canvas.drawCircle(flower, 2, Paint()..color = const Color(0xFFFFF3A5));
    }

    canvas.drawRect(
      Rect.fromCenter(center: const Offset(80, 101), width: 13, height: 22),
      skin,
    );
    canvas.drawOval(const Rect.fromLTWH(45, 96, 28, 27), lavender);
    canvas.drawOval(const Rect.fromLTWH(88, 96, 28, 27), lavender);
    final skirt = Path()
      ..moveTo(54, 118)
      ..quadraticBezierTo(80, 106 + breath, 106, 118)
      ..lineTo(122, 215)
      ..quadraticBezierTo(80, 227, 38, 215)
      ..close();
    canvas.drawPath(skirt, outline);
    canvas.drawPath(
      Path()
        ..moveTo(57, 119)
        ..quadraticBezierTo(80, 109 + breath, 103, 119)
        ..lineTo(116, 210)
        ..quadraticBezierTo(80, 220, 44, 210)
        ..close(),
      lavender,
    );
    canvas.drawPath(
      Path()
        ..moveTo(79, 120)
        ..lineTo(93, 211)
        ..lineTo(67, 216)
        ..close(),
      pink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(58, 105, 44, 54),
        const Radius.circular(12),
      ),
      purple,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(65, 108, 30, 47),
        const Radius.circular(9),
      ),
      lavender,
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(69, 116 + i * 9),
        Offset(91, 122 + i * 9),
        Paint()
          ..color = const Color(0xFFFFD4E9)
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(91, 116 + i * 9),
        Offset(69, 122 + i * 9),
        Paint()
          ..color = const Color(0xFFFFD4E9)
          ..strokeWidth = 2,
      );
    }

    final armPaint = Paint()
      ..color = skin.color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(55, 116), const Offset(37, 164), armPaint);
    canvas.drawLine(const Offset(105, 116), const Offset(123, 158), armPaint);
    canvas.drawCircle(const Offset(36, 165), 5, skin);
    canvas.drawCircle(const Offset(124, 159), 5, skin);
    // Bare feet, another characteristic silhouette detail.
    canvas.drawOval(const Rect.fromLTWH(48, 211, 28, 13), skin);
    canvas.drawOval(const Rect.fromLTWH(85, 211, 28, 13), skin);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PrincessPainter oldDelegate) =>
      oldDelegate.breath != breath;
}

class MickeyPainter extends CustomPainter {
  const MickeyPainter({required this.wave});
  final double wave;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 237);
    final black = Paint()..color = const Color(0xFF1F2028);
    final face = Paint()..color = const Color(0xFFFFD7B4);
    final red = Paint()..color = const Color(0xFFE53935);
    final white = Paint()..color = Colors.white;
    final yellow = Paint()..color = const Color(0xFFFFCF42);

    canvas.drawCircle(const Offset(43, 34), 29, black);
    canvas.drawCircle(const Offset(117, 34), 29, black);
    canvas.drawCircle(const Offset(80, 73), 49, black);
    final facePatch = Path()
      ..moveTo(80, 42)
      ..cubicTo(63, 28, 47, 45, 52, 68)
      ..cubicTo(43, 83, 54, 106, 80, 110)
      ..cubicTo(106, 106, 117, 83, 108, 68)
      ..cubicTo(113, 45, 97, 28, 80, 42)
      ..close();
    canvas.drawPath(facePatch, face);
    canvas.drawOval(const Rect.fromLTWH(55, 73, 50, 35), face);
    canvas.drawOval(const Rect.fromLTWH(63, 48, 15, 31), white);
    canvas.drawOval(const Rect.fromLTWH(82, 48, 15, 31), white);
    canvas.drawOval(const Rect.fromLTWH(70, 73, 22, 14), black);
    canvas.drawCircle(const Offset(72, 67), 3, black);
    canvas.drawCircle(const Offset(88, 67), 3, black);
    canvas.drawCircle(const Offset(71, 65), 1, white);
    canvas.drawCircle(const Offset(87, 65), 1, white);
    canvas.drawArc(
      const Rect.fromLTWH(59, 82, 42, 27),
      0,
      math.pi,
      false,
      Paint()
        ..color = black.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4,
    );
    canvas.drawOval(
      const Rect.fromLTWH(71, 96, 19, 8),
      Paint()..color = const Color(0xFFE76F73),
    );

    canvas.drawOval(const Rect.fromLTWH(55, 106, 50, 67), black);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 142, 64, 44),
        const Radius.circular(16),
      ),
      red,
    );
    canvas.drawCircle(const Offset(70, 158), 5, white);
    canvas.drawCircle(const Offset(91, 158), 5, white);

    canvas.drawLine(
      const Offset(59, 120),
      const Offset(31, 154),
      Paint()
        ..color = black.color
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(28, 158), 12, white);
    for (final y in const [153.0, 158.0, 163.0]) {
      canvas.drawLine(
        Offset(20, y),
        Offset(34, y - 2),
        Paint()
          ..color = const Color(0xFFB7B7B7)
          ..strokeWidth = 1.2,
      );
    }
    canvas.save();
    canvas.translate(102, 120);
    canvas.rotate(-.75 + wave * .28);
    canvas.drawLine(
      Offset.zero,
      const Offset(0, -52),
      Paint()
        ..color = black.color
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(0, -61), 13, white);
    for (final x in const [-5.0, 0.0, 5.0]) {
      canvas.drawLine(
        Offset(x, -68),
        Offset(x + 2, -56),
        Paint()
          ..color = const Color(0xFFB7B7B7)
          ..strokeWidth = 1.2,
      );
    }
    canvas.restore();

    final tail = Path()
      ..moveTo(105, 157)
      ..cubicTo(141, 157, 144, 126, 129, 121);
    canvas.drawPath(
      tail,
      Paint()
        ..color = black.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      const Offset(67, 181),
      const Offset(61, 215),
      Paint()
        ..color = black.color
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(94, 181),
      const Offset(101, 215),
      Paint()
        ..color = black.color
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      const Rect.fromLTWH(29, 208, 49, 22),
      Paint()..color = const Color(0xFF8A6717),
    );
    canvas.drawOval(
      const Rect.fromLTWH(84, 208, 49, 22),
      Paint()..color = const Color(0xFF8A6717),
    );
    canvas.drawOval(const Rect.fromLTWH(31, 205, 47, 20), yellow);
    canvas.drawOval(const Rect.fromLTWH(84, 205, 47, 20), yellow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MickeyPainter oldDelegate) =>
      oldDelegate.wave != wave;
}
