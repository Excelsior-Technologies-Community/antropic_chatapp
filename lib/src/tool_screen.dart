import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chatapp/services/reminderservices.dart';
import 'package:chatapp/src/customWidgets/promptcard.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ReminderService reminderService = ReminderService();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        reminderService.checkReminders(messages);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({
        "text": text,
        "isUser": true,
      });
    });
    controller.clear();
    if (text.toLowerCase().contains("remind")) {
      reminderService.addReminder(text);
      setState(() {
        messages.add({
          "text": "⏰ Reminder created successfully.",
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
    reminderService.markAllTriggeredAsSeen();
    setState(() {});
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final reminders = reminderService.reminders;
        if (reminders.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: Text(
                "No reminders",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * .6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Reminders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: reminder.isTriggered
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          reminder.isTriggered
                              ? Icons.notifications_active
                              : Icons.schedule,
                          color: reminder.isTriggered
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      title: Text(reminder.title),
                      subtitle: Text(
                        "Due: ${reminder.reminderTime}",
                      ),
                      trailing: Chip(
                        label: Text(
                          reminder.isTriggered? "Completed" : "Pending",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
              if (reminderService.badgeCount > 0)
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
                      reminderService.badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          PromptCard(
                            text: "Remind me in 10 To Push Code",
                            controller: controller,
                          ),
                          const SizedBox(width: 10),
                          PromptCard(
                            text: "Remind me to call after 5 min",
                            controller: controller,
                          ),
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
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                      onSubmitted: (_) => sendMessage(),
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