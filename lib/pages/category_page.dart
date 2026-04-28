import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/select_category.dart';

const mainGreen = Color(0xff3fd966);

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 41),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: 157,
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
                        'Category',
                        style: GoogleFonts.inter(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 13),

              _categoryScroll(),

              SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _categoryScroll() {
  List<String> categories = ['Only Me', '두번째', '세번쨰', '다스엇번째'];
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: categories
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: SelectCategory(categoryCount: '개수', categoryTitle: m),
            ),
          )
          .toList(),
    ),
  );
}
