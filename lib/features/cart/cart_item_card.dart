import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'cart.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });
  final CartItem item;
  final VoidCallback onDecrease, onIncrease, onRemove;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8EDF5)),
    ),
    child: Row(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CachedNetworkImage(
            imageUrl: item.product.thumbnail,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 13),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remove ${item.product.title}',
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${item.product.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '-20%',
                      style: TextStyle(
                        color: AppTheme.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _Control(icon: Icons.remove, onTap: onDecrease),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _Control(icon: Icons.add, onTap: onIncrease),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Control extends StatelessWidget {
  const _Control({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Icon(icon, size: 16, color: AppTheme.ink),
  );
}
