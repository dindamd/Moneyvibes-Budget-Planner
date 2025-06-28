import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';

class FinanceSummaryCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const FinanceSummaryCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  State<FinanceSummaryCard> createState() => _FinanceSummaryCardState();
}

class _FinanceSummaryCardState extends State<FinanceSummaryCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          });
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ringkasan Keuangan',
                        style: AppStyles.cardTitle,
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saldo Total',
                        style: AppStyles.cardSubtitle,
                      ),
                      Text(
                        FormatUtils.formatCurrency(widget.totalBalance),
                        style: AppStyles.bodyText1.copyWith(
                          color: widget.totalBalance >= 0 ? AppColors.textPrimary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1,
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pemasukan',
                              style: AppStyles.cardSubtitle,
                            ),
                            Text(
                              FormatUtils.formatCurrency(widget.totalIncome),
                              style: AppStyles.bodyText1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pengeluaran',
                              style: AppStyles.cardSubtitle,
                            ),
                            Text(
                              FormatUtils.formatCurrency(widget.totalExpenses),
                              style: AppStyles.bodyText1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}