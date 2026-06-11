import 'package:flutter/material.dart';

class ProfileFeild extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const ProfileFeild({super.key,required this.label,required this.value,required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );;
  }
}