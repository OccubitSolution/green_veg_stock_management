/// Database Provider
///
/// Manages PostgreSQL connection to Neon database
import 'package:postgres/postgres.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider instance = DatabaseProvider._();

  Connection? _connection;
  bool _isInitialized = false;

  bool get isConnected => _connection != null && _isInitialized;

  /// Get the database connection (initializes if needed)
  Future<Connection> get connection async {
    if (!isConnected) {
      await initialize();
    }
    return _connection!;
  }

  /// Initialize database connection
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final endpoint = Endpoint(
        host: AppConstants.dbHost,
        port: AppConstants.dbPort,
        database: AppConstants.dbName,
        username: AppConstants.dbUser,
        password: AppConstants.dbPassword,
      );

      _connection = await Connection.open(
        endpoint,
        settings: ConnectionSettings(sslMode: SslMode.require),
      );

      _isInitialized = true;
      print('✅ Database connected successfully');
    } catch (e) {
      print('❌ Database connection failed: $e');
      rethrow;
    }
  }

  /// Execute a query and return results
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!isConnected) {
      await initialize();
    }

    try {
      final result = await _connection!.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ Query failed: $e');
      rethrow;
    }
  }

  /// Execute insert and return the inserted row
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data, {
    String returning = '*',
  }) async {
    final columns = data.keys.join(', ');
    final values = data.keys.map((k) => '@$k').join(', ');

    final sql =
        '''
      INSERT INTO $table ($columns)
      VALUES ($values)
      RETURNING $returning
    ''';

    final result = await query(sql, parameters: data);
    return result.isNotEmpty ? result.first : null;
  }

  /// Execute update and return affected rows
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    Map<String, dynamic>? whereParams,
    String returning = '*',
  }) async {
    final setClause = data.keys.map((k) => '$k = @$k').join(', ');

    final sql =
        '''
      UPDATE $table
      SET $setClause, updated_at = NOW()
      WHERE $where
      RETURNING $returning
    ''';

    final params = {...data, ...?whereParams};
    return await query(sql, parameters: params);
  }

  /// Execute soft delete (set is_active = false)
  Future<bool> softDelete(
    String table, {
    required String where,
    Map<String, dynamic>? whereParams,
  }) async {
    final sql =
        '''
      UPDATE $table
      SET is_active = false, updated_at = NOW()
      WHERE $where
    ''';

    await query(sql, parameters: whereParams);
    return true;
  }

  /// Execute hard delete
  Future<bool> delete(
    String table, {
    required String where,
    Map<String, dynamic>? whereParams,
  }) async {
    final sql = 'DELETE FROM $table WHERE $where';
    await query(sql, parameters: whereParams);
    return true;
  }

  /// Close connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
    _isInitialized = false;
  }
}
