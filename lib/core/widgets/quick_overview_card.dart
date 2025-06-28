import 'package:flutter/material.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/screens/transaction_category_screen.dart';

class QuickOverviewCard extends StatelessWidget {
  final List<Transaction> recentTransactions;

  const QuickOverviewCard({super.key, required this.recentTransactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaksi Terbaru',
                style: AppStyles.cardTitle,
              ),
              const SizedBox(height: 10),
              recentTransactions.isEmpty
                  ? SizedBox( // Removed 'const' to allow dynamic style
                width: double.infinity,
                child: Text(
                  'Belum ada transaksi.',
                  style: AppStyles.cardSubtitle,
                  textAlign: TextAlign.center,
                ),
              )
                  : Column(
                children: recentTransactions.map((transaction) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              TransactionCategoryScreen(category: transaction.category),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${transaction.category} (${transaction.type})',
                                style: AppStyles.bodyText1,
                              ),
                              Text(
                                FormatUtils.formatDate(transaction.date),
                                style: AppStyles.cardSubtitle,
                              ),
                            ],
                          ),
                          Text(
                            FormatUtils.formatCurrency(transaction.amount),
                            style: AppStyles.bodyText1.copyWith(
                              color: transaction.type == 'Pemasukan' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}