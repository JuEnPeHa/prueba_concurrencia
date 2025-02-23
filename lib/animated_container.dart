import 'package:flutter/material.dart';

class AnimatedContainerM extends StatefulWidget {
  const AnimatedContainerM({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
    this.principalColor = Colors.orange,
    this.borderColor = Colors.green,
    this.borderWidth = 20.0,
  });

  final Widget child;
  final Duration duration;
  final Color principalColor;
  final Color borderColor;
  final double borderWidth;

  @override
  State<AnimatedContainerM> createState() => _AnimatedContainerMState();
}

class _AnimatedContainerMState extends State<AnimatedContainerM>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  late Animation _animationBorder;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animationBorder = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.borderColor.withValues(
                alpha: _animationBorder.value,
              ),
              width: widget.borderWidth,
            ),
            borderRadius: BorderRadius.circular(10),
            color: widget.principalColor.withValues(alpha: _animation.value),
          ),
          child: widget.child,
        );
      },
    );
  }
}
