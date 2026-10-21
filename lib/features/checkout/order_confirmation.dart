import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.total,
  });

  final Object? orderId;
  final double total;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 88,
              ),
              const SizedBox(height: 24),
              Text(
                'Order placed!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your simulated order was accepted successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text('Total  \$${total.toStringAsFixed(2)}'),
              if (orderId != null) Text('Cart reference  #$orderId'),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
