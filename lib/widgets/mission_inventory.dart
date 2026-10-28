import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import 'game_item_art.dart';
import 'game_widgets.dart';

class MissionScrollOverlay extends StatefulWidget {
  const MissionScrollOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  State<MissionScrollOverlay> createState() => _MissionScrollOverlayState();
}

class _MissionScrollOverlayState extends State<MissionScrollOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _curve = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xB3150C2B),
    child: SafeArea(
      child: Center(
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, child) => LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.clamp(0.0, 760.0);
              final height = constraints.maxHeight * .9;
              return Opacity(
                opacity: (.25 + _animation.value * .75).clamp(0, 1),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: _parchment(_curve.value),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _parchment(double openness) => LayoutBuilder(
    builder: (context, constraints) {
      const rodHeight = 25.0;
      const openRodInset = 9.0;
      final closedRodInset = constraints.maxHeight / 2 - rodHeight / 2;
      final rodInset =
          closedRodInset + (openRodInset - closedRodInset) * openness;
      final paperWidth = (constraints.maxWidth - 36).clamp(
        0.0,
        double.infinity,
      );
      final paperHeight = (constraints.maxHeight - 44).clamp(
        0.0,
        double.infinity,
      );
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: math.max(.01, openness),
                child: SizedBox(
                  width: paperWidth,
                  height: paperHeight,
                  child: _parchmentBody(),
                ),
              ),
            ),
          ),
          Positioned(left: 5, right: 5, top: rodInset, child: _scrollRod()),
          Positioned(left: 5, right: 5, bottom: rodInset, child: _scrollRod()),
        ],
      );
    },
  );

  Widget _parchmentBody() => Container(
    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF1B8), Color(0xFFFFE29A), Color(0xFFF6C96B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFA76624), width: 3),
      boxShadow: const [
        BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 16)),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              size: 34,
              color: Color(0xFF633713),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '米奇的生日任務卷軸',
                    style: TextStyle(
                      color: Color(0xFF633713),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '完成所有任務，取得最終生日大獎！',
                    style: TextStyle(color: Color(0xFF805525)),
                  ),
                ],
              ),
            ),
            MagicIconButton(
              tooltip: '收起任務卷軸',
              onPressed: () => _closeScroll(),
              icon: Icons.close_rounded,
              style: MagicButtonStyle.parchment,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => LinearProgressIndicator(
            value:
                widget.controller.completedMissions.value /
                GameController.missions.length,
            minHeight: 9,
            color: const Color(0xFF7A45A8),
            backgroundColor: const Color(0x55A76624),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            final completedCount = widget.controller.completedMissions.value;
            final visibleCount = (completedCount + 1).clamp(
              0,
              GameController.missions.length,
            );
            final hasLocked = visibleCount < GameController.missions.length;
            return ListView.separated(
              itemCount: visibleCount + (hasLocked ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const Divider(color: Color(0x55A76624), height: 8),
              itemBuilder: (context, index) {
                if (index == visibleCount) {
                  final remaining =
                      GameController.missions.length - visibleCount;
                  return _LockedMissionsRow(count: remaining);
                }
                final completed = index < completedCount;
                final active =
                    index == completedCount &&
                    !widget.controller.allMissionsCompleted;
                return InkWell(
                  key: ValueKey('mission_$index'),
                  onTap: active
                      ? () => _closeScroll(
                          afterClosed: () =>
                              widget.controller.enterMission(index),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0x66FFFFFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: active
                          ? Border.all(color: const Color(0xFF8D5B2A))
                          : null,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: completed
                              ? const Color(0xFF5A9E68)
                              : const Color(0xFF7A45A8),
                          child: completed
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 19,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.controller.lobbyMissionTitle(index),
                                style: const TextStyle(
                                  color: Color(0xFF5D3519),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                widget.controller.lobbyMissionDescription(
                                  index,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF805525),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          completed ? '完成' : '點擊開始',
                          style: const TextStyle(
                            color: Color(0xFF70401F),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 10),
        MagicButton(
          onPressed: () => _closeScroll(),
          icon: Icons.check_rounded,
          label: widget.controller.questStarted.value ? '收起卷軸' : '接受生日任務',
          style: MagicButtonStyle.parchment,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        ),
      ],
    ),
  );

  Widget _scrollRod() => Container(
    height: 25,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7D451B), Color(0xFFD9953E), Color(0xFF6C3717)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF4E260F), width: 2),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 5)],
    ),
  );

  Future<void> _closeScroll({VoidCallback? afterClosed}) async {
    if (_animation.status == AnimationStatus.dismissed) return;
    await _animation.reverse();
    if (!mounted) return;
    if (afterClosed != null) {
      afterClosed();
    } else {
      widget.controller.closeMissionScroll();
    }
  }
}

class MissionListSheet extends StatelessWidget {
  const MissionListSheet({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 16, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF282631),
                  child: Icon(Icons.face_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '米奇的生日任務清單',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF38256D),
                        ),
                      ),
                      Text(
                        '依序完成 10 項任務，尋找限定道具。',
                        style: TextStyle(color: Color(0xFF716780)),
                      ),
                    ],
                  ),
                ),
                MagicIconButton(
                  onPressed: Get.back,
                  icon: Icons.close_rounded,
                  tooltip: '關閉任務清單',
                  style: MagicButtonStyle.parchment,
                ),
              ],
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: LinearProgressIndicator(
                value:
                    controller.completedMissions.value /
                    GameController.missions.length,
                minHeight: 9,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final completedCount = controller.completedMissions.value;
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                itemCount: GameController.missions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final completed = index < completedCount;
                  final active =
                      index == completedCount &&
                      !controller.allMissionsCompleted;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFEDE3FF) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF8A5CC5)
                            : const Color(0xFFE6DFF0),
                        width: active ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: completed
                            ? const Color(0xFF62B87C)
                            : active
                            ? const Color(0xFF7A55B5)
                            : const Color(0xFFE4DFE9),
                        child: completed
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF817789),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      title: Text(
                        controller.lobbyMissionTitle(index),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: active ? const Color(0xFF4D2A83) : null,
                        ),
                      ),
                      subtitle: Text(controller.lobbyMissionDescription(index)),
                      trailing: completed || active
                          ? Text(
                              completed ? '完成' : '進行中',
                              style: TextStyle(
                                color: completed
                                    ? const Color(0xFF308E52)
                                    : const Color(0xFF7350A5),
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF7350A5),
                            ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

class InventoryBar extends StatelessWidget {
  const InventoryBar({super.key, required this.controller, this.onItemTap});

  final GameController controller;
  final void Function(int index, InventoryItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final slotSize = compact ? 44.0 : 53.0;
    return Container(
      margin: EdgeInsets.fromLTRB(
        compact ? 6 : 12,
        0,
        compact ? 6 : 12,
        compact ? 6 : 12,
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 7 : 12,
        6,
        compact ? 7 : 12,
        compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xE6251D43),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.backpack_rounded, color: Color(0xFFFFE487), size: 16),
              SizedBox(width: 6),
              Text(
                '生日冒險道具欄',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(10, (index) {
                  final item = index < controller.inventory.length
                      ? controller.inventory[index]
                      : null;
                  return Tooltip(
                    message: item == null
                        ? '空的道具格'
                        : '${item.name} ×${item.quantity}',
                    child: InkWell(
                      key: ValueKey('inventory_slot_$index'),
                      onTap: item == null
                          ? null
                          : () {
                              if (onItemTap != null) {
                                onItemTap!(index, item);
                              } else {
                                controller.inspectItem(index);
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: slotSize,
                        height: slotSize,
                        margin: EdgeInsets.symmetric(
                          horizontal: compact ? 2 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: item == null
                              ? const Color(0x663F365D)
                              : const Color(0xFFFDF6D7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item == null
                                ? Colors.white24
                                : const Color(0xFFFFCF55),
                            width: 2,
                          ),
                        ),
                        child: item == null
                            ? Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  Center(
                                    child: switch (GameItemArt.typeForName(
                                      item.name,
                                    )) {
                                      final type? => GameItemArt(
                                        type: type,
                                        size: compact ? 31 : 37,
                                      ),
                                      null => Icon(
                                        Icons.card_giftcard_rounded,
                                        color: const Color(0xFF6A3C91),
                                        size: compact ? 25 : 30,
                                      ),
                                    },
                                  ),
                                  if (item.quantity > 1)
                                    Positioned(
                                      right: 3,
                                      bottom: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5C388C),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedMissionsRow extends StatelessWidget {
  const _LockedMissionsRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0x22A76624),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0x55A76624),
          child: Icon(Icons.lock_rounded, color: Color(0xFF75451E), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '還有 $count 項任務尚未解鎖',
            style: const TextStyle(
              color: Color(0xFF805525),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
