
import 'package:chatapp/model/tool_result.dart';

class ToolManager {
  static ToolResult? execute(String msg) {
    final text = msg.toLowerCase();

    // TIME TOOL
    if (text.contains("time") ||
        text.contains("current time") ||
        text.contains("what time")) {
      return ToolResult(
        handled: true,
        response: "Current Time: ${DateTime.now()}",
      );
    }

    // WEATHER TOOL (mock)
    if (text.contains("weather")) {
      return ToolResult(
        handled: true,
        response:
            "Weather Tool: Please integrate OpenWeather API for real data",
      );
    }

    // CALCULATOR TOOL (simple)
    if (RegExp(r'^\d+\s*[\+\-\*\/]\s*\d+$')
        .hasMatch(text)) {
      try {
        final parts = text.split(RegExp(r'[\+\-\*\/]'));
        final a = double.parse(parts[0].trim());
        final b = double.parse(parts[1].trim());

        double result = 0;

        if (text.contains("+")) result = a + b;
        if (text.contains("-")) result = a - b;
        if (text.contains("*")) result = a * b;
        if (text.contains("/")) result = a / b;

        return ToolResult(
          handled: true,
          response: "Calculator Result: $result",
        );
      } catch (_) {
        return ToolResult(
          handled: true,
          response: "Invalid calculation format",
        );
      }
    }

    return null;
  }
}