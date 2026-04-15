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

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int selectedIndex = 0;

  final List<List<TextEditingController>> titleControllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );
  final List<List<TextEditingController>> urlControllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );

  void _openEditSheet(int categoryIndex, int cardIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Category", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: titleControllers[categoryIndex][cardIndex],
                decoration: InputDecoration(
                  labelText: "제목 수정",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        titleControllers[categoryIndex][cardIndex].clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlControllers[categoryIndex][cardIndex],
                decoration: InputDecoration(
                  labelText: "URL 수정",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        urlControllers[categoryIndex][cardIndex].clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: "날짜 수정",
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: "카테고리 1",
                items: ["카테고리 1", "카테고리 2", "카테고리 3"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: "카테고리 수정",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget buildCategoryCards(int categoryIndex) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleControllers[categoryIndex][index],
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "제목",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () => _openEditSheet(categoryIndex, index),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: urlControllers[categoryIndex][index],
                  decoration: InputDecoration(
                    labelText: "URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.star_border),
                    SizedBox(width: 12),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Category")),
      body: buildCategoryCards(selectedIndex),
    );
  }
}
