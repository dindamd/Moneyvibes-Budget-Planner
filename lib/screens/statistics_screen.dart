import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/providers/app_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Map<String, double> _calculateCategoryBreakdown(List<Transaction> transactions) {
    final breakdown = <String, double>{};
    for (var transaction in transactions) {
      breakdown[transaction.category] = (breakdown[transaction.category] ?? 0) + transaction.amount;
    }
    return breakdown;
  }

  List<FlSpot> _calculateBalanceOverTime(List<Transaction> transactions) {
    final sortedTransactions = transactions..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];
    double balance = 0;
    for (var i = 0; i < sortedTransactions.length; i++) {
      final transaction = sortedTransactions[i];
      balance += transaction.type == 'Pemasukan' ? transaction.amount : -transaction.amount;
      spots.add(FlSpot(i.toDouble(), balance));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final categoryBreakdown = _calculateCategoryBreakdown(appProvider.transactions);
        final balanceSpots = _calculateBalanceOverTime(appProvider.transactions);

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: Text('Statistik', style: AppStyles.headline2),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengeluaran per Kategori',
                    style: AppStyles.headline2,
                  ),
                  const SizedBox(height: 16),
                  categoryBreakdown.isEmpty
                      ? const Center(child: Text('Tidak ada data untuk ditampilkan.', style: TextStyle(color: AppColors.textSecondary)))
                      : SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: categoryBreakdown.entries.map((entry) {
                          final index = categoryBreakdown.keys.toList().indexOf(entry.key);
                          return PieChartSectionData(
                            color: Colors.primaries[index % Colors.primaries.length],
                            value: entry.value,
                            title: '${entry.key}\n${(entry.value / categoryBreakdown.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
                            radius: 100,
                            titleStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Saldo Seiring Waktu',
                    style: AppStyles.headline2,
                  ),
                  const SizedBox(height: 16),
                  balanceSpots.isEmpty
                      ? const Center(child: Text('Tidak ada data untuk ditampilkan.', style: TextStyle(color: AppColors.textSecondary)))
                      : SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: balanceSpots.length.toDouble() - 1,
                        minY: balanceSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 100000,
                        maxY: balanceSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 100000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: balanceSpots,
                            isCurved: true,
                            color: AppColors.accent,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.accent.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}