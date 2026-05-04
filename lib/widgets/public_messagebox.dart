import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

enum BoxType { alert, warning }

class DialogPopup extends StatelessWidget {
  final String title, confirmText;
  final VoidCallback onConfirm;
  final BoxType boxType;

  const DialogPopup({
    super.key,
    required this.title,
    required this.onConfirm,
    required this.confirmText,
    required this.boxType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      child: Container(
        width: 326,
        height: 141,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  title,
                  style: GoogleFonts.inter(fontSize: 20),
                ),
              ),
            ),

            const Divider(
              height: 1,
              thickness: 0.38,
              color: AppColors.black,
            ),

            if (boxType == BoxType.warning)
              Expanded(
                child: Center(
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Text(
                              '취소',
                              style: GoogleFonts.inter(
                                color: AppColors.mainBlue,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        thickness: 0.38,
                        width: 1,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          child: Center(
                            child: Text(
                              confirmText,
                              style: GoogleFonts.inter(
                                color: AppColors.mainRed,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (boxType == BoxType.alert)
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Text(
                      '확인',
                      style: GoogleFonts.inter(
                        color: AppColors.mainBlue,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
