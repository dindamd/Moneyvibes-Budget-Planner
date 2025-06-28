import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/screens/settings_screen.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onTransactionPressed;
  final VoidCallback onBudgetPressed;

  const CustomFAB({
    super.key,
    required this.onTransactionPressed,
    required this.onBudgetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElasticIn(
          child: FloatingActionButton(
            heroTag: 'add_transaction',
            onPressed: onTransactionPressed,
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.add, size: 30, color: AppColors.textPrimary),
            tooltip: 'Tambah Transaksi',
          ),
        ),
        const SizedBox(height: 10),
        ElasticIn(
          delay: const Duration(milliseconds: 100),
          child: FloatingActionButton(
            heroTag: 'set_budget',
            onPressed: onBudgetPressed,
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.account_balance_wallet, size: 30, color: AppColors.textPrimary),
            tooltip: 'Atur Budget',
          ),
        ),
        const SizedBox(height: 10),
        ElasticIn(
          delay: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            heroTag: 'settings',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.settings, size: 30, color: AppColors.textPrimary),
            tooltip: 'Pengaturan',
          ),
        ),
      ],
    );
  }
}