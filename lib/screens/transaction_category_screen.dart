import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';
import 'package:moneyvibes/core/widgets/animated_card.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/providers/app_provider.dart';
import 'package:moneyvibes/screens/transaction_form_screen.dart';

class TransactionCategoryScreen extends StatefulWidget {
  final String category;

  const TransactionCategoryScreen({required this.category, super.key});

  @override
  State<TransactionCategoryScreen> createState() => _TransactionCategoryScreenState();
}

class _TransactionCategoryScreenState extends State<TransactionCategoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showTooltip = true;

  @override
  void initState() {
    super.initState();
    _checkTooltipStatus();
  }

  Future<void> _checkTooltipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _showTooltip = prefs.getBool('show_transaction_tooltip_${widget.category}') ?? true;
    if (_showTooltip) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Panduan'),
              content: const Text('Tekan tombol edit untuk mengubah transaksi, atau tombol hapus untuk menghapus transaksi.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await prefs.setBool('show_transaction_tooltip_${widget.category}', false);
                    Navigator.pop(context);
                  },
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.accent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (_startDate == null || _endDate == null) return transactions;
    return transactions.where((t) {
      final date = DateTime.parse(t.date);
      return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _deleteTransaction(int id, AppProvider appProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appProvider.deleteTransaction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _filterTransactions(
          appProvider.transactions.where((t) => t.category == widget.category).toList(),
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: Text(
              '${widget.category} Transaksi',
              style: AppStyles.headline2,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range, color: AppColors.textPrimary),
                onPressed: () => _pickDateRange(context),
                tooltip: 'Filter Tanggal',
              ),
            ],
          ),
          body: Column(
            children: [
              if (_startDate != null && _endDate != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Filter: ${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    style: AppStyles.bodyText2,
                  ),
                ),
              Expanded(
                child: transactions.isEmpty
                    ? Center(child: Text('Tidak ada transaksi.', style: AppStyles.bodyText2))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return AnimatedCard(
                      delay: Duration(milliseconds: 100 * index),
                      gradientColors: transaction.type == 'Pemasukan'
                          ? const [AppColors.cardGradientStart, AppColors.cardGradientEnd]
                          : const [Color(0xFFF44336), Color(0xFFE57373)],
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          FormatUtils.formatCurrency(transaction.amount),
                          style: AppStyles.bodyText1,
                        ),
                        subtitle: Text(
                          FormatUtils.formatDate(transaction.date),
                          style: AppStyles.bodyText2,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TransactionFormScreen(transaction: transaction)),
                                ).then((result) {
                                  if (result == true) appProvider.loadData();
                                });
                              },
                              tooltip: 'Edit Transaksi',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _deleteTransaction(transaction.id!, appProvider),
                              tooltip: 'Hapus Transaksi',
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransactionFormScreen(transaction: transaction)),
                          ).then((result) {
                            if (result == true) appProvider.loadData();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}