import 'package:chatapp/model/chat_model.dart';
import 'package:chatapp/services/gemini_services.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController systemPromptController =
      TextEditingController();

  final ScrollController scrollController = ScrollController();

  List<ChatMessageModel> messages = [];
  bool isLoading = false;

  double temperature = 0.7;
  int maxTokens = 1024;

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessageModel(text: text, isUser: true));
      isLoading = true;
    });

    controller.clear();
    _scrollToBottom();

    try {
      final response = await GeminiService().sendMessage(
        text,
        systemPrompt: systemPromptController.text,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      setState(() {
        messages.add(ChatMessageModel(text: response, isUser: false));
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(ChatMessageModel(
          text: "Error: $e",
          isUser: false,
        ));
      });
    } finally {
      setState(() => isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // =========================
  // 💬 USER + AI MESSAGE UI (IMPROVED)
  // =========================
  Widget buildMessage(ChatMessageModel msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  )
                : null,
            color: isUser ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
                  isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight:
                  isUser ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // ⚙ CONFIG CARD UI (IMPROVED)
  // =========================
  Widget buildConfigCard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            "⚙ Configuration",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("System Prompt"),
                  const SizedBox(height: 6),

                  TextField(
                    controller: systemPromptController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text("Temperature: ${temperature.toStringAsFixed(1)}"),
                  Slider(
                    value: temperature,
                    min: 0,
                    max: 2,
                    divisions: 20,
                    onChanged: (v) => setState(() => temperature = v),
                  ),

                  const SizedBox(height: 8),

                  Text("Max Tokens: $maxTokens"),
                  Slider(
                    value: maxTokens.toDouble(),
                    min: 128,
                    max: 2048,
                    divisions: 15,
                    onChanged: (v) =>
                        setState(() => maxTokens = v.toInt()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    systemPromptController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // =========================
  // 🧠 MAIN UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text("AI Chat Config"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SafeArea(
        child: Column(
          children: [
            buildConfigCard(),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return buildMessage(messages[index]);
                },
              ),
            ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),

            // =========================
            // INPUT BAR (MODERN UI)
            // =========================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      onPressed: isLoading ? null : sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}