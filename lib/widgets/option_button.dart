import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OptionState { idle, selectedCorrect, selectedWrong, revealCorrect }

class OptionButton extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.bgCard;
    Color border = AppColors.cardBorder;
    Color fg = AppColors.fg;

    switch (state) {
      case OptionState.idle:
        break;
      case OptionState.selectedCorrect:
        bg = AppColors.good.withOpacity(0.22);
        border = AppColors.good;
        fg = AppColors.good;
        break;
      case OptionState.selectedWrong:
        bg = AppColors.bad.withOpacity(0.22);
        border = AppColors.bad;
        fg = AppColors.bad;
        break;
      case OptionState.revealCorrect:
        bg = AppColors.good.withOpacity(0.12);
        border = AppColors.good.withOpacity(0.7);
        fg = AppColors.good;
        break;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 15.5,
            ),
          ),
        ),
      ),
    );
  }
}
