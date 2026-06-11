import 'package:flutter/material.dart';

class CustomFillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  const CustomFillButton({super.key,required this.onPressed,required this.title});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
  }
}
//isLoading ? null : extractJson
//"Extract Data"