import 'package:mysql_client/mysql_client.dart';

class DataService {
  // DB 설정 값들
  final String _host = '3.34.52.216';
  final int _port = 3306;
  final String _user = 'root';
  final String _password = 'remnant260()!';
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
  Future<int> insertLink({
    required String kakaoId,
    required String url,
    required String title,
    String? category,
    required bool isPrivate,
    DateTime? selectedDate,
  }) async {
    final conn = await _getConnection();
    try {
      await conn.execute(
        "INSERT INTO link (kakao_id, url, title, category, is_private, selected_date) "
        "VALUES (:kakao_id, :url, :title, :category, :is_private, :date)",
        {
          "kakao_id": kakaoId,
          "url": url,
          "title": title,
          "category": category ?? "미분류",
          "is_private": isPrivate ? 1 : 0,
          "date": selectedDate?.toIso8601String(),
        },
      );
      final idResult = await conn.execute("SELECT LAST_INSERT_ID() AS id");
      final newId = int.parse(idResult.rows.first.assoc()['id'].toString());

      print("DB 저장 완료!");
      return newId;
    } finally {
      await conn.close();
    }
  }

  // 2. 데이터 조회 (Read)
  Future<List<Map<String, dynamic>>> fetchLinksByKakaoId(String kakaoId) async {
    final conn = await _getConnection();
    try {
      final result = await conn.execute(
        "SELECT * FROM link WHERE kakao_id = :kakao_id ORDER BY id DESC",
        {"kakao_id": kakaoId},
      );

      return result.rows.map((row) => row.assoc()).toList();
    } finally {
      await conn.close();
    }
  }

  // 3. 특정 데이터 삭제 (Delete)
  Future<void> deleteLink({
    required int id,
    required String kakaoId,
  }) async {
    print("DB 삭제 시도 id: $id, kakaoId: $kakaoId");

    final conn = await _getConnection();
    try {
      //await conn.execute("SET SQL_SAFE_UPDATES = 0"); // ->id 뿐만아니라 title, url 등 다른 컬럼으로도 삭제 가능하도록 설정 변경
      await conn.execute("DELETE FROM link WHERE id = :id AND kakao_id = :kakao_id", {
        "id": id,
        "kakao_id": kakaoId,
      }); //->id를 이용해 행 삭제 -> 바꿀수 있음
      print("DB 삭제 요청 완료");
      //await conn.execute("SET SQL_SAFE_UPDATES = 1"); // ->id 뿐만아니라 title, url 등 다른 컬럼으로도 삭제 못하게 설정 변경
    } finally {
      await conn.close();
    }
  }
}
