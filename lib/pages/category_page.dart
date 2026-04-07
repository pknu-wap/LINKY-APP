import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Widget> _categories = [
    const CategorySelect(categoryText: 'Text1'),
    const SizedBox(width: 10),
    const CategorySelect(categoryText: 'Text2'),
    const SizedBox(width: 10),
    const CategorySelect(categoryText: 'Text3'),
    const SizedBox(width: 10),
    const CategorySelect(categoryText: 'Text4'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xff058aff),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _categories),
        ),
      ),
    );
  }
}

class CategorySelect extends StatelessWidget {
  final String categoryText;

  const CategorySelect({
    super.key,
    required this.categoryText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        height: 40,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(child: Text(categoryText)),
        ),
      ),
      onTap: () => print('$categoryText clicked'),
    );
  }
}
