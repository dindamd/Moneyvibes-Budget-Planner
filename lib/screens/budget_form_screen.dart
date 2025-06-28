import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/utils/format_utils.dart';
import 'package:moneyvibes/core/widgets/animated_card.dart';
import 'package:moneyvibes/models/budget.dart';
import 'package:moneyvibes/providers/app_provider.dart';

class BudgetFormScreen extends StatefulWidget {
  final Budget? budget;

  const BudgetFormScreen({this.budget, super.key});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late String _startDate;

  @override
  void initState() {
    super.initState();
    _amount = widget.budget?.amount ?? 0.0;
    _startDate = widget.budget?.startDate ?? DateTime.now().toIso8601String().split('T')[0];
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
        _startDate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _deleteBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus budget ini?'),
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
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.deleteBudget(widget.budget!.id!);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          widget.budget == null ? 'Atur Budget' : 'Edit Budget',
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
                  child: TextFormField(
                    initialValue: _amount == 0.0 ? '' : _amount.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Budget (Rp)',
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
                  child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(text: FormatUtils.formatDate(_startDate)),
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan tanggal!';
                          try {
                            DateTime.parse(_startDate);
                            return null;
                          } catch (e) {
                            return 'Format tanggal salah!';
                          }
                        },
                        onSaved: (value) => _startDate = _startDate,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.budget != null)
                    ElevatedButton(
                      onPressed: _deleteBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hapus Budget'),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final budget = Budget(
                          id: widget.budget?.id,
                          amount: _amount,
                          startDate: _startDate,
                        );
                        final appProvider = Provider.of<AppProvider>(context, listen: false);
                        try {
                          if (widget.budget == null) {
                            await appProvider.addBudget(budget);
                          } else {
                            await appProvider.updateBudget(budget);
                          }
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: Text(widget.budget == null ? 'Simpan Budget' : 'Perbarui Budget'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}