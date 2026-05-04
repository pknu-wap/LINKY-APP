import 'package:mysql_client/mysql_client.dart';

class DataService {
  // DB 설정 값들
  final String _host = '192.168.35.178';
  final int _port = 3306;
  final String _user = 'linky_user';
  final String _password = 'k08221004k!';
  final String _dbName = 'linky_db';

  // 공통 커넥션 생성 메서드
  Future<MySQLConnection> _getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: _host,
      port: _port,
      userName: _user,
      password: _password,
      databaseName: _dbName,
    );
    await conn.connect();
    return conn;
  }

  // 1. 데이터 저장 (Create)
  Future<void> insertLink({
    required String url,
    required String title,
    String? category,
    required bool isPrivate,
    DateTime? selectedDate,
  }) async {
    final conn = await _getConnection();
    try {
      await conn.execute(
        "INSERT INTO links (url, title, category, is_private, selected_date) "
        "VALUES (:url, :title, :category, :is_private, :date)",
        {
          "url": url,
          "title": title,
          "category": category ?? "미분류",
          "is_private": isPrivate ? 1 : 0,
          "date": selectedDate?.toIso8601String(),
        },
      );
      print("DB 저장 완료!");
    } finally {
      await conn.close();
    }
  }

  // 2. 데이터 조회 (Read)
  Future<List<Map<String, dynamic>>> fetchAllLinks() async {
    final conn = await _getConnection();
    try {
      final result = await conn.execute("SELECT * FROM links ORDER BY id DESC");
      List<Map<String, dynamic>> list = [];
      for (final row in result.rows) {
        list.add(row.assoc()); // 모든 컬럼을 Map 형태로 반환
      }
      return list;
    } finally {
      await conn.close();
    }
  }

  // 3. 특정 데이터 삭제 (Delete)
  Future<void> deleteLink(int id) async {
    final conn = await _getConnection();
    try {
      await conn.execute("SET SQL_SAFE_UPDATES = 0"); // ->id 뿐만아니라 title, url 등 다른 컬럼으로도 삭제 가능하도록 설정 변경
      await conn.execute("DELETE FROM links WHERE id = :id", {"id": id}); //->id를 이용해 행 삭제 -> 바꿀수 있음
      await conn.execute("SET SQL_SAFE_UPDATES = 1"); // ->id 뿐만아니라 title, url 등 다른 컬럼으로도 삭제 못하게 설정 변경
    } finally {
      await conn.close();
    }
  }
}