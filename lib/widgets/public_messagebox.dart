import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

enum BoxType { alert, warning }

class DialogPopup extends StatelessWidget {
  final String title, confirmText;
  final bool Function() onConfirm;
  final BoxType boxType;
  final Widget? content;

  const DialogPopup({
    super.key,
    required this.title,
    required this.onConfirm,
    required this.confirmText,
    required this.boxType,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      child: Container(
        width: 326,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 20),
                  ),
                  if (content != null) ...[
                    const SizedBox(height: 12),
                    content!,
                  ],
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 0.38,
              color: AppColors.black,
            ),
            if (boxType == BoxType.warning)
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          color: Colors.transparent,
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
                    ),
                    const VerticalDivider(
                      thickness: 0.38,
                      width: 1,
                      color: AppColors.black,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final shouldClose = onConfirm();
                          if (shouldClose) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
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
                    ),
                  ],
                ),
              ),
            if (boxType == BoxType.alert)
              SizedBox(
                height: 52,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.transparent,
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
              ),
          ],
        ),
      ),
    );
  }
}
