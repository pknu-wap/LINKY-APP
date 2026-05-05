import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_content_detail_sheet.dart';
import 'package:std/widgets/public_popup_menu_button.dart';
import 'package:std/constants.dart';

class ContentsBox extends StatelessWidget {
  final int contentID;
  final VoidCallback onActionDone;

  const ContentsBox({
    super.key,
    required this.contentID,
    required this.onActionDone,
  });

  @override
  Widget build(BuildContext context) {
    final targetItem = context.select<AppState, ContentItem?>(
      (state) => state.contentById(contentID),
    );

    final titleText = targetItem?.title ?? "찾을 수 없음";
    final urlText = targetItem?.url ?? "찾을 수 없음";
    final datetimeText = targetItem?.time ?? '';

    return InkWell(
      child: Container(
        width: 375,
        height: 138,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(23),
          border: BoxBorder.all(color: AppColors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 11),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Container(
                width: 357,
                height: 53,
                decoration: BoxDecoration(
                  color: AppColors.mainGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 21, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titleText,
                        style: GoogleFonts.inter(
                          color: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                      PopupButton(
                        contentID: contentID,
                        onActionDone: onActionDone,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                height: 17,
                child: Text(
                  urlText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 12.5,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: targetItem!.isPrivate
                  ? Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 24),
                        SizedBox(width: 7),
                        Text(
                          datetimeText,
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<AppState>().toggleFavorite(targetItem);
                          },
                          child: Image.asset(
                            targetItem.isFavorite
                                ? 'assets/images/FavoriteIcon_Active.png'
                                : 'assets/images/FavoriteIcon.png',
                            height: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.calendar_today_outlined, size: 24),
                        SizedBox(width: 7),
                        Text(
                          datetimeText.isEmpty
                              ? ''
                              : datetimeText.substring(0, 16),
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ],
                    ),
            ),

            SizedBox(height: 10.22),
          ],
        ),
      ),
      onTap: () {
        // print('clicked $titleText');
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.transparent, // 배경을 투명하게 해야 컨테이너 디자인이 보임
          builder: (context) => TripleFolderBottomSheet(contentID: contentID),
        );
      },
    );
  }
}
