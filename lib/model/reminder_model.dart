class ReminderModel {
  final String title;
  final DateTime reminderTime;
  bool isTriggered;
  bool isSeen;

  ReminderModel({
    required this.title,
    required this.reminderTime,
    this.isTriggered = false,
    this.isSeen = false,
  });
}