import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

enum IconType { icon, image }

class AppBarDesign extends StatelessWidget {
  const AppBarDesign({
    super.key,
    required this.appbarText,
    required this.appbarIcon,
  });

  final String appbarText;
  final dynamic appbarIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: SizedBox(
            height: 34.43,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.mainPink,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: (appbarIcon is IconData)
                        ? Icon(
                            appbarIcon,
                            size: 25,
                          )
                        : Image.asset(
                            appbarIcon,
                            width: 25,
                            height: 25,
                          ),
                  ),
                ),

                SizedBox(width: 11),
                Text(
                  appbarText,
                  style: GoogleFonts.inter(fontSize: 24, color: AppColors.black, decoration: TextDecoration.none, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
