import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/alert.dart';
import 'package:std/widgets/edit_content_sheet.dart';

const mainGreen = Color(0xff3fd966);

class ContentsBox extends StatelessWidget {
  final String titleText, urlText;
  final VoidCallback onActionDone;

  const ContentsBox({
    super.key,
    required this.titleText,
    required this.urlText,
    required this.onActionDone,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 375,
        height: 138,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: BoxBorder.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
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
                  color: mainGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 21, right: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titleText,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      _popupMenu(context),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                height: 16,
                child: Text(
                  urlText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Color(0xff7E7E7E),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 12.78,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 33.21),
              child: Icon(Icons.calendar_today_outlined, size: 24),
            ),

            SizedBox(height: 10.22),
          ],
        ),
      ),
      onTap: () {
        print('clicked $titleText');
      },
    );
  }

  Widget _popupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(-10, 40),
      menuPadding: EdgeInsets.symmetric(vertical: 3),
      // 메뉴 전체의 최대 너비 제한
      constraints: const BoxConstraints(
        maxWidth: 100,
      ),

      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert),

      onSelected: (value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return DialogPopup(
                title: '해당 링크를 수정하시겠어요?',
                onConfirm: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // 키보드 대응 및 높이 조절을 위해 필수
                    backgroundColor:
                        Colors.transparent, // 배경을 투명하게 해야 컨테이너 디자인이 보임
                    builder: (context) => const EditContentSheet(),
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
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
