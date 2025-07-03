import 'package:flutter/cupertino.dart';

class SlideInLeftAnimationWidget extends StatefulWidget {
  final bool? shouldStartAnimation;

  const SlideInLeftAnimationWidget({
    Key? key,
    this.child,
    this.shouldStartAnimation = true ,
  }) : super(key: key);
  final Widget? child;

  @override
  State<SlideInLeftAnimationWidget> createState() =>
      _SlideInLeftAnimationWidgetState();
}

class _SlideInLeftAnimationWidgetState extends State<SlideInLeftAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<Offset> offset;

  ValueNotifier<bool> _myString = ValueNotifier<bool>(false);


  @override
  void initState() {
    if (widget.shouldStartAnimation!) {
      animation = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      offset = Tween<Offset>(
          begin: const Offset(
            2.0,
            0.0,
          ),
          end: const Offset(
            0.0,
            0.0,
          )).animate(animation);
      startAnimation();
    }

    _myString.addListener(() => print(_myString.value));


    super.initState();
  }

  startAnimation() {

    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: offset, child: widget.child);
  }
}
