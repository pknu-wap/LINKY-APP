import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/public_contents_box.dart';
import 'package:std/widgets/public_select_category.dart';

List<String> contentsTitle = [];
List<String> contentsURL = [];

class PrivatePage extends StatefulWidget {
  const PrivatePage({super.key});

  @override
  State<PrivatePage> createState() => _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  void _updatePage(int listIndex) {
    setState(() {
      contentsTitle.remove(contentsTitle[listIndex]);
      contentsURL.remove(contentsURL[listIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            SelectCategory(
              categoryCount: contentsTitle.length.toString(),
              categoryTitle: 'Only me',
            ),
            SizedBox(height: 13),
            Expanded(child: _contentsScroll()),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _contentsScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: List.generate(contentsTitle.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: ContentsBox(
              titleText: contentsTitle[index],
              urlText: contentsURL[index],
              onActionDone: () => _updatePage(index),
            ),
          );
        }),
      ),
    );
  }
}
