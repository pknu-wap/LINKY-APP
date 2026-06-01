import 'package:local_auth/local_auth.dart';
import 'package:std/main.dart';

class LocalAuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> checkAvailable() async {
    // isDeviceSupported()는 기기에 PIN, 패턴, 비밀번호 또는 생체 인식이 등록되어 있는지 확인합니다.
    final isSupported = await _auth.isDeviceSupported();
    return isSupported;
  }

  static Future<bool> authenticate() async {
    try {
      bool isAvailable = await checkAvailable();
      if (isAvailable) {
        return await _auth.authenticate(
          // localizedReason: '시크릿 모드를 해제하려면 인증이 필요합니다.',
          localizedReason: ' ',
          persistAcrossBackgrounding: true,
          biometricOnly: false,
        );
      } else {
        return true;
      }
    }
    // on LocalAuthException catch (e) {
    //   print("🚨 LocalAuthException 발생! 코드: ${e.code.name}");
    //   if (e.code.name == 'notEnrolled') print("기기에 등록된 생체 정보가 없습니다.");
    //   if (e.code.name == 'noCredentialsSet') print('기기에 등록된 보안 설정이 없습니다.');
    //   return false;
    // }
    catch (e) {
      print("예상치 못한 에러 발생! 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      return false;
    }
  }
}

class PwAuthService {
  static bool authenticate(String inputPassword) {
    if (inputPassword == customPw) {
      return true;
    } else {
      return false;
    }
  }
}
