import 'package:flutter/material.dart';
import 'package:std/constants.dart';

class EditContentSheet extends StatelessWidget {
  const EditContentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: AppColors.popupBackGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                Icons.close_rounded,
                AppColors.mainRed,
                () => Navigator.pop(context),
              ),
              _circleButton(
                Icons.check_rounded,
                AppColors.mainGreen,
                () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: AppColors.white,
            ),
            height: 101,
            width: screenSize.width * 0.86,
            child: Column(
              children: [Text('제목 수정')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(width: 0.33, color: AppColors.outlineGrey),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 48,
          ),
        ),
      ),
    );
  }
}
