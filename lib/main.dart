// main.dart
import 'package:flutter/material.dart';
import 'package:reminder_app/hive_service.dart';
import 'package:reminder_app/notification_service.dart';
import 'package:reminder_app/reminder_list_screen.dart';
import 'package:reminder_app/reminder_repository.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();
  final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZone));

  // Initialize notification service
  await NotificationService().init();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService;
  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: ReminderListScreen(
        reminderRepository: ReminderRepository(hiveService),
      ),
    );
  }
}
