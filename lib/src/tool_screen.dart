import 'dart:async';
import 'package:flutter/material.dart';

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

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [];
  final List<ReminderModel> reminders = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => checkReminders(),
    );
  }

  Widget _buildPromptCard(String text) {
    return GestureDetector(
      onTap: () {
        controller.text = text;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void checkReminders() {
    final now = DateTime.now();

    for (final r in reminders) {
      if (!r.isTriggered && now.isAfter(r.reminderTime)) {
        r.isTriggered = true;

        if (!messages.any((m) => m["text"] == "🔔 Reminder: ${r.title}")) {
          messages.add({
            "text": "🔔 Reminder: ${r.title}",
            "isUser": false,
          });
        }
      }
    }

    setState(() {});
  }

  int get badgeCount =>
      reminders.where((r) => r.isTriggered && !r.isSeen).length;

  int extractMinutes(String text) {
    final regex = RegExp(r'(\d+)\s*(minute|min|minutes)');
    final match = regex.firstMatch(text.toLowerCase());

    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
    });

    controller.clear();

    if (text.toLowerCase().contains("remind")) {
      final minutes = extractMinutes(text);

      reminders.add(
        ReminderModel(
          title: text,
          reminderTime: DateTime.now().add(Duration(minutes: minutes)),
        ),
      );

      setState(() {
        messages.add({
          "text": "⏰ Reminder set for $minutes minute(s).",
          "isUser": false,
        });
      });

      return;
    }

    setState(() {
      messages.add({
        "text": "Tool not found.",
        "isUser": false,
      });
    });
  }

  void showReminders() {
    for (final r in reminders) {
      r.isSeen = true;
    }

    setState(() {});

    showModalBottomSheet(
      context: context,
      builder: (_) {
        final list = reminders.where((r) => r.isTriggered).toList();

        return list.isEmpty
            ? const Center(child: Text("No reminders"))
            : ListView(
                children: list.map((r) {
                  return ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: Text(r.title),
                    subtitle: Text(
                      "Time: ${r.reminderTime}\nSeen: ${r.isSeen}",
                    ),
                  );
                }).toList(),
              );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tools Assistant"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: showReminders,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {

                // ✅ PROMPTS INSIDE CHAT (TOP SECTION)
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPromptCard("Remind me in 10 minutes"),
                          const SizedBox(width: 10),
                          _buildPromptCard("Remind me to call after 5 min"),
                          const SizedBox(width: 10),
                          _buildPromptCard("Remind me tomorrow"),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index - 1];

                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isUser"]
                          ? Colors.blue
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"]
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Ask a tool...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}