import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/category_page_select_category.dart';
import 'package:std/widgets/public_popup_menu_button.dart';

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
  String selectedCategory = 'All';

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

    return Scaffold(
      backgroundColor: const Color(0xFFf0f2f6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 41),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 34.43,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffffffff),
                    ),
                    child: Image.asset('assets/images/CategoryIcon.png'),
                  ),
                  const SizedBox(width: 8),
                  Text('Category', style: GoogleFonts.inter(fontSize: 24)),
                ],
              ),
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
                    padding: const EdgeInsets.only(right: 12),
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
                            : Colors.white,
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Container(
                      width: double.infinity,
                      height: 138,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 11),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 9),
                            child: Container(
                              height: 53,
                              decoration: BoxDecoration(
                                color: AppColors.mainGreen,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 21,
                                  right: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    PopupButton(
                                      contentID: item.id,
                                      onActionDone: () => context
                                          .read<AppState>()
                                          .removeContent(item.id),
                                      context: context,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              item.url, // targetIdx로 수정 완료
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xff7E7E7E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12.78),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<AppState>().toggleFavorite(
                                      item,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      item.isFavorite
                                          ? 'assets/images/FavoriteIcon_Active.png'
                                          : 'assets/images/FavoriteIcon.png',
                                      height: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
