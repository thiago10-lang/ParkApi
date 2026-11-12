import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ParkLogo extends StatelessWidget {
  final double size;

  const ParkLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo.png', width: size, height: size, filterQuality: FilterQuality.medium);
  }
}

class ParkNome extends StatelessWidget {
  final double fontSize;

  const ParkNome({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: const [
          TextSpan(text: 'Park', style: TextStyle(color: AppColors.textStrong)),
          TextSpan(text: 'API', style: TextStyle(color: AppColors.primary)),
        ],
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}
