import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/public_content_detail_sheet.dart';
import 'package:std/widgets/public_popup_menu_button.dart';
import 'package:std/constants.dart';

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
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      PopupButton(
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
        // print('clicked $titleText');
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // 배경을 투명하게 해야 컨테이너 디자인이 보임
          builder: (context) => TripleFolderBottomSheet(
            contentTitle: titleText,
            url: urlText,
          ),
        );
      },
    );
  }
}
