class UrlVerification {
  static const int maxUrlLength = 2048;

  String urlVerify(String rawUrl) {
    final input = rawUrl.trim();

    if (input.isEmpty) {
      throw const FormatException('URL을 입력해주세요');
    }
    if (input.length > maxUrlLength) {
      throw const FormatException('URL이 너무 길어요');
    }
    if (_hasControlCharacter(input) || RegExp(r'\s').hasMatch(input)) {
      throw const FormatException('URL에 사용할 수 없는 문자가 포함되어 있어요');
    }
    if (input.contains('\\') || input.startsWith('//')) {
      throw const FormatException('유효한 URL을 입력하세요');
    }
    String urlToParse = input;
    final lowerInput = input.toLowerCase();

    final hasAnyScheme = RegExp(r'^[a-z][a-z0-9+.-]*:').hasMatch(lowerInput);

    if (!hasAnyScheme) {
      urlToParse = 'https://$input';
    } else {
      final isHttpSchemeText =
          lowerInput.startsWith('http:') || lowerInput.startsWith('https:');

      final isValidHttpScheme =
          lowerInput.startsWith('http://') || lowerInput.startsWith('https://');

      if (isHttpSchemeText && !isValidHttpScheme) {
        throw const FormatException('유효한 URL 형식이 아니에요');
      }

      if (!isValidHttpScheme) {
        throw const FormatException('http 또는 https 주소만 사용할 수 있어요');
      }
    }

    if (urlToParse.length > maxUrlLength) {
      throw const FormatException('URL이 너무 길어요');
    }

    final uri = Uri.tryParse(urlToParse);
    if (uri == null) {
      throw const FormatException('유효한 URL을 입력하세요');
    }

    if (!(uri.isScheme('http') || uri.isScheme('https'))) {
      throw const FormatException('http 또는 https 주소만 사용할 수 있어요');
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      throw const FormatException('유효한 URL을 입력하세요');
    }
    if (uri.userInfo.isNotEmpty) {
      throw const FormatException('사용자 정보가 포함된 URL은 사용할 수 없어요');
    }
    if (uri.hasPort && !_isValidPort(uri.port)) {
      throw const FormatException('유효한 포트 번호가 아니에요');
    }

    if (!_isValidHost(uri.host)) {
      throw const FormatException('유효한 도메인을 입력하세요');
    }

    final result = uri.toString();
    if (result.length > maxUrlLength) {
      throw const FormatException('URL이 너무 길어요');
    }

    return result;
  }

  bool _hasControlCharacter(String value) {
    return RegExp(r'[\x00-\x1F\x7F]').hasMatch(value);
  }

  bool _isValidPort(int port) {
    return port > 0 && port <= 65535;
  }

  bool _isValidHost(String host) {
    final lowerHost = host.toLowerCase();

    if (lowerHost.isEmpty || lowerHost.length > 253) {
      return false;
    }
    if (lowerHost.contains('%')) {
      return false;
    }
    if (lowerHost == 'localhost' || lowerHost.endsWith('.localhost')) {
      return false;
    }
    if (lowerHost.startsWith('.') ||
        lowerHost.endsWith('.') ||
        lowerHost.contains('..')) {
      return false;
    }
    if (lowerHost.contains(':')) {
      return false;
    }
    if (_isStrictIPv4(lowerHost) || RegExp(r'^[0-9.]+$').hasMatch(lowerHost)) {
      return false;
    }

    return _isValidDomain(lowerHost);
  }

  bool _isValidDomain(String host) {
    if (!host.contains('.')) {
      return false;
    }

    final labels = host.split('.');
    for (final label in labels) {
      if (label.isEmpty || label.length > 63) {
        return false;
      }
      if (label.startsWith('-') || label.endsWith('-')) {
        return false;
      }
      if (!RegExp(r'^[a-z0-9-]+$').hasMatch(label)) {
        return false;
      }
    }

    final tld = labels.last;
    if (RegExp(r'^\d+$').hasMatch(tld) || tld.length < 2) {
      return false;
    }

    return true;
  }

  bool _isStrictIPv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4) {
      return false;
    }

    for (final part in parts) {
      if (part.isEmpty) {
        return false;
      }
      if (part.length > 1 && part.startsWith('0')) {
        return false;
      }
      if (!RegExp(r'^\d+$').hasMatch(part)) {
        return false;
      }

      final number = int.tryParse(part);
      if (number == null || number < 0 || number > 255) {
        return false;
      }
    }

    return true;
  }
}
