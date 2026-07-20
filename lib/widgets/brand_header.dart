import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Logo + nome do app usado nas telas de autenticação.
class BrandHeader extends StatelessWidget {
  final String subtitle;
  const BrandHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('Rotina', style: Theme.of(context).textTheme.displaySmall),
            Text(
              'App',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
