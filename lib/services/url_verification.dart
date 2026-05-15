class UrlVerification {
  void urlVerify(String url) {
    if (url.isEmpty) {
      throw FormatException('URL을 입력해주세요');
    }

    if (RegExp(r'\s').hasMatch(url)) {
      throw FormatException('URL에는 공백이 포함될 수 없어요');
    }

    final blockedScheme = RegExp(
      r'^(javascript|data|file|ftp|mailto):',
      caseSensitive: false,
    );

    if (blockedScheme.hasMatch(url)) {
      throw FormatException('지원하지 않는 주소 형식이에요');
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        uri.scheme != 'http' && uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw FormatException('유효한 URL을 입력하세요');
    }
  }
}
