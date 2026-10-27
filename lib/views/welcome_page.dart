import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../widgets/animated_characters.dart';
import '../widgets/game_widgets.dart';

class WelcomePage extends GetView<GameController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/castle_courtyard.png', fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xAA21145D), Color(0x22000000), Color(0x88302362)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Flex(
                      direction: narrow ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(flex: narrow ? 0 : 5, child: _hero(narrow)),
                        SizedBox(
                          width: narrow ? 0 : 44,
                          height: narrow ? 24 : 0,
                        ),
                        Expanded(
                          flex: narrow ? 0 : 4,
                          child: GlassPanel(child: _form()),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Positioned(
          right: 16,
          bottom: 10,
          child: Text(
            '非官方同人遊戲原型',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _hero(bool narrow) => Column(
    crossAxisAlignment: narrow
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      const Text(
        '生日專屬\n迪士尼',
        style: TextStyle(
          color: Colors.white,
          fontSize: 46,
          height: .95,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Color(0xAA432A84), blurRadius: 18)],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        '和米奇一起完成 20 項生日限定任務！',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 22),
      Container(
        width: narrow ? 235 : 380,
        height: narrow ? 185 : 285,
        decoration: BoxDecoration(
          color: const Color(0x66382274),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 22)],
        ),
        child: Center(
          child: AnimatedPrincessCharacter(width: narrow ? 125 : 170),
        ),
      ),
    ],
  );

  Widget _form() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        '歡迎，新的冒險者！',
        style: TextStyle(
          color: Color(0xFF3A246D),
          fontSize: 27,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        '先告訴我們你的名字，公主冒險者已經準備好出發了。',
        style: TextStyle(color: Color(0xFF665C78), height: 1.5),
      ),
      const SizedBox(height: 22),
      MagicTextField(
        controller: controller.nameController,
        label: '你的名字',
        hint: '例如：小星',
        onSubmitted: (_) => controller.startAdventure(),
      ),
      const SizedBox(height: 16),
      MagicButton(
        onPressed: controller.startAdventure,
        icon: Icons.castle_rounded,
        label: '開始生日冒險',
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
    ],
  );
}
