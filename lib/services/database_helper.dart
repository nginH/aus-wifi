import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/credential.dart';
import '../models/login_log.dart';

import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final directory = await getApplicationSupportDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      path = join(directory.path, 'aus_wifi.db');
    } else {
      path = join(await getDatabasesPath(), 'aus_wifi.db');
    }
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE credentials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        username TEXT,
        status TEXT,
        message TEXT
      )
    ''');

    final List<Map<String, String>> initialCreds = [
      {"username": "testdummy", "password": "testdummy"},
    ];

    for (var cred in initialCreds) {
      await db.insert('credentials', {
        'username': cred['username'],
        'password': cred['password'],
        'isActive': 1,
      });
    }
  }

  // Credential CRUD
  Future<int> insertCredential(Credential credential) async {
    Database db = await database;
    return await db.insert('credentials', credential.toMap());
  }

  Future<List<Credential>> getCredentials() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('credentials');
    return maps.map((e) => Credential.fromMap(e)).toList();
  }

  Future<int> updateCredential(Credential credential) async {
    Database db = await database;
    return await db.update(
      'credentials',
      credential.toMap(),
      where: 'id = ?',
      whereArgs: [credential.id],
    );
  }

  Future<int> deleteCredential(int id) async {
    Database db = await database;
    return await db.delete('credentials', where: 'id = ?', whereArgs: [id]);
  }

  // Logs CRUD
  Future<int> insertLog(LoginLog log) async {
    Database db = await database;
    return await db.insert('logs', log.toMap());
  }

  Future<List<LoginLog>> getLogs({int limit = 50}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((e) => LoginLog.fromMap(e)).toList();
  }

  Future<void> clearLogs() async {
    Database db = await database;
    await db.delete('logs');
  }
}
