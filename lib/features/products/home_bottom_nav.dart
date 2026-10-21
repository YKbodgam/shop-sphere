import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, required this.index, required this.onChanged, required this.cartCount});
  final int index; final ValueChanged<int> onChanged; final int cartCount;
  @override Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE8EDF5)))),
    padding: const EdgeInsets.only(top: 8, bottom: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _Item(icon: Icons.home_rounded, label: 'Home', selected: index == 0, onTap: () => onChanged(0)),
      _Item(icon: Icons.grid_view_rounded, label: 'Categories', selected: index == 1, onTap: () => onChanged(1)),
      _Item(icon: Icons.shopping_cart_outlined, label: 'Cart', selected: index == 2, badge: cartCount, onTap: () => onChanged(2)),
      _Item(icon: Icons.person_outline_rounded, label: 'Profile', selected: index == 3, onTap: () => onChanged(3)),
    ]),
  );
}
class _Item extends StatelessWidget { const _Item({required this.icon, required this.label, required this.selected, required this.onTap, this.badge = 0}); final IconData icon; final String label; final bool selected; final VoidCallback onTap; final int badge;
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Column(mainAxisSize: MainAxisSize.min, children: [Badge(isLabelVisible: badge > 0, label: Text('$badge'), child: Icon(icon, color: selected ? AppTheme.primary : AppTheme.muted)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? AppTheme.primary : AppTheme.muted))])));
}
