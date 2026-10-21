import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.title, required this.action});
  final String title;
  final VoidCallback action;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off_rounded, size: 48),
        const SizedBox(height: 12),
        Text(title),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: action,
          child: const Text('Continue shopping'),
        ),
      ],
    ),
  );
}
