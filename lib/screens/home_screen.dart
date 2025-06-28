import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/constants/categories.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';
import 'package:moneyvibes/core/widgets/animated_card.dart';
import 'package:moneyvibes/core/widgets/custom_fab.dart';
import 'package:moneyvibes/core/widgets/finance_summary_card.dart';
import 'package:moneyvibes/core/widgets/quick_overview_card.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/models/budget.dart';
import 'package:moneyvibes/core/services/notification_service.dart';
import 'package:moneyvibes/screens/transaction_form_screen.dart';
import 'package:moneyvibes/screens/budget_form_screen.dart';
import 'package:moneyvibes/screens/transaction_category_screen.dart';
import 'package:moneyvibes/screens/statistics_screen.dart';
import 'package:moneyvibes/providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService.instance;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.loadData();
      _checkBudget();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkBudget() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.currentBudget == null) return;

    final now = DateTime.now();
    final startDate = DateTime.parse(appProvider.currentBudget!.startDate);
    final endDate = startDate.add(const Duration(days: 7));

    if (now.isBefore(endDate)) {
      final totalSpent = appProvider.transactions
          .where((t) => t.type == 'Pengeluaran' && DateTime.parse(t.date).isAfter(startDate) && DateTime.parse(t.date).isBefore(endDate))
          .fold(0.0, (sum, t) => sum + t.amount);

      if (totalSpent >= appProvider.currentBudget!.amount * 0.7 && totalSpent < appProvider.currentBudget!.amount) {
        await _notificationService.showNotification(
          'Peringatan Budget 🚨',
          'Pengeluaranmu hampir mencapai 70% dari budget! 🚧',
        );
      } else if (totalSpent >= appProvider.currentBudget!.amount) {
        await _notificationService.showNotification(
          'Budget Habis! 💥',
          'Budget mingguanmu sudah habis! Waktunya hemat! 🛡️',
        );
      }
    }
  }

  double _calculateTotalIncome(List<Transaction> transactions) {
    return transactions.where((t) => t.type == 'Pemasukan').fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpenses(List<Transaction> transactions) {
    return transactions.where((t) => t.type == 'Pengeluaran').fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalBalance(List<Transaction> transactions) {
    return _calculateTotalIncome(transactions) - _calculateTotalExpenses(transactions);
  }

  List<Transaction> _getRecentTransactions(List<Transaction> transactions) {
    final sortedTransactions = transactions..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    return sortedTransactions.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final categories = appProvider.transactions.map((t) => t.category).toSet().toList();
        final totalIncome = _calculateTotalIncome(appProvider.transactions);
        final totalExpenses = _calculateTotalExpenses(appProvider.transactions);
        final totalBalance = _calculateTotalBalance(appProvider.transactions);
        final recentTransactions = _getRecentTransactions(appProvider.transactions);

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: RefreshIndicator(
            onRefresh: () async => appProvider.loadData(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      '💸 MoneyVibes',
                      style: AppStyles.headline1,
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 60,
                            right: 16,
                            child: ScaleTransition(
                              scale: _animation,
                              child: IconButton(
                                icon: const Icon(Icons.bar_chart, color: AppColors.textPrimary, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const StatisticsScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                              .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                tooltip: 'Lihat Statistik',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        FinanceSummaryCard(
                          totalBalance: totalBalance,
                          totalIncome: totalIncome,
                          totalExpenses: totalExpenses,
                        ),
                        const SizedBox(height: 16),
                        AnimatedCard(
                          gradientColors: const [AppColors.budgetGradientStart, AppColors.budgetGradientEnd],
                          child: appProvider.currentBudget != null
                              ? ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              'Budget Mingguan: ${FormatUtils.formatCurrency(appProvider.currentBudget!.amount)} 💰',
                              style: AppStyles.budgetTitle,
                            ),
                            subtitle: Text(
                              'Mulai: ${FormatUtils.formatDate(appProvider.currentBudget!.startDate)} 📅',
                              style: AppStyles.budgetSubtitle,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        BudgetFormScreen(budget: appProvider.currentBudget),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                ).then((result) {
                                  if (result == true) appProvider.loadData();
                                });
                              },
                            ),
                          )
                              : const Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity, // Ensure full width when no budget
                              child: Text(
                                'Atur budget Anda sekarang! 🚀',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        QuickOverviewCard(recentTransactions: recentTransactions),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Kategori Transaksi 🔥',
                      style: AppStyles.headline2,
                    ),
                  ),
                ),
                appProvider.transactions.isEmpty
                    ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Tambah transaksi pertama Anda! 😄',
                      style: AppStyles.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: AnimatedCard(
                          delay: Duration(milliseconds: 100 * index),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    TransactionCategoryScreen(category: category),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              '$category ${AppCategories.categoryEmojis[category] ?? '❓'}',
                              style: AppStyles.bodyText1,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: CustomFAB(
            onTransactionPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const TransactionFormScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ).then((result) {
                if (result == true) appProvider.loadData();
              });
            },
            onBudgetPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => BudgetFormScreen(budget: appProvider.currentBudget),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ).then((result) {
                if (result == true) appProvider.loadData();
              });
            },
          ),
        );
      },
    );
  }
}