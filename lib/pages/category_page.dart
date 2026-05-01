import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/select_category_categorypage.dart';
import 'package:std/widgets/popup_menu_button_categorypage.dart';

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
  List<String> contentsTitle = ['Title1', '제목2', 'Title3', '제목4', 'Title5'];
  List<String> contentsURL = ['URL1', 'URL2', 'URL3', 'URL4', 'URL5'];
  final List<String> categoryNames = [
    'All',
    'Favorites',
    'Category1',
    'Category2',
  ];
  String selectedCategory = 'All';

  void _updatePage(int index) {
    setState(() {
      contentsTitle.removeAt(index);
      contentsURL.removeAt(index);
      contentsFavorite.removeAt(index);
    });
  }

  late List<bool> contentsFavorite = List.generate(
    contentsTitle.length,
    (index) => false,
  );

  @override
  Widget build(BuildContext context) {
    // [1] 필터링 로직 정리
    List<int> filteredIndices = [];
    for (int i = 0; i < contentsTitle.length; i++) {
      if (selectedCategory == 'All') {
        filteredIndices.add(i);
      } else if (selectedCategory == 'Favorites') {
        if (contentsFavorite[i]) filteredIndices.add(i);
      } else {
        // 나머지 카테고리는 제목에 카테고리명이 포함되어 있는지 확인
        if (contentsTitle[i].contains(selectedCategory)) {
          filteredIndices.add(i);
        }
      }
    }

    final List<Map<String, String>> currentCategories = categoryNames.map((
      name,
    ) {
      String count;
      if (name == 'All') {
        count = contentsTitle.length.toString(); //
      } else if (name == 'Favorites') {
        count = contentsFavorite.where((e) => e).length.toString(); //
      } else {
        count = contentsTitle
            .where((title) => title.contains(name))
            .length
            .toString();
      }

      return {"title": name, "count": count};
    }).toList(); //

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
                  bool isSelected = selectedCategory == cat["title"];

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat["title"]!;
                        });
                      },
                      child: SelectCategoryHome(
                        categoryCount: cat["count"]!,
                        categoryTitle: cat["title"]!,
                        backgroundColor: isSelected ? mainGreen : Colors.white,
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
                itemCount: filteredIndices.length,
                itemBuilder: (context, index) {
                  int targetIdx = filteredIndices[index];
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
                            color: Colors.black,
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
                                color: mainGreen,
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
                                      contentsTitle[targetIdx],
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    PopupButtonHome(
                                      onActionDone: () =>
                                          _updatePage(targetIdx),
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
                              contentsURL[targetIdx], // targetIdx로 수정 완료
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
                                    setState(() {
                                      contentsFavorite[targetIdx] =
                                          !contentsFavorite[targetIdx];
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      contentsFavorite[targetIdx]
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
