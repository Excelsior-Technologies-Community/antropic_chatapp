import 'package:chatapp/src/prompt_evalution.dart';
import 'package:chatapp/src/tool_screen.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    ChatScreen(),
    PromptEvaluationScreen(),
    ToolsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: "Evaluate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_important),
            label: "Tools",
          ),
        ],
      ),
    );
  }
}