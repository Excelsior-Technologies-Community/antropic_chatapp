import 'dart:convert';
import 'package:chatapp/src/customWidgets/fillbutton.dart';
import 'package:chatapp/src/customWidgets/profilefeild.dart';
import 'package:flutter/material.dart';

class PromptEvaluationScreen extends StatefulWidget {
  const PromptEvaluationScreen({super.key});

  @override
  State<PromptEvaluationScreen> createState() =>
      _PromptEvaluationScreenState();
}

class _PromptEvaluationScreenState
    extends State<PromptEvaluationScreen> {
  final TextEditingController controller = TextEditingController();

  Map<String, dynamic>? extractedData;
  bool isLoading = false;
  Future<void> extractJson() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      isLoading = true;
      extractedData = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    final result = {
      "name": _findName(text),
      "email": _findEmail(text),
      "role": _findRole(text),
      "sentiment": _findSentiment(text),
      "confidence": 0.87,
    };

    setState(() {
      extractedData = result;
      isLoading = false;
    });
  }

  String _findEmail(String text) {
    final regex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
    return regex.firstMatch(text)?.group(0) ?? "Not found";
  }

  String _findName(String text) {
    final words = text.trim().split(" ");
    return words.isNotEmpty ? words.first : "Unknown";
  }

  String _findRole(String text) {
    final lower = text.toLowerCase();
    if (lower.contains("developer")) return "Developer";
    if (lower.contains("engineer")) return "Engineer";
    if (lower.contains("designer")) return "Designer";
    return "Unknown";
  }

  String _findSentiment(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("good") ||
        lower.contains("great") ||
        lower.contains("happy")) {
      return "Positive";
    }

    if (lower.contains("bad") ||
        lower.contains("sad") ||
        lower.contains("angry")) {
      return "Negative";
    }

    return "Neutral";
  }

  Color _sentimentColor(String sentiment) {
    switch (sentiment) {
      case "Positive":
        return Colors.green;
      case "Negative":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI JSON Extractor",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                maxLines: 5,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Paste unstructured text here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomFillButton(onPressed: isLoading? null : extractJson, title: "Extract Data"),

              const SizedBox(height: 24),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (extractedData != null) ...[
                Text(
                  "Extracted Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileFeild(label:"Name", value: extractedData!['name'], icon: Icons.person_outline),
                        const Divider(height: 24, thickness: 0.8),
                        ProfileFeild(label: "Email", value: extractedData!['email'], icon:Icons.mail_outline),
                        const Divider(height: 24, thickness: 0.8),
                        ProfileFeild(label:"Role", value:extractedData!['role'], icon:Icons.work_outline),
                        const Divider(height: 24, thickness: 0.8),

                        Row(
                          children: [
                            Icon(Icons.emoji_emotions_outlined, size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sentiment",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _sentimentColor(extractedData!['sentiment']).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      extractedData!['sentiment'],
                                      style: TextStyle(
                                        color: _sentimentColor(extractedData!['sentiment']),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 0.8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.analytics_outlined, size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Confidence Level",
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                      ),
                                      Text(
                                        "${(extractedData!['confidence'] * 100).toStringAsFixed(0)}%",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: extractedData!['confidence'],
                                      backgroundColor: Colors.grey.shade100,
                                      color: theme.primaryColor,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Raw JSON Response",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SelectionArea(
                      child: Text(
                        const JsonEncoder.withIndent("  ").convert(extractedData),
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13,
                          color: Colors.blueGrey.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}