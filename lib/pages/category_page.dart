import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:std/constants.dart';

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

class FilterButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainGreen : AppColors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("갯수", style: TextStyle(color: AppColors.black)),
            ),
            const SizedBox(width: 8),
            Text(
              "카테고리 제목",
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                      backgroundColor: AppColors.mainRed,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, color: AppColors.white),
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
                  color: AppColors.mainGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleControllers[categoryIndex][index],
                          style: const TextStyle(color: AppColors.black),
                          decoration: const InputDecoration(
                            hintText: "  제목",
                            hintStyle: TextStyle(color: AppColors.black),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.white,
                        ),
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
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset('assets/images/FavoriteIcon.png'),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/CalendarIcon.png'),
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
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/CategoryIcon.png', height: 24),
            const SizedBox(width: 8),
            const Text("Category"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      setState(() {
                        selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: buildCategoryCards(selectedIndex)),
        ],
      ),
    );
  }
}
