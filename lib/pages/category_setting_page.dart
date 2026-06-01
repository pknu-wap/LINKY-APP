import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';

class CategorySettingPage extends StatefulWidget {
  const CategorySettingPage({super.key});

  @override
  State<CategorySettingPage> createState() => _CategorySettingPageState();
}

class _CategorySettingPageState extends State<CategorySettingPage> {
  @override
  void initState() {
    super.initState();
  }

  InputDecoration inputBox(String hint, {Color? fillColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      filled: true,
      fillColor: fillColor ?? AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.outlineGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.mainGreen),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final reorderableCategories = appState.categories
        .where((item) => item != '전체' && item != '즐겨찾기')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 20),
                AppBarDesign(
                  appbarText: '카테고리 설정',
                  appbarIcon: Icons.reorder,
                ),
                const SizedBox(height: 25),
                const Row(
                  children: [
                    Icon(
                      Icons.unfold_more_rounded,
                      color: AppColors.mainGreen,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "카테고리 순서 설정",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ReorderableListView(
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) {
                          return Material(
                            color: AppColors.mainGreen.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      final item = reorderableCategories[oldIndex];
                      final originalOldIndex = appState.categories.indexOf(
                        item,
                      );
                      int originalNewIndex;

                      if (newIndex < reorderableCategories.length) {
                        originalNewIndex = appState.categories.indexOf(
                          reorderableCategories[newIndex],
                        );
                      } else {
                        originalNewIndex =
                            appState.categories.indexOf(
                              reorderableCategories.last,
                            ) +
                            1;
                      }

                      appState.reorderCategories(
                        originalOldIndex,
                        originalNewIndex,
                      );
                    },
                    children: reorderableCategories.map((category) {
                      return ListTile(
                        key: ValueKey(category),
                        title: Row(
                          children: [
                            Transform.translate(
                              offset: Offset(0, 1.5),
                              child: Text(
                                (appState.categories.indexOf(category) - 1)
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.menu,
                          color: AppColors.textGrey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
