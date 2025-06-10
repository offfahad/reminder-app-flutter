import 'package:reminder_app/hive_service.dart';
import 'package:reminder_app/reminder_model.dart';

class ReminderRepository {
  final HiveService _hiveService;

  ReminderRepository(this._hiveService);

  Future<List<Reminder>> getReminders() async {
    return _hiveService.remindersBox.values.toList();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _hiveService.remindersBox.add(reminder);
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    final reminder = await _findReminderById(updatedReminder.id);
    if (reminder != null) {
      reminder.title = updatedReminder.title;
      reminder.dateTime = updatedReminder.dateTime;
      reminder.isCompleted = updatedReminder.isCompleted;
      await reminder.save();
    }
  }

  Future<void> deleteReminder(String id) async {
    final reminder = await _findReminderById(id);
    if (reminder != null) {
      await reminder.delete();
    }
  }

  Future<Reminder?> _findReminderById(String id) async {
    try {
      return _hiveService.remindersBox.values.firstWhere(
        (reminder) => reminder.id == id,
      );
    } catch (e) {
      return null; // Return null if not found
    }
  }
}
