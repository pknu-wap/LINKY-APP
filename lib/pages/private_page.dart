import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/contents_box.dart';

const mainGreen = Color(0xff3fd966);

class PrivatePage extends StatelessWidget {
  const PrivatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFf0f2f6),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 41),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: 145,
                  height: 34.43,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 34.43,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffffbff3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.account_circle,
                            size: 25,
                          ),
                        ),
                      ),
                      Text(
                        'Only Me',
                        style: GoogleFonts.inter(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 13),
              Container(
                width: 120,
                decoration: BoxDecoration(
                  color: mainGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment(0, 0),
                      margin: EdgeInsets.only(
                        top: 4,
                        right: 5,
                        left: 4,
                        bottom: 4,
                      ),
                      height: 27,
                      width: 39,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: SizedBox(
                        width: 30,
                        height: 19,
                        child: Text(
                          '갯수',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 63,
                      height: 19,
                      child: Text(
                        'Only me',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 13),
              ContentsBox(
                titleText: 'Title',
                urlText: 'URL',
              ),
              SizedBox(height: 13),
              ContentsBox(titleText: 'Title2', urlText: 'URL2'),
              SizedBox(height: 13),
              ContentsBox(titleText: 'Title3', urlText: 'URL3'),
              SizedBox(height: 13),
              ContentsBox(titleText: '제목4', urlText: 'URL4'),
              SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }
}
