import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:sqflite/sqflite.dart';

class ChatSessionEntity {
  final String id; // numeric string per user: 1,2,3...
  final String userId;
  final int createdAt;
  final int updatedAt;
  final String? title;

  ChatSessionEntity({required this.id, required this.userId, required this.createdAt, required this.updatedAt, this.title});

  Map<String, Object?> toMap() => {
        'Id': id,
        'UserId': userId,
        'CreatedAt': createdAt,
        'UpdatedAt': updatedAt,
        'Title': title,
      };

  static ChatSessionEntity fromMap(Map<String, Object?> m) => ChatSessionEntity(
        id: m['Id'] as String,
        userId: m['UserId'] as String,
        createdAt: m['CreatedAt'] as int,
        updatedAt: m['UpdatedAt'] as int,
        title: m['Title'] as String?,
      );
}

class ChatMessageEntity {
  final int? id;
  final String sessionId;
  final bool isUser;
  final String content;
  final int timestamp;

  ChatMessageEntity({this.id, required this.sessionId, required this.isUser, required this.content, required this.timestamp});

  Map<String, Object?> toMap() => {
        if (id != null) 'Id': id,
        'SessionId': sessionId,
        'IsUser': isUser ? 1 : 0,
        'Content': content,
        'Timestamp': timestamp,
      };

  static ChatMessageEntity fromMap(Map<String, Object?> m) => ChatMessageEntity(
        id: m['Id'] as int?,
        sessionId: m['SessionId'] as String,
        isUser: (m['IsUser'] as int) == 1,
        content: m['Content'] as String,
        timestamp: m['Timestamp'] as int,
      );
}

class ChatRepository {
  Future<Database> get _db async => await DB.instance.database;

  // Returns latest session for user; if none, creates first (Id='1')
  Future<ChatSessionEntity> getOrCreateSession(String userId, {String? sessionId}) async {
    final db = await _db;
    final rows = await db.query(
      'chat_session',
      where: 'UserId = ?',
      whereArgs: [userId],
      orderBy: 'UpdatedAt DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return ChatSessionEntity.fromMap(rows.first);
    }
    return await createNewSession(userId);
  }

  // Creates a new session with incremental numeric Id per user (as TEXT)
  Future<ChatSessionEntity> createNewSession(String userId, {String? title}) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final nextId = await _nextSessionIdForUser(userId);
    final session = ChatSessionEntity(
      id: nextId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      title: title ?? 'Sessão $nextId',
    );
    await db.insert('chat_session', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return session;
  }

  Future<String> _nextSessionIdForUser(String userId) async {
    final db = await _db;
    final res = await db.rawQuery('SELECT COUNT(*) as cnt FROM chat_session WHERE UserId = ?', [userId]);
    final cnt = (res.first['cnt'] as int?) ?? 0;
    return (cnt + 1).toString();
  }

  Future<List<ChatMessageEntity>> getMessages(String sessionId, {int? limit}) async {
    final db = await _db;
    final rows = await db.query(
      'chat_message',
      where: 'SessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'Timestamp ASC',
      limit: limit,
    );
    return rows.map((e) => ChatMessageEntity.fromMap(e)).toList();
  }

  Future<int> saveMessage(ChatMessageEntity msg) async {
    final db = await _db;
    final id = await db.insert('chat_message', msg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await db.update(
      'chat_session',
      {'UpdatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'Id = ?',
      whereArgs: [msg.sessionId],
    );
    return id;
  }

  Future<void> clearSession(String sessionId) async {
    final db = await _db;
    await db.delete('chat_message', where: 'SessionId = ?', whereArgs: [sessionId]);
    await db.delete('chat_session', where: 'Id = ?', whereArgs: [sessionId]);
  }
}
