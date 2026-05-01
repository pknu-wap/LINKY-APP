import 'package:flutter/material.dart';
import 'package:std/constants.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onPressed;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.mainGreen,
          foregroundColor: Color(0xFF000000),
          side: BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedDate == null
                  ? '만료일 선택'
                  : '만료일: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
          ],
        ),
      ),
    );
  }
}
