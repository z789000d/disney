import 'package:flutter/material.dart';

enum MagicButtonStyle { royal, parchment }

class MagicButton extends StatefulWidget {
  const MagicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = MagicButtonStyle.royal,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MagicButtonStyle style;
  final EdgeInsets padding;

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final parchment = widget.style == MagicButtonStyle.parchment;
    final borderColor = _enabled
        ? const Color(0xFFFFD873)
        : const Color(0xFFAAA3B4);
    final colors = !_enabled
        ? const [Color(0xFF8C8794), Color(0xFF686371)]
        : parchment
        ? const [Color(0xFFFFF2BF), Color(0xFFE8B85D)]
        : _hovered
        ? const [Color(0xFFA963E1), Color(0xFF57318F)]
        : const [Color(0xFF8648C2), Color(0xFF40216F)];
    final foreground = parchment ? const Color(0xFF5B3216) : Colors.white;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: _enabled
              ? (_) {
                  setState(() => _pressed = false);
                  widget.onPressed!();
                }
              : null,
          child: AnimatedScale(
            scale: _pressed ? .96 : 1,
            duration: const Duration(milliseconds: 110),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: _pressed
                        ? const Color(0x557A4EC0)
                        : const Color(0x88401C69),
                    blurRadius: _hovered ? 18 : 12,
                    offset: Offset(0, _pressed ? 3 : 7),
                  ),
                  const BoxShadow(
                    color: Color(0x66FFFFFF),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: const Color(0x55FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: foreground, size: 21),
                    const SizedBox(width: 9),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                        shadows: parchment
                            ? null
                            : const [
                                Shadow(color: Colors.black38, blurRadius: 3),
                              ],
                      ),
                    ),
                  ),
                  if (_enabled) ...[
                    const SizedBox(width: 8),
                    Text(
                      '✦',
                      style: TextStyle(color: foreground, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MagicIconButton extends StatefulWidget {
  const MagicIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.style = MagicButtonStyle.royal,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final MagicButtonStyle style;
  final String? badge;

  @override
  State<MagicIconButton> createState() => _MagicIconButtonState();
}

class _MagicIconButtonState extends State<MagicIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final parchment = widget.style == MagicButtonStyle.parchment;
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? .9 : 1,
          duration: const Duration(milliseconds: 110),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: enabled ? 1 : .45,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: parchment
                          ? const [Color(0xFFFFF1B4), Color(0xFFD99A3C)]
                          : const [Color(0xFF8B4FC6), Color(0xFF392066)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD873),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x77401C69),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: parchment ? const Color(0xFF5B3216) : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              if (widget.badge != null)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC72F50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE39A)),
                    ),
                    child: Text(
                      widget.badge!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MagicTextField extends StatelessWidget {
  const MagicTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFFCED), Color(0xFFF4E4FF)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD8A94E), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33452072),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
        BoxShadow(
          color: Color(0x99FFFFFF),
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: Color(0xFF3A246D),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.auto_awesome, color: Color(0xFF8A4CC0)),
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Center(
            widthFactor: 1,
            child: Text('✦', style: TextStyle(color: Color(0xFFD09A32))),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF76529A),
          fontWeight: FontWeight.w700,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .90),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x420E0A42),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

class MouseGuideAvatar extends StatelessWidget {
  const MouseGuideAvatar({super.key, this.size = 76});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 2, top: 0, child: _ear(size * .42)),
        Positioned(right: 2, top: 0, child: _ear(size * .42)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size * .78,
            height: size * .78,
            decoration: BoxDecoration(
              color: const Color(0xFF22202C),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                '米奇',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * .17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ear(double diameter) => Container(
    width: diameter,
    height: diameter,
    decoration: const BoxDecoration(
      color: Color(0xFF22202C),
      shape: BoxShape.circle,
    ),
  );
}
