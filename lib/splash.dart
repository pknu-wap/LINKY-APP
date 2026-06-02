import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:std/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _turns;
  late final Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 0.74,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.74),
        weight: 25,
      ),
    ]).animate(_controller);

    _turns = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.25,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.25,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 25,
      ),
    ]).animate(_controller);

    _textReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 0.96, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: _turns.value * 2 * math.pi,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: SizedBox(
                      width: 87,
                      height: 105,
                      child: Image.asset(
                        'assets/images/linky_logo.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _textReveal.value,
                    child: Opacity(
                      opacity: _textReveal.value,
                      child: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Text(
                          'LINKY',
                          style: GoogleFonts.lalezar(
                            fontSize: 60,
                            fontWeight: FontWeight.w300,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
