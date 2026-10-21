import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}

class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppTheme.danger.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '-${value.round()}%',
        style: const TextStyle(
          color: AppTheme.danger,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      border: Border.all(color: const Color(0xFFE8EDF5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F2742),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const Spacer(),
      if (action != null)
        Text(
          action!,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
    ],
  );
}
