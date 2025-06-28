import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyvibes/core/constants/app_colors.dart';
import 'package:moneyvibes/core/constants/app_styles.dart';
import 'package:moneyvibes/screens/home_screen.dart';
import 'package:moneyvibes/core/services/notification_service.dart';
import 'package:moneyvibes/providers/app_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MoneyVibesApp());
}

class MoneyVibesApp extends StatelessWidget {
  const MoneyVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'MoneyVibes',
        theme: ThemeData(
          primaryColor: AppColors.primaryDark,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          textTheme: TextTheme(
            bodyLarge: AppStyles.bodyText1,
            bodyMedium: AppStyles.bodyText2,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            titleTextStyle: AppStyles.headline2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
