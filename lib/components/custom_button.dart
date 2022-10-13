import 'package:flutter/material.dart';
import 'package:live_app/styles/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function() onTap;
  final bool spread;
  final _colorUtils = ColorUtils();

  CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.spread = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      onTap: onTap,
      child: Material(
        color: _colorUtils.buttonColor,
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _colorUtils.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
    if (spread) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
