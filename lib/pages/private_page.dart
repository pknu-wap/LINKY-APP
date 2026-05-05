import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_select_category.dart';
import 'package:std/widgets/public_contents_box.dart';

class PrivatePage extends StatefulWidget {
  const PrivatePage({super.key});

  @override
  State<PrivatePage> createState() => _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final privateList = appState.privateContents;

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 41),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 145,
                height: 34.43,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 34.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.mainPink,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.account_circle,
                          size: 25,
                        ),
                      ),
                    ),
                    Text(
                      'Only Me',
                      style: GoogleFonts.inter(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 13),
            SelectCategoryHome(
              categoryCount: privateList.length.toString(),
              categoryTitle: 'Only me',
              backgroundColor: AppColors.mainGreen,
              countBackgroundColor: AppColors.white,
              textColor: AppColors.white,
            ),

            // SelectCategory(
            //   categoryCount: privateList.length.toString(),
            //   categoryTitle: 'Only me',
            // ),
            SizedBox(height: 13),
            Expanded(child: _contentsScroll(privateList)),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _contentsScroll(List<ContentItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "일정을 추가해주세요!",
          style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 20),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: ContentsBox(
            key: ValueKey(item.id),
            contentID: item.id,
            onActionDone: () {
              context.read<AppState>().removeContent(item.id);
            },
          ),
        );
      },
    );
  }
}
