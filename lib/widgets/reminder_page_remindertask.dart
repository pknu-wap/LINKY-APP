import 'package:flutter/material.dart';
import 'package:std/widgets/public_popup_menu_button.dart';
import 'package:std/constants.dart';

class RemindertaskWidget extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String url;
  final VoidCallback? onMorePressed; // 더보기 버튼 클릭 시 실행할 함수
  final OffsetTapCallback? onTapDown; // 팝업 메뉴 위치 계산을 위한 콜백

  const RemindertaskWidget({
    super.key,
    required this.backgroundColor,
    required this.title,
    this.url = '',
    this.onMorePressed,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.isEmpty ? '제목 없음' : title;
    final hasUrl = url.isNotEmpty;

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

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              safeTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
