import 'package:flutter/material.dart';

enum GameItemArtType { bone, strawberry, greenSock, redBow, pinkBow }

class GameItemArt extends StatelessWidget {
  const GameItemArt({super.key, required this.type, this.size = 48});

  final GameItemArtType type;
  final double size;

  static GameItemArtType? typeForName(String name) => switch (name) {
    '狗骨頭' => GameItemArtType.bone,
    '熊抱哥的草莓' => GameItemArtType.strawberry,
    '高飛狗的綠襪子' => GameItemArtType.greenSock,
    '米妮的紅色蝴蝶結' => GameItemArtType.redBow,
    '米妮的粉色蝴蝶結' => GameItemArtType.pinkBow,
    _ => null,
  };

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _GameItemPainter(type)),
  );
}

class _GameItemPainter extends CustomPainter {
  const _GameItemPainter(this.type);

  final GameItemArtType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case GameItemArtType.bone:
        _paintBone(canvas, size);
      case GameItemArtType.strawberry:
        _paintStrawberry(canvas, size);
      case GameItemArtType.greenSock:
        _paintGreenSock(canvas, size);
      case GameItemArtType.redBow:
        _paintBow(canvas, size, const Color(0xFFE62F45));
      case GameItemArtType.pinkBow:
        _paintBow(canvas, size, const Color(0xFFFF73B5));
    }
  }

  void _paintBone(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-.42);
    final unit = size.shortestSide;
    final shadow = Paint()
      ..color = const Color(0x44000000)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = unit * .26;
    final bone = Paint()
      ..color = const Color(0xFFFFF3D4)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = unit * .25;
    final outline = Paint()
      ..color = const Color(0xFFB98243)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = unit * .32;
    final start = Offset(-unit * .25, 0);
    final end = Offset(unit * .25, 0);
    canvas.drawLine(start.translate(1.5, 2), end.translate(1.5, 2), shadow);
    canvas.drawLine(start, end, outline);
    canvas.drawLine(start, end, bone);
    for (final x in [-.34, .34]) {
      canvas.drawCircle(Offset(unit * x, -unit * .10), unit * .13, outline);
      canvas.drawCircle(Offset(unit * x, unit * .10), unit * .13, outline);
      canvas.drawCircle(Offset(unit * x, -unit * .10), unit * .095, bone);
      canvas.drawCircle(Offset(unit * x, unit * .10), unit * .095, bone);
    }
    canvas.restore();
  }

  void _paintStrawberry(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final berry = Path()
      ..moveTo(w * .20, h * .33)
      ..quadraticBezierTo(w * .18, h * .72, w * .50, h * .92)
      ..quadraticBezierTo(w * .82, h * .72, w * .80, h * .33)
      ..quadraticBezierTo(w * .66, h * .17, w * .50, h * .27)
      ..quadraticBezierTo(w * .34, h * .17, w * .20, h * .33)
      ..close();
    canvas.drawShadow(berry, Colors.black, 3, false);
    canvas.drawPath(berry, Paint()..color = const Color(0xFFE93242));
    canvas.drawPath(
      berry,
      Paint()
        ..color = const Color(0xFF9F1627)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .035,
    );
    final leaf = Paint()..color = const Color(0xFF3C9B46);
    final leaves = Path()
      ..moveTo(w * .50, h * .29)
      ..lineTo(w * .29, h * .18)
      ..lineTo(w * .39, h * .35)
      ..lineTo(w * .19, h * .33)
      ..lineTo(w * .42, h * .44)
      ..lineTo(w * .50, h * .29)
      ..lineTo(w * .58, h * .44)
      ..lineTo(w * .81, h * .33)
      ..lineTo(w * .61, h * .35)
      ..lineTo(w * .71, h * .18)
      ..close();
    canvas.drawPath(leaves, leaf);
    final seed = Paint()..color = const Color(0xFFFFE27A);
    for (final point in const [
      Offset(.37, .48),
      Offset(.58, .47),
      Offset(.48, .63),
      Offset(.34, .69),
      Offset(.63, .68),
      Offset(.49, .80),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * point.dx, h * point.dy),
          width: w * .055,
          height: h * .085,
        ),
        seed,
      );
    }
  }

  void _paintGreenSock(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sock = Path()
      ..moveTo(w * .30, h * .10)
      ..lineTo(w * .69, h * .10)
      ..lineTo(w * .65, h * .58)
      ..quadraticBezierTo(w * .78, h * .66, w * .88, h * .72)
      ..quadraticBezierTo(w * .93, h * .89, w * .70, h * .93)
      ..lineTo(w * .37, h * .91)
      ..quadraticBezierTo(w * .20, h * .88, w * .22, h * .71)
      ..lineTo(w * .30, h * .10)
      ..close();
    canvas.drawShadow(sock, Colors.black, 3, false);
    canvas.drawPath(sock, Paint()..color = const Color(0xFF39A95A));
    canvas.drawPath(
      sock,
      Paint()
        ..color = const Color(0xFF176F39)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .045,
    );
    canvas.drawRect(
      Rect.fromLTRB(w * .27, h * .08, w * .72, h * .25),
      Paint()..color = const Color(0xFFB7E64A),
    );
    canvas.drawLine(
      Offset(w * .28, h * .25),
      Offset(w * .70, h * .25),
      Paint()
        ..color = const Color(0xFF176F39)
        ..strokeWidth = w * .035,
    );
  }

  void _paintBow(Canvas canvas, Size size, Color color) {
    final w = size.width;
    final h = size.height;
    final left = Path()
      ..moveTo(w * .46, h * .42)
      ..cubicTo(w * .25, h * .12, w * .03, h * .20, w * .10, h * .52)
      ..cubicTo(w * .16, h * .78, w * .34, h * .70, w * .47, h * .55)
      ..close();
    final right = Path()
      ..moveTo(w * .54, h * .42)
      ..cubicTo(w * .75, h * .12, w * .97, h * .20, w * .90, h * .52)
      ..cubicTo(w * .84, h * .78, w * .66, h * .70, w * .53, h * .55)
      ..close();
    final outline = Paint()
      ..color = const Color(0xFF8C2745)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .035;
    canvas.drawShadow(left, Colors.black, 3, false);
    canvas.drawShadow(right, Colors.black, 3, false);
    canvas.drawPath(left, Paint()..color = color);
    canvas.drawPath(right, Paint()..color = color);
    canvas.drawPath(left, outline);
    canvas.drawPath(right, outline);
    canvas.drawCircle(
      Offset(w * .50, h * .49),
      w * .14,
      Paint()..color = Color.lerp(color, Colors.white, .16)!,
    );
    canvas.drawCircle(Offset(w * .50, h * .49), w * .14, outline);
    final shine = Paint()
      ..color = const Color(0x99FFFFFF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * .045;
    canvas.drawLine(Offset(w * .21, h * .35), Offset(w * .30, h * .31), shine);
    canvas.drawLine(Offset(w * .70, h * .31), Offset(w * .79, h * .35), shine);
  }

  @override
  bool shouldRepaint(covariant _GameItemPainter oldDelegate) =>
      oldDelegate.type != type;
}
