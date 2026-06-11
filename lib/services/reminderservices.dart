import '../model/reminder_model.dart';

class ReminderService {
  final List<ReminderModel> reminders = [];

  int extractMinutes(String text) {
    final regex = RegExp(r'(\d+)\s*(minute|min|minutes)');
    final match = regex.firstMatch(text.toLowerCase());
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }

  void checkReminders(
    List<Map<String, dynamic>> messages,
  ) {
    final now = DateTime.now();

    for (final reminder in reminders) {
      if (!reminder.isTriggered &&
          now.isAfter(reminder.reminderTime)) {
        reminder.isTriggered = true;

        messages.add({
          "text": "🔔 Reminder: ${reminder.title}",
          "isUser": false,
        });
      }
    }
  }

  void markAllTriggeredAsSeen() {
    for (final reminder in reminders) {
      if (reminder.isTriggered) {
        reminder.isSeen = true;
      }
    }
  }

  void addReminder(String text) {
    final minutes = extractMinutes(text);

    reminders.add(
      ReminderModel(
        title: text,
        reminderTime: DateTime.now().add(
          Duration(minutes: minutes),
        ),
      ),
    );
  }
  List<ReminderModel> getTriggeredReminders() {
    final now = DateTime.now();
    for (final reminder in reminders) {
      if (!reminder.isTriggered &&
          now.isAfter(reminder.reminderTime)) {
        reminder.isTriggered = true;
      }
    }
    return reminders;
  }
  int get badgeCount =>
      reminders.where(
        (r) => r.isTriggered && !r.isSeen,
      ).length;
}