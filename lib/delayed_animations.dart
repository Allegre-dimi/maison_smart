import 'package:flutter/material.dart';
import 'dart:async';   // permet de gérer le delais de lancement de notre animation

class DelayedAnimations extends StatefulWidget {
  final Widget child;
  final int delay;
  const DelayedAnimations({required this.delay, required this.child}) ;

  @override
  State<DelayedAnimations> createState() => _DelayedAnimationsState();
}

class _DelayedAnimationsState extends State<DelayedAnimations> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // pour controller l'animation
  late Animation <Offset> _animOffset;  // pour préciser le comportement de notre animation
  @override

  // initialisation de notre application
  void initState(){
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800)
    );
    final curve = CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate);

    _animOffset = Tween<Offset>(
      begin: Offset(0.0, -0.35),
      end: Offset.zero,
      ).animate(curve);

    // controller la durée d'apparition de notre widget
    Timer(Duration(milliseconds: widget.delay), () {
      _controller.forward();
    });
  }

  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: _animOffset,
          child:widget.child,
    ),
    );
  }
}
