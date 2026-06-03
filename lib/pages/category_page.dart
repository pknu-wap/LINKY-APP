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
          backgroundColor: AppColors.white,

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

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogPopup(
                      title: '카테고리 이름 수정',
                      height: 160,
                      boxType: BoxType.warning,
                      confirmText: '확인',
                      content: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: AppColors.mainGreen,
                            selectionColor: AppColors.mainGreen.withValues(
                              alpha: 0.3,
                            ),
                            selectionHandleColor: AppColors.mainGreen,
                          ),
                        ),
                        child: TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 1),
                            hintText: '수정할 이름을 입력해주세요',
                            hintStyle: const TextStyle(
                              color: AppColors.textGrey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onConfirm: () {
                        final newCategoryName = categoryController.text.trim();

                        if (newCategoryName.isEmpty ||
                            newCategoryName.replaceAll(' ', '') == '전체' ||
                            newCategoryName.replaceAll(' ', '') == '즐겨찾기' ||
                            newCategoryName.replaceAll(' ', '') == '나만보기') {
                          showCustomSnackBar(
                            context,
                            message: "기본설정 카테고리입니다",
                            isError: true,
                          );
                          return false;
                        }

                        if (newCategoryName != categoryName &&
                            context.read<AppState>().categoryNameCheck(
                              newCategoryName,
                            )) {
                          showCustomSnackBar(
                            context,
                            message: '이미 존재하는 카테고리명입니다.',
                            isError: true,
                          );
                          return false;
                        }

                        context.read<AppState>().updateCategory(
                          oldCategoryName: categoryName,
                          newCategoryName: newCategoryName,
                        );

                        if (selectedCategory == categoryName) {
                          setState(() {
                            selectedCategory = newCategoryName;
                          });
                        }

                        showCustomSnackBar(
                          context,
                          message: '카테고리명이 수정되었습니다.',
                        );
                        return true;
                      },
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
                        selectedCategory = '전체';
                        showCustomSnackBar(
                          context,
                          message: "카테고리가 삭제되었습니다.",
                        );
                        return true;
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

    return Scaffold(
      backgroundColor: const Color(0xFFf0f2f6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              AppBarDesign(
                appbarText: 'Category',
                appbarIcon: 'assets/images/CategoryIcon.svg',
              ),
              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                                    ? AppColors.white
                                    : AppColors.outlineGrey.withValues(
                                        alpha: 0.7,
                                      ),
                                textColor: isSelected
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final TextEditingController categoryController =
                          TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return DialogPopup(
                            title: "카테고리 추가",
                            height: 160,
                            content: Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme: TextSelectionThemeData(
                                  cursorColor: AppColors.mainGreen,
                                  selectionColor: AppColors.mainGreen
                                      .withValues(
                                        alpha: 0.3,
                                      ),
                                  selectionHandleColor: AppColors.mainGreen,
                                ),
                              ),
                              child: TextField(
                                controller: categoryController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 1,
                                  ),
                                  hintText: "카테고리를 입력해주세요.",
                                  hintStyle: GoogleFonts.inter(
                                    color: AppColors.textGrey,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            confirmText: "확인",
                            boxType: BoxType.warning,
                            onConfirm: () {
                              final newCategoryName = categoryController.text
                                  .trim();

                              if (newCategoryName.isEmpty) {
                                showCustomSnackBar(
                                  context,
                                  message: '카테고리를 입력해주세요.',
                                  isError: true,
                                );
                                return false;
                              }

                              if (newCategoryName.replaceAll(' ', '') == '전체' ||
                                  newCategoryName.replaceAll(' ', '') ==
                                      '즐겨찾기' ||
                                  newCategoryName.replaceAll(' ', '') ==
                                      '나만보기') {
                                showCustomSnackBar(
                                  context,
                                  message: '기본설정 카테고리입니다.',
                                  isError: true,
                                );
                                return false;
                              }
                              final alredyExists = context
                                  .read<AppState>()
                                  .categoryNameCheck(newCategoryName);

                              if (alredyExists) {
                                showCustomSnackBar(
                                  context,
                                  message: '이미 존재하는 카테고리 입니다.',
                                  isError: true,
                                );
                                return false;
                              }
                              context.read<AppState>().addCategory(
                                newCategoryName,
                              );

                              setState(() {
                                selectedCategory = newCategoryName;
                              });

                              showCustomSnackBar(
                                context,
                                message: '카테고리가 추가되었습니다.',
                              );
                              return true;
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.25),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.black, width: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.mainGreen,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          "링크를 추가해주세요!",
                          style: GoogleFonts.inter(
                            color: AppColors.textGrey,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 15),
                          Expanded(
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
                                        await context
                                            .read<AppState>()
                                            .removeContent(
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
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
