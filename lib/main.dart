import 'package:flutter/material.dart';

void main() {
  runApp(const Linky());
}

class Linky extends StatelessWidget {
  const Linky({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Linky', home: const CategoryPage());
  }
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 개수 지정
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/images/category_icon.png', width: 56),
          title: const Text('Category'),
        ),
        body: Column(
          children: const [
            TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '갯수 / 카테고리 제목'),
                Tab(text: '갯수 / 카테고리 제목'),
                Tab(text: '갯수 / 카테고리 제목'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text("Category 1 Page")),
                  Center(child: Text("Category 2 Page")),
                  Center(child: Text("Category 3 Page")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
