import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/core/services/notification_service.dart';
import 'package:moneyvibes/providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = NotificationService.instance.isEnabled;
  }

  Future<void> _resetAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin mereset semua data? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.resetAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data telah direset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Pengaturan', style: AppStyles.headline2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi',
              style: AppStyles.headline2,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(
                'Aktifkan Notifikasi',
                style: AppStyles.bodyText1,
              ),
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await NotificationService.instance.toggleNotifications(value);
              },
              activeColor: AppColors.accent,
            ),
            const SizedBox(height: 32),
            Text(
              'Data',
              style: AppStyles.headline2,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                'Reset Semua Data',
                style: AppStyles.bodyText1,
              ),
              subtitle: Text(
                'Hapus semua transaksi dan budget',
                style: AppStyles.bodyText2,
              ),
              trailing: const Icon(Icons.delete_forever, color: AppColors.error),
              onTap: () => _resetAllData(context),
            ),
          ],
        ),
      ),
    );
  }
}