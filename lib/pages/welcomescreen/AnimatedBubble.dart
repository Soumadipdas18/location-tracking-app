import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedBubble extends AnimatedWidget {
  var transform = Matrix4.identity();
  late double startSize;
  late double endSize;
  final Animation<double> animation;

  AnimatedBubble({
    Key? key,
    required this.startSize,
    required this.endSize,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final _sizeTween = Tween<double>(begin: startSize, end: endSize);

    transform.translate(0.0, 0.5, 0.0);

    return Opacity(
      opacity: 0.4,
      child: Transform(
        transform: transform,
        child: Container(
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          height: _sizeTween.evaluate(animation),
          width: _sizeTween.evaluate(animation),
        ),
      ),
    );
  }
}
