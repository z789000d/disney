import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GamePreloadGate extends StatefulWidget {
  const GamePreloadGate({super.key, required this.child});

  final Widget child;

  @override
  State<GamePreloadGate> createState() => _GamePreloadGateState();
}

class _GamePreloadGateState extends State<GamePreloadGate> {
  static const _images = <String>[
    'assets/images/agrabah_night.png',
    'assets/images/aladdin_carpet.png',
    'assets/images/andy_room.png',
    'assets/images/anna.png',
    'assets/images/bause.png',
    'assets/images/castle_courtyard.png',
    'assets/images/elsa.png',
    'assets/images/frozen_maze.png',
    'assets/images/genie.png',
    'assets/images/jafar.png',
    'assets/images/jafar_defeated.png',
    'assets/images/lotso.png',
    'assets/images/magic_lamp.png',
    'assets/images/mickey.png',
    'assets/images/mickey_cutout.png',
    'assets/images/minnine_pink.png',
    'assets/images/minnine_red.png',
    'assets/images/olaf_has_nose.png',
    'assets/images/olaf_no_nose.png',
    'assets/images/pluto.png',
    'assets/images/pluto_cutout.png',
    'assets/images/pluto_has_bone.png',
    'assets/images/pluto_house.png',
    'assets/images/princess.png',
    'assets/images/princess_cutout.png',
    'assets/images/slinky_dog.png',
    'assets/images/three_eye.png',
    'assets/images/woody.png',
    'assets/images/zurg.png',
  ];

  static const _fontWarmup =
      '生日專屬迪士尼 米奇 米妮 布魯托 公主 任務 道具欄 '
      '狗骨頭 綠襪子 草莓 蝴蝶結 安迪的房間 玩具夥伴 '
      '阿拉丁 魔毯 賈方 神燈 精靈 勇氣 幸福 冒險 友誼 '
      '你救了我們，我們永遠感謝你！';

  bool _ready = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _preload();
  }

  Future<void> _preload() async {
    await Future.wait(
      _images.map(
        (path) => precacheImage(AssetImage(path), context).catchError((_) {}),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (kIsWeb) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    return Material(
      key: const Key('game_preload_loading'),
      color: const Color(0xFF281B58),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF7654C4), Color(0xFF281B58)],
                radius: 1.1,
              ),
            ),
          ),
          const Center(
            child: SizedBox.square(
              dimension: 54,
              child: CircularProgressIndicator(
                color: Color(0xFFFFDF70),
                strokeWidth: 5,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            child: ClipRect(
              child: OverflowBox(
                minWidth: 900,
                maxWidth: 900,
                minHeight: 30,
                maxHeight: 30,
                alignment: Alignment.topLeft,
                child: Opacity(
                  opacity: .01,
                  child: Text(
                    _fontWarmup,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
