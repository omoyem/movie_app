import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FadeInAnimationWidget extends StatefulWidget {
  const FadeInAnimationWidget({
    Key? key,
    this.delay,
    required this.child,
  }) : super(key: key);
  final Widget child;
  final Duration? delay;

  @override
  State<FadeInAnimationWidget> createState() => _FadeInAnimationWidgetState();
}

class _FadeInAnimationWidgetState extends State<FadeInAnimationWidget> with TickerProviderStateMixin {

  AnimationController? animation;
  Animation<double>? _fadeInFadeOut;

  @override
  void initState() {
    animation = AnimationController(vsync: this, duration: Duration(milliseconds: 500),);
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(animation!);

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      if (widget.delay != null) {
        await Future.delayed(widget.delay!, () => animation!.forward());
      }else{
        animation!.forward();
      }
    });


    super.initState();
  }

  @override
  void dispose() {
    animation!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition( opacity: _fadeInFadeOut!,
    child: widget.child);
  }
}
