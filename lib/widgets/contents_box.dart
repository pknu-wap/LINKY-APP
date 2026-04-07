import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const mainGreen = Color(0xff3fd966);

class ContentsBox extends StatelessWidget {
  final String titleText, urlText;

  const ContentsBox({
    super.key,
    required this.titleText,
    required this.urlText,
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
                  padding: const EdgeInsets.only(left: 21, right: 16.2),
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
                      InkWell(
                        child: Icon(Icons.more_vert),
                        onTap: () => print('menu clicked'),
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
              child: InkWell(
                child: Icon(Icons.calendar_today_outlined, size: 24),
                onTap: () => print('calendar clicked'),
              ),
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
}
