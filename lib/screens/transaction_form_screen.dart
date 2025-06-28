import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/constants/categories.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';
import 'package:moneyvibes/core/widgets/animated_card.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/providers/app_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({this.transaction, super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _category;
  late double _amount;
  late String _description;
  late String _date;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? 'Pemasukan';
    _category = widget.transaction?.category ??
        (_type == 'Pemasukan' ? AppCategories.incomeCategories[0] : AppCategories.expenseCategories[0]);
    _amount = widget.transaction?.amount ?? 0.0;
    _description = widget.transaction?.description ?? '';
    _date = widget.transaction?.date ?? DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        _date = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
          style: AppStyles.headline2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              AnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    items: ['Pemasukan', 'Pengeluaran']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _category = _type == 'Pemasukan'
                            ? AppCategories.incomeCategories[0]
                            : AppCategories.expenseCategories[0];
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Tipe Transaksi',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    items: (_type == 'Pemasukan' ? AppCategories.incomeCategories : AppCategories.expenseCategories)
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: _amount == 0.0 ? '' : _amount.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Masukkan jumlah!';
                      if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Jumlah harus positif!';
                      return null;
                    },
                    onSaved: (value) => _amount = double.parse(value!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _description = value ?? '',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(text: FormatUtils.formatDate(_date)),
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan tanggal!';
                          try {
                            DateTime.parse(_date);
                            return null;
                          } catch (e) {
                            return 'Format tanggal salah!';
                          }
                        },
                        onSaved: (value) => _date = _date,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final transaction = Transaction(
                      id: widget.transaction?.id,
                      type: _type,
                      category: _category,
                      amount: _amount,
                      description: _description,
                      date: _date,
                    );
                    final appProvider = Provider.of<AppProvider>(context, listen: false);
                    try {
                      if (widget.transaction == null) {
                        await appProvider.addTransaction(transaction);
                      } else {
                        await appProvider.updateTransaction(transaction);
                      }
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text(widget.transaction == null ? 'Simpan Transaksi' : 'Perbarui Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}