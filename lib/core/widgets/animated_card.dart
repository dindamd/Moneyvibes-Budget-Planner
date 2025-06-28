import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration delay;
  final List<Color> gradientColors;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.delay = const Duration(milliseconds: 100),
    this.gradientColors = const [Color(0xFF2A5298), Color(0xFF1E3C72)],
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: delay,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}