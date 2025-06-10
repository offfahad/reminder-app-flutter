// reminder_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/add_edit_reminder_screen.dart';
import 'package:reminder_app/helper.dart';
import 'package:reminder_app/notification_service.dart';
import 'package:reminder_app/reminder_model.dart';
import 'package:reminder_app/reminder_repository.dart';

class ReminderListScreen extends StatefulWidget {
  final ReminderRepository reminderRepository;
  const ReminderListScreen({super.key, required this.reminderRepository});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await widget.reminderRepository.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _addReminder() async {
    final result = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditReminderScreen()),
    );

    if (result != null) {
      await widget.reminderRepository.addReminder(result);
      await _notificationService.scheduleNotification(
        id: generateNotificationId(result.id),
        title: 'Reminder',
        body: result.title,
        scheduledTime: result.dateTime,
      );
      _loadReminders();
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final result = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditReminderScreen(reminder: reminder),
      ),
    );

    if (result != null) {
      await widget.reminderRepository.updateReminder(result);
      await _notificationService.cancelNotification(
        generateNotificationId(result.id),
      );
      await _notificationService.scheduleNotification(
        id: generateNotificationId(result.id),
        title: 'Reminder',
        body: result.title,
        scheduledTime: result.dateTime,
      );
      _loadReminders();
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await widget.reminderRepository.deleteReminder(reminder.id);
    await _notificationService.cancelNotification(
      generateNotificationId(reminder.id),
    ); // Updated
    _loadReminders();
  }

  Future<void> _toggleCompletion(Reminder reminder) async {
    final updatedReminder = Reminder(
      id: reminder.id,
      title: reminder.title,
      dateTime: reminder.dateTime,
      isCompleted: !reminder.isCompleted,
    );
    await widget.reminderRepository.updateReminder(updatedReminder);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addReminder),
        ],
      ),
      body:
          _reminders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reminders yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add one',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteReminder(reminder),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: reminder.isCompleted,
                          onChanged: (value) => _toggleCompletion(reminder),
                        ),
                        title: Text(
                          reminder.title,
                          style:
                              reminder.isCompleted
                                  ? TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).disabledColor,
                                  )
                                  : null,
                        ),
                        subtitle: Text(
                          DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(reminder.dateTime),
                          style:
                              reminder.isCompleted
                                  ? TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).disabledColor,
                                  )
                                  : null,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editReminder(reminder),
                        ),
                        onTap: () => _editReminder(reminder),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
