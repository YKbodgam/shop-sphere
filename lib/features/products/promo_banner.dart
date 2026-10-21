import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.paleBlue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Up to 50% OFF',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Top picks for you',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Shop Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.headphones_rounded, size: 58, color: AppTheme.ink),
      ],
    ),
  );
}
