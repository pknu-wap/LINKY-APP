import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_messagebox.dart';
import 'package:std/widgets/public_popup_menu_button.dart';

class FolderModel {
  final int id;
  final int contentID;
  final Color color;

  FolderModel({
    required this.id,
    required this.contentID,
    required this.color,
  });
}

class TripleFolderBottomSheet extends StatefulWidget {
  final int contentID;
  final String currentCategory;

  const TripleFolderBottomSheet({
    super.key,
    required this.contentID,
    required this.currentCategory,
  });

  @override
  State<TripleFolderBottomSheet> createState() =>
      _TripleFolderBottomSheetState();
}

class _TripleFolderBottomSheetState extends State<TripleFolderBottomSheet> {
  final Duration _durationMove = const Duration(milliseconds: 100);
  final Duration _durationHide = const Duration(milliseconds: 700);
  final Duration _durationShow = const Duration(milliseconds: 300);

  final List<double> _slotTops = [0, 38, 92, 1000];
  final List<double> _slotSubWidths = [80, 33, 0, 0];
  final List<double> _slotOffsetXs = [27, 16, 0, 0];
  final List<double> _slotOpacities = [1.0, 1.0, 1.0, 0.0];

  late List<FolderModel> _folders;
  List<int> _currentSlots = [3, 3, 3];
  bool _isAnimating = false;

  late List<int> _targetIds;
  late int _nextLoadIndex;

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();

    _targetIds = appState.getContentIdsByCategory(widget.currentCategory);

    int currentIndex = _targetIds.indexOf(widget.contentID);
    if (currentIndex == -1) currentIndex = 0;
    int len = _targetIds.length;

    _folders = [
      FolderModel(
        id: 1,
        contentID: _targetIds[(currentIndex + 2) % len], // 맨 뒤 폴더
        color: AppColors.lightGrey,
      ),
      FolderModel(
        id: 2,
        contentID: _targetIds[(currentIndex + 1) % len], // 중간 폴더
        color: AppColors.outlineGrey,
      ),
      FolderModel(
        id: 3,
        contentID: _targetIds[currentIndex % len], // 맨 앞(현재 클릭한) 폴더
        color: AppColors.mainGreen,
      ),
    ];

    _nextLoadIndex = (currentIndex + 3) % len;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentSlots[0] = 0);
      Future.delayed(const Duration(milliseconds: 70), () {
        if (mounted) setState(() => _currentSlots[1] = 1);
      });
      Future.delayed(const Duration(milliseconds: 110), () {
        if (mounted) setState(() => _currentSlots[2] = 2);
      });
    });
  }

  void _cycleFolders() {
    if (_isAnimating) return;
    _isAnimating = true;

    setState(() {
      _currentSlots = [1, 2, 3];
    });

    Future.delayed(_durationHide - const Duration(milliseconds: 370), () {
      if (!mounted) return;

      setState(() {
        FolderModel outFolder = _folders.removeLast();

        FolderModel updatedFolder = FolderModel(
          id: outFolder.id,
          contentID: _targetIds[_nextLoadIndex],
          color: outFolder.color,
        );

        _folders.insert(0, updatedFolder);

        _nextLoadIndex = (_nextLoadIndex + 1) % _targetIds.length;

        _currentSlots = [0, 1, 2];
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double sheetHeight = screenSize.height - 100;

    return SizedBox(
      height: sheetHeight,
      width: screenSize.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: _folders.asMap().entries.map((entry) {
          int index = entry.key;
          FolderModel folder = entry.value;
          int slot = _currentSlots[index];

          Duration currentDuration;
          if (slot == 3) {
            currentDuration = _durationHide; // 사라질 때
          } else if (slot == 0) {
            currentDuration = _durationShow; // 뒤에서 다시 나타날 때
          } else {
            currentDuration = _durationMove; // 앞으로 전진할 때
          }

          return AnimatedPositioned(
            key: ValueKey(
              folder.id,
            ),
            duration: currentDuration,
            curve: Curves.easeOutCubic,
            top: _slotTops[slot],
            child: AnimatedOpacity(
              duration: currentDuration,
              opacity: _slotOpacities[slot],
              child: AnimatedContainer(
                duration: currentDuration,
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(_slotOffsetXs[slot], 0, 0),
                child: GestureDetector(
                  onTap: _cycleFolders,
                  child: ContentDetailSheet(
                    contentID: folder.contentID,
                    showContent: slot == 2, // 슬롯 2(맨 앞)일 때만 요약 내용 표시
                    subWidth: _slotSubWidths[slot],
                    color: folder.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ContentDetailSheet extends StatelessWidget {
  final Color color;
  final double subWidth;
  final bool showContent;
  final int contentID;
  final storage = const FlutterSecureStorage();

  const ContentDetailSheet({
    super.key,
    required this.color,
    required this.subWidth,
    required this.showContent,
    required this.contentID,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double folderWidth = screenSize.width - 28 - subWidth;
    double folderHeight = screenSize.height - 260;

    final targetItem = context.select<AppState, ContentItem?>(
      (state) => state.contentById(contentID),
    );

    String titleText = targetItem?.title ?? "찾을 수 없음";
    final urlText = targetItem?.url ?? "찾을 수 없음";
    late final String fixedUrlText;

    if (titleText.length >= 12) titleText = '${titleText.substring(0, 12)}...';
    fixedUrlText = (urlText.length >= 14)
        ? '${urlText.substring(0, 14)}...'
        : urlText;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: folderWidth,
        height: folderHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            CustomPaint(
              size: Size(folderWidth, folderHeight),
              painter: FolderShapePainter(backColor: color),
            ),

            if (showContent)
              Padding(
                padding: const EdgeInsets.only(top: 78, left: 26, right: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('제목', style: GoogleFonts.inter(fontSize: 20)),
                            const SizedBox(width: 20),
                            Text(
                              titleText,
                              style: GoogleFonts.inter(fontSize: 20),
                            ),
                          ],
                        ),
                        PopupButton(
                          contentID: contentID,
                          onActionDone: () async {
                            final kakaoId = await storage.read(key: 'kakaoId');
                            if (kakaoId == null) return;
                            Navigator.pop(context);
                            await context.read<AppState>().removeContent(
                              id: contentID,
                              kakaoId: kakaoId,
                            );
                          },
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, color: Colors.black),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('URL', style: GoogleFonts.inter(fontSize: 20)),
                            const SizedBox(width: 20),
                            Text(
                              fixedUrlText,
                              style: GoogleFonts.inter(fontSize: 20),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => DialogPopup(
                                title: '해당 링크로 이동하시겠어요?',
                                boxType: BoxType.warning,
                                onConfirm: () => print('링크 실행 완료'),
                                confirmText: '이동',
                              ),
                            );
                          },
                          child: Container(
                            width: 70,
                            height: 39,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                            ),
                            child: const Center(child: Text('이동')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(thickness: 1, color: Colors.black),
                    const SizedBox(height: 10),
                    Text('요약', style: GoogleFonts.inter(fontSize: 20)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FolderShapePainter extends CustomPainter {
  final Color backColor;
  const FolderShapePainter({required this.backColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backColor
      ..style = PaintingStyle.fill;
    final path = Path();
    final double radius = 25.0;
    final double tabWidth = size.width * 0.45;
    final double tabHeight = 40.0;

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(tabWidth - radius, 0);
    path.quadraticBezierTo(
      tabWidth,
      0,
      tabWidth + size.width * 0.13,
      radius + tabHeight / 1.5,
    );
    path.lineTo(size.width - radius, radius + tabHeight / 1.5);
    path.quadraticBezierTo(
      size.width,
      radius + tabHeight / 1.5,
      size.width,
      tabHeight + radius * 1.5,
    );
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
