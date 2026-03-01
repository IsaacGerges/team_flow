import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';

class EditProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final Widget? suffixIcon;

  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ?suffixIcon,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
