import 'package:flutter/material.dart';
import 'package:linkyapp/pages/calender.dart';
import 'package:linkyapp/pages/reminder.dart';

class Slidepage extends StatefulWidget {
  const Slidepage({super.key});

  @override
  State<Slidepage> createState() => _SlidepageState();
}

class _SlidepageState extends State<Slidepage> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [CalendarPage(), ReminderScreen()],
        ),
      ),
    );
  }
}
