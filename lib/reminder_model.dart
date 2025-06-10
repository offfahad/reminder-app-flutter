import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reminder_model.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isCompleted;

  Reminder({
    String? id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  // No need for toMap/fromMap anymore as Hive handles serialization
}
