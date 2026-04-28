import 'package:flutter/material.dart';
import 'std/pages/add_link_page.dart';

void main() {
  runApp(const LinkyApp());
}

class LinkyApp extends StatelessWidget {
  const LinkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF0F2F6)),
      ),
      home: const AddLinkPage(),
    );
  }
}
