import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';

/// ============================================================================
/// Composants réutilisables Dèmè Mali (Design System issu des maquettes Figma)
/// ============================================================================

/// 1. Logo officiel Dèmè Mali
class DemeLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isHorizontal;
  final double textSize;

  const DemeLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.isHorizontal = false,
    this.textSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.volunteer_activism,
          size: size,
          color: AppColors.vert,
        );
      },
    );

    if (!showText) return imageWidget;

    final textWidget = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        children: const [
          TextSpan(text: 'Dèmè ', style: TextStyle(color: AppColors.vert)),
          TextSpan(text: 'Mali', style: TextStyle(color: AppColors.jaune)),
        ],
      ),
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          imageWidget,
          const SizedBox(width: 10),
          textWidget,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageWidget,
        const SizedBox(height: 12),
        textWidget,
      ],
    );
  }
}

/// 2. Header avec indicateur d'étapes (Stepper Header)
class DemeStepperHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const DemeStepperHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const DemeLogo(
              size: 32,
              textSize: 20,
              isHorizontal: true,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.jaune, width: 1.5),
              ),
              child: Text(
                '$currentStep sur $totalSteps',
                style: const TextStyle(
                  color: AppColors.texte,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Barre de progression par segments
        Row(
          children: List.generate(totalSteps, (index) {
            final isFilled = index < currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                height: 4,
                decoration: BoxDecoration(
                  color: isFilled ? AppColors.vert : AppColors.bordure,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// 3. Bouton Retour circulaire moderne
class DemeBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DemeBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bordure),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.texte,
          size: 20,
        ),
      ),
    );
  }
}

/// 4. Champ de texte standardisé Dèmè
class DemeTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const DemeTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          maxLines: isPassword ? 1 : maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.texte,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.placeholder,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            prefixIcon: prefixIcon,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.placeholder,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.bordure, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.bordure, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.vert, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

/// 5. Sélecteur déroulant stylisé (Dropdown)
class DemeDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const DemeDropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bordure, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.placeholder,
                      ),
                    )
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.texte),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// 6. Bouton pilule principal ou secondaire
class DemeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final bool iconAtEnd;
  final Color? backgroundColor;
  final Color? textColor;

  const DemeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.iconAtEnd = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? (isOutlined ? Colors.white : AppColors.vert);
    final effectiveText = textColor ?? (isOutlined ? AppColors.texte : Colors.white);

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveText,
          elevation: isOutlined ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isOutlined ? const BorderSide(color: AppColors.bordure, width: 1.4) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null && !iconAtEnd) ...[
                    Icon(icon, size: 18, color: effectiveText),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: effectiveText,
                    ),
                  ),
                  if (icon != null && iconAtEnd) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18, color: effectiveText),
                  ],
                ],
              ),
      ),
    );
  }
}

/// 7. Barre d'action inférieure Retour / Suivant
class DemeBottomButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextText;
  final bool isNextLoading;

  const DemeBottomButtons({
    super.key,
    this.onBack,
    this.onNext,
    this.nextText = 'Suivant',
    this.isNextLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: DemeButton(
            text: 'Retour',
            isOutlined: true,
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 6,
          child: DemeButton(
            text: nextText,
            icon: Icons.arrow_forward,
            isLoading: isNextLoading,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}
