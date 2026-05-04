import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_popup_menu_button.dart';
import 'package:std/constants.dart';

class RemindertaskWidget extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String url;
  final VoidCallback? onMorePressed; // 더보기 버튼 클릭 시 실행할 함수
  final OffsetTapCallback? onTapDown; // 팝업 메뉴 위치 계산을 위한 콜백
  final int contentID;

  const RemindertaskWidget({
    super.key,
    required this.backgroundColor,
    required this.contentID,
    this.onMorePressed,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final targetItem = context.select<AppState, ContentItem?>(
      (state) => state.contentById(contentID),
    );

    final titleText = targetItem?.title ?? "제목 없음";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: AppColors.black.withValues(alpha: 0.541),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              titleText,
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ),
          PopupButton(
            contentID: contentID,
            onActionDone: () =>
                context.read<AppState>().removeContent(contentID),
            context: context,
          ),

          const SizedBox(width: 8),

          if (hasUrl)
            PopupButton(
              titleValue: safeTitle,
              urlValue: url,
              onActionDone: () {
                print('삭제 버튼 클릭됨');
              },
              context: context,
            )
          else
            IconButton(
              onPressed: onMorePressed,
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.black,
              ),
            ),
        ],
      ),
    );
  }
}

// 메뉴 위치를 잡기 위한 커스텀 콜백 타입 정의
typedef OffsetTapCallback = void Function(TapDownDetails details);
