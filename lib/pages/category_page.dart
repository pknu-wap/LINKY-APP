import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_select_category.dart';
import 'package:std/widgets/public_contents_box.dart';

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

// List<String> categoryNames = ['전체', '즐겨찾기'];

class _CategoryPageState extends State<CategoryPage> {
  String selectedCategory = '전체';

  // void _updatePage(int index) {
  //   setState(() {
  //     categories_contentsTitle.removeAt(index);
  //     categories_contentsURL.removeAt(index);
  //     contentsFavorite.removeAt(index);
  //   });
  // }

  // late List<bool> contentsFavorite = List.generate(
  //   categories_contentsTitle.length,
  //   (index) => false,
  // );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allContents = appState.contents;
    final categories = appState.categories;

    final filteredItems = allContents.where((item) {
      if (item.isPrivate) return false;
      if (selectedCategory == 'All' || selectedCategory == '전체') return true;
      if (selectedCategory == 'Favorites' || selectedCategory == '즐겨찾기') {
        return item.isFavorite;
      }
      return item.category == selectedCategory;
    }).toList();

    final List<Map<String, String>> currentCategories = categories.map((name) {
      final publicItems = allContents.where((item) => !item.isPrivate).toList();
      int count;
      if (name == 'All' || name == '전체') {
        count = publicItems.length;
      } else if (name == 'Favorites' || name == '즐겨찾기') {
        count = publicItems.where((item) => item.isFavorite).length;
      } else {
        count = publicItems.where((item) => item.category == name).length;
      }
      return {"title": name, "count": count.toString()};
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f2f6),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              AppBarDesign(
                appbarText: 'Category',
                appbarIcon: 'assets/images/CategoryIcon.png',
              ),
              const SizedBox(height: 13),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: currentCategories.map((cat) {
                    final String? categoryTitle = cat["title"];
                    final String? categoryCount = cat["count"];

                    bool isSelected = selectedCategory == categoryTitle;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat["title"]!;
                          });
                        },
                        child: SelectCategoryHome(
                          categoryCount: categoryCount!,
                          categoryTitle: categoryTitle!,
                          backgroundColor: isSelected
                              ? AppColors.mainGreen
                              : AppColors.white,
                          countBackgroundColor: isSelected
                              ? const Color(0xffffffff)
                              : const Color(0xFFC5C5C5),
                          textColor: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 13),
              filteredItems.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          "\n일정을 추가해주세요!",
                          style: GoogleFonts.inter(
                            color: AppColors.textGrey,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Column(
                            children: [
                              ContentsBox(
                                contentID: item.id,
                                onActionDone: () => context
                                    .read<AppState>()
                                    .removeContent(item.id),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
