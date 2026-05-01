import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/widgets/dropdownbox_categorypage.dart';
import 'package:std/widgets/reminder_page_calender.dart';

class EditContentSheet extends StatefulWidget {
  const EditContentSheet({super.key});

  @override
  State<EditContentSheet> createState() => _EditContentSheetState();
}

class _EditContentSheetState extends State<EditContentSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: const Color(0xfff0f2f6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                Icons.close_rounded,
                Colors.red,
                () => Navigator.pop(context),
              ),
              _circleButton(
                Icons.check_rounded,
                Colors.green,
                () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: Colors.white,
            ),
            height: 101,
            width: screenSize.width * 0.86,
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "제목 입력",
                    hintMaxLines: 1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: IconButton(
                      icon: Image.asset('assets/images/DeleteIcon.png'),
                      onPressed: () {
                        _titleController.clear();
                      },
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                TextField(
                  controller: _urlController,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "URL 입력",
                    hintMaxLines: 1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: IconButton(
                      icon: Image.asset('assets/images/DeleteIcon.png'),
                      onPressed: () {
                        _urlController.clear();
                      },
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: screenSize.width * 0.86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: Colors.white,
            ),
            child: TextField(
              readOnly: true,
              controller: _dateController,
              style: GoogleFonts.inter(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "날짜 입력",
                hintMaxLines: 1,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: PopupMenuButton<void>(
                  icon: Image.asset(
                    'assets/images/CalendarIcon.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.calendar_today_outlined),
                  ),
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 4),
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<void>(
                      enabled: false,
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: 320,
                        height: 380,
                        child: CalenderWidget(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              String month = selectedDay.month
                                  .toString()
                                  .padLeft(2, '0');
                              String day = selectedDay.day.toString().padLeft(
                                2,
                                '0',
                              );
                              _dateController.text =
                                  "${selectedDay.year}.$month.$day";
                            });
                            Navigator.pop(context);
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: (day) => [],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: screenSize.width * 0.86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: Colors.white,
            ),
            child: TextField(
              readOnly: true,
              controller: _categoryController,
              style: GoogleFonts.inter(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "카테고리 수정",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xff7E7E7E),
                  ),
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 4),
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: CategoryDropdown(
                        // 변경된 위젯 이름
                        categories: const [
                          'All',
                          'Favorites',
                          'Category1',
                          'Category2',
                        ],
                        selectedCategory: _categoryController.text,
                        onCategorySelected: (category) {
                          setState(() {
                            _categoryController.text = category;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              textAlignVertical: TextAlignVertical.center,
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
          color: Colors.white,
          border: Border.all(width: 0.33, color: const Color(0xffC4C4C4)),
        ),
        child: Center(child: Icon(icon, color: color, size: 48)),
      ),
    );
  }
}
