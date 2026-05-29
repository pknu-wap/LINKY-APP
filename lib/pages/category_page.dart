import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_messagebox.dart';
import 'package:std/widgets/public_select_category.dart';
import 'package:std/widgets/public_contents_box.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:std/snackbar.dart';

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
  String selectedCategory = '전체';

  final storage = const FlutterSecureStorage();

  void _showChatRoomOptions(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            categoryName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                final TextEditingController categoryController =
                    TextEditingController();

                String newCategoryName = categoryName;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppColors.white,
                      title: Text('카테고리 이름 수정'),
                      content: TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          hintText: '수정할 카테고리 이름을 입력해주세요',
                          hintStyle: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: AppColors.outlineGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: AppColors.outlineGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.mainGreen,
                            ),
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.only(
                        top: 20,
                        right: 20,
                        left: 20,
                      ),
                      actionsPadding: EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                        right: 10,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            newCategoryName = categoryController.text;
                            if (newCategoryName.isEmpty ||
                                newCategoryName == '전체' ||
                                newCategoryName == '즐겨찾기') {
                              showCustomSnackBar(
                                context,
                                message: "올바르지 않은 카테고리명입니다",
                                isError: true,
                              );
                            } else {
                              bool isValid = !context
                                  .read<AppState>()
                                  .categoryNameCheck(newCategoryName);
                              if (isValid) {
                                context.read<AppState>().updateCategory(
                                  oldCategoryName: categoryName,
                                  newCategoryName: newCategoryName,
                                );
                                if (selectedCategory == categoryName) {
                                  selectedCategory = newCategoryName;
                                }

                                showCustomSnackBar(
                                  context,
                                  message: "카테고리 이름이 수정되었습니다.",
                                );
                              } else {
                                showCustomSnackBar(
                                  context,
                                  message: "이미 존재하는 카테고리명입니다.",
                                  isError: true,
                                );
                              }
                            }
                          },
                          child: Text("확인"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: Text('수정'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return DialogPopup(
                      title: '해당 카테고리를 삭제하시겠어요?',
                      onConfirm: () {
                        context.read<AppState>().removeCategory(
                          categoryName,
                        );
                        showCustomSnackBar(
                          context,
                          message: "카테고리가 삭제되었습니다.",
                        );
                      },
                      confirmText: '삭제',
                      boxType: BoxType.warning,
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('삭제'),
              ),
            ),
          ],
        );
      },
    );
  }

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
                        onLongPress: () {
                          if (categoryTitle != '전체' &&
                              categoryTitle != '즐겨찾기') {
                            _showChatRoomOptions(context, categoryTitle);
                          }
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
                                currentCategory: selectedCategory,
                                onActionDone: () async {
                                  await context.read<AppState>().removeContent(
                                    id: item.id,
                                  );
                                },
                              ),
                              const SizedBox(height: 13),
                            ],
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
