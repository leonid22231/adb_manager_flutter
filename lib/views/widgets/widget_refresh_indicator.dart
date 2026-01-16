import 'package:adb_manager/utils/extensions.dart';
import 'package:flutter/material.dart';

class WidgetRefreshIndicator extends StatefulWidget {
  final VoidCallback? onRefresh;
  final String? label;

  const WidgetRefreshIndicator({
    super.key,
    this.onRefresh,
    this.label = 'Обновление...',
  });

  @override
  State<StatefulWidget> createState() => _WidgetRefreshIndicatorState();
}

class _WidgetRefreshIndicatorState extends State<WidgetRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController
  _spinnerController; // Отдельный для бесконечного вращения
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Контроллер появления/исчезновения (1000ms)
    _appearController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Бесконечное вращение спиннера
    _spinnerController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Запускаем сразу и бесконечно

    // Анимации появления
    _slideAnimation = Tween<Offset>(begin: Offset(-0.5, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _appearController,
            curve: Interval(0.0, 0.4, curve: Curves.elasticOut),
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinnerController, curve: Curves.linear),
    );

    // Автозапуск анимации появления
    _appearController.forward();
  }

  // Публичный метод для запуска исчезновения
  Future<void> hide() async {
    await _appearController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedBuilder(
        animation: Listenable.merge([_appearController, _spinnerController]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.setOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: _rotateAnimation.value * 2 * 3.14159,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.label ?? 'Обновление...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _appearController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }
}
