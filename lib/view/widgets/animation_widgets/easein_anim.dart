import 'package:flutter/cupertino.dart';

class EaseInAnimationWidget extends StatefulWidget {
  const EaseInAnimationWidget({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;

  @override
  State<EaseInAnimationWidget> createState() => _EaseInAnimationWidgetState();
}

class _EaseInAnimationWidgetState extends State<EaseInAnimationWidget> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void initState() {
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}
