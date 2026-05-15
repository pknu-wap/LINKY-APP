import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_edit_content_sheet.dart';
import 'package:std/widgets/public_messagebox.dart';

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.contentID,
    required this.onActionDone,
    required this.context,
  });

  final int contentID;
  final VoidCallback onActionDone;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      popUpAnimationStyle: AnimationStyle.noAnimation,
      offset: const Offset(-5, 30),
      menuPadding: EdgeInsets.symmetric(vertical: 3),
      // 메뉴 전체의 최대 너비 제한
      constraints: const BoxConstraints(
        maxWidth: 100,
      ),

      padding: EdgeInsets.zero,

      onSelected: (value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return DialogPopup(
                title: '해당 링크를 수정하시겠어요?',
                boxType: BoxType.warning,
                onConfirm: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor:
                        AppColors.transparent, // 배경을 투명하게 해야 컨테이너 디자인이 보임
                    builder: (context) => EditContentSheet(
                      contentID: contentID,
                    ),
                  );
                },
                confirmText: '수정',
              );
            },
          );
        } else if (value == 'delete') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return DialogPopup(
                title: '해당 링크를 삭제하시겠어요?',
                onConfirm: onActionDone,
                confirmText: '삭제',
                boxType: BoxType.warning,
              );
            },
          );
        }
      },

      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          height: 25,

          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            children: const [
              Icon(Icons.chevron_right, size: 16),
              SizedBox(width: 8),
              Text('수정', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1), // 구분선 높이
        PopupMenuItem<String>(
          value: 'delete',
          height: 25,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: const [
              Icon(Icons.chevron_right, size: 16),
              SizedBox(width: 8),
              Text('삭제', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
      color: AppColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(width: 24, height: 24, child: Icon(Icons.more_vert)),
    );
  }
}
