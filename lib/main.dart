import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'model/recurring_transaction.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'utils/app_theme.dart';
import 'utils/notifications_service.dart';

late SharedPreferences _sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestNotificationPermissions();
  NotificationService().initializeNotifications();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);

  _sharedPreferences = await SharedPreferences.getInstance();

  // perform recurring transactions checks
  DateTime? lastCheckGetPref = _sharedPreferences.getString('last_recurring_transactions_check') != null ? DateTime.parse(_sharedPreferences.getString('last_recurring_transactions_check')!) : null;
  DateTime? lastRecurringTransactionsCheck = lastCheckGetPref;

  if(lastRecurringTransactionsCheck == null || DateTime.now().difference(lastRecurringTransactionsCheck).inDays >= 1){
    RecurringTransactionMethods().checkRecurringTransactions();
    // update last recurring transactions runtime
    await _sharedPreferences.setString('last_recurring_transactions_check', DateTime.now().toIso8601String());
  }

  initializeDateFormatting('it_IT', null).then((_) => runApp(Phoenix(child: const ProviderScope(child: Launcher()))));
}

class Launcher extends ConsumerWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Although the saved key refers to 'is_first_login',
    // its behavior aligns with a 'has the user completed onboarding' check.
    // It has not been renamed to maintain compatibility with previous versions.
    final bool isFirstLogin = _sharedPreferences.getBool('is_first_login') ?? true;

    final appThemeState = ref.watch(appThemeStateNotifier);
    return MaterialApp(
      title: 'Sossoldi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: makeRoute,
      initialRoute: isFirstLogin ? '/onboarding' : '/',
    );
  }
}
