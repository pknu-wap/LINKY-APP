import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:std/main.dart';
import 'package:std/widgets/alert.dart';

class AuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final isAvailable =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!isAvailable) {
        print('인증 하드웨어를 사용할 수 없는 기기입니다.');
        return false;
      }

      return await _auth.authenticate(
        // localizedReason: '시크릿 모드를 해제하려면 인증이 필요합니다.',
        localizedReason: ' ',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
    } on LocalAuthException catch (e) {
      print("🚨 LocalAuthException 발생! 코드: ${e.code.name}");

      if (e.code.name == 'notEnrolled' || e.code.name == 'noCredentialsSet') {
        print("기기에 등록된 생체 정보나 보안 설정이 없습니다.");

        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            builder: (context) => const AlertDialogPage(),
          );
        }
        return false;
      }
      return false;
    } catch (e) {
      print("예상치 못한 에러 발생! 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      return false;
    }
  }
}
