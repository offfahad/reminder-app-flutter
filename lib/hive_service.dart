import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder_app/reminder_model.dart';

class HiveService {
  static const String _reminderBoxName = 'reminders';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ReminderAdapter());
    await Hive.openBox<Reminder>(_reminderBoxName);
  }

  Box<Reminder> get remindersBox => Hive.box<Reminder>(_reminderBoxName);

  Future<void> close() async {
    await Hive.close();
  }
}
