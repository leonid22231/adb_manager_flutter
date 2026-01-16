import 'package:adb_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetButton extends StatefulWidget {
  final String title;
  final Function onTap;
  final Color color;
  const WidgetButton({
    required this.title,
    required this.onTap,
    this.color = Colors.redAccent,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _WidgetButtonState();
}

class _WidgetButtonState extends State<WidgetButton>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: widget.color,
            borderRadius: BorderRadius.circular(10),
            elevation: 8,
            shadowColor: Colors.black.setOpacity(0.15),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  widget.title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black.setOpacity(0.2),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
