String password = '0000';

class AuthWithPW {
  static bool authenticate(String inputPassword) {
    if (inputPassword == password) {
      return true;
    } else {
      return false;
    }
  }
}
