import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shopsphere_components.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 18.h),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppTheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ShopSphere',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontSize: 27),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Better Products. Happier You.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Image.asset(
                'assets/shopsphere_onboarding.png',
                fit: BoxFit.contain,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  width: i == 0 ? 22 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == 0 ? AppTheme.primary : const Color(0xFFDDE4F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              label: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account?  Log In'),
            ),
          ],
        ),
      ),
    ),
  );
}
