import 'package:flutter/material.dart';
import '../theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double padding;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 100,
    this.iconSize = 60,
    this.padding = 20,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + (padding * 2),
      height: size + (padding * 2),
      decoration: showShadow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: ClipOval(
        child: Image.asset(
          'assets/images/logoutama.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
