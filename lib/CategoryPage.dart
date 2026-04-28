import 'package:flutter/material.dart';
<<<<<<< HEAD

void main() {
  runApp(const Linky());
}

class Linky extends StatelessWidget {
  const Linky({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Linky', home: const CategoryPage());
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class FilterButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff3FD966) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("갯수", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 8),
            Text(
              "카테고리 제목",
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPageState extends State<CategoryPage> {
  int selectedIndex = 0;

  final List<List<TextEditingController>> titleControllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );
  final List<List<TextEditingController>> urlControllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );

  void _openEditSheet(int categoryIndex, int cardIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3FD966),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Category", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: titleControllers[categoryIndex][cardIndex],
                decoration: InputDecoration(
                  labelText: "제목 수정",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        titleControllers[categoryIndex][cardIndex].clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlControllers[categoryIndex][cardIndex],
                decoration: InputDecoration(
                  labelText: "URL 수정",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        urlControllers[categoryIndex][cardIndex].clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: "날짜 수정",
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: "카테고리 1",
                items: ["카테고리 1", "카테고리 2", "카테고리 3"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: "카테고리 수정",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget buildCategoryCards(int categoryIndex) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  color: Color(0xff3FD966),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleControllers[categoryIndex][index],
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: "  제목",
                            hintStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () => _openEditSheet(categoryIndex, index),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: urlControllers[categoryIndex][index],
                  decoration: InputDecoration(
                    labelText: "URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset('assets/images/FavoriteIcon.png'),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/CalendarIcon.png'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
=======
import 'package:std/pages/category_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/widgets/secretpage_guard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Linky',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭의 인덱스
  int _selectedIndex = 0;

  // 이동할 페이지 리스트
  final List<Widget> _pages = [
    const CategoryPage(),
    const SecretGuardWrapperPw(child: PrivatePage()), // 커스텀 패스워드 (현재 0000)
    const Center(child: Text('추가(+) 페이지', style: TextStyle(fontSize: 24))),
    const Center(child: Text('리마인더 페이지', style: TextStyle(fontSize: 24))),
    const Center(child: Text('설정 페이지', style: TextStyle(fontSize: 24))),
  ];

  // 탭 클릭 시 인덱스 변경 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
>>>>>>> ef5970785fd143cbdd2f0ccfcb114f5c5f394abd
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/CategoryIcon.png', height: 24),
            const SizedBox(width: 8),
            const Text("Category"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      setState(() {
                        selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: buildCategoryCards(selectedIndex)),
        ],
      ),
    );
  }
=======
      extendBody: true,
      // 현재 인덱스에 맞는 페이지 표시
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(19),
            topLeft: Radius.circular(19),
          ),
          border: Border.all(color: Color(0xffC4C4C4), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(19),
            topRight: Radius.circular(19),
          ),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color(0xff3fd966),
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                icon: _buildCommonItem(Icons.reorder, '카테고리', false),
                activeIcon: _buildCommonItem(Icons.reorder, '카테고리', true),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(
                  Icons.account_circle_outlined,
                  '나만보기',
                  false,
                ),
                activeIcon: _buildCommonItem(
                  Icons.account_circle_outlined,
                  '나만보기',
                  true,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  height: 45, // 조정 필요
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xff3fd966), size: 45),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(
                  Icons.calendar_today_rounded,
                  '리마인더',
                  false,
                ),
                activeIcon: _buildCommonItem(
                  Icons.calendar_today_rounded,
                  '리마인더',
                  true,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(
                  Icons.settings_outlined,
                  '설정',
                  false,
                ),
                activeIcon: _buildCommonItem(
                  Icons.settings_outlined,
                  '설정',
                  true,
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xff3fd966) : Colors.black,
          size: 25,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xff3fd966) : Colors.black,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
>>>>>>> ef5970785fd143cbdd2f0ccfcb114f5c5f394abd
}
