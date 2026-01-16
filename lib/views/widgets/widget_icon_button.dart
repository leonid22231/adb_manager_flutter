import 'package:adb_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Function onTap;
  final String? description;
  final bool isDark;
  const WidgetIconButton({
    required this.icon,
    required this.onTap,
    this.description,
    this.size = 24,
    this.isDark = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _WidgetIconButtonState();
}

class _WidgetIconButtonState extends State<WidgetIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.description ?? '',
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      preferBelow: true,
      child: MouseRegion(
        // ← Для hover на desktop
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                elevation: 8,
                shadowColor: Colors.black.setOpacity(0.15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  splashColor: widget.isDark
                      ? Colors.black45.setOpacity(0.3)
                      : Colors.grey.shade400.setOpacity(0.3),
                  highlightColor: Colors.transparent,
                  onTapDown: (_) {
                    _controller.forward();
                  },
                  onTapUp: (_) {
                    _controller.reverse();
                  },
                  onTapCancel: () {
                    _controller.reverse();
                  },
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onTap.call();
                  },
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: widget.isDark
                          ? Colors.black26
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.isDark ? Colors.white : Colors.black,
                        size: widget.size - widget.size / 6,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
