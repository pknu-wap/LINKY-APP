import 'package:flutter/material.dart';
import 'package:std/constants.dart';
import 'package:std/widgets/public_edit_content_sheet.dart';
import 'package:std/widgets/public_messagebox.dart';

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.contentID,
    required this.onActionDone,
    required this.context,
    this.deleteTitle = '해당 링크를 삭제하시겠어요?',
  });

  final int contentID;
  final VoidCallback onActionDone;
  final BuildContext context;
  final String deleteTitle;

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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.transparent, // 배경을 투명하게 해야 컨테이너 디자인이 보임
            builder: (context) => EditContentSheet(
              contentID: contentID,
            ),
          );
        } else if (value == 'delete') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return DialogPopup(
                title: deleteTitle,
                onConfirm: () {
                  onActionDone();
                  return true;
                },
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
        const PopupMenuDivider(height: 1),
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
      child: SizedBox.square(
        dimension: 28,
        child: Center(
          child: Icon(
            Icons.more_vert,
            size: 24,
          ),
        ),
      ),
    );
  }
}
