import 'package:mysql_client/mysql_client.dart';

/// Singleton class for managing a single MySQL database connection.
///
/// Ensures only one connection is active at a time and reuses it when possible.
class Database {
  /// Singleton instance
  static final Database _instance = Database._internal();

  /// Factory constructor to get the singleton instance
  factory Database() => _instance;

  /// Private constructor to enforce singleton pattern
  Database._internal();

  MySQLConnection? _connection;

  /// Opens a new database connection or reuses existing one if still active.
  ///
  /// Returns an active [MySQLConnection] object
  Future<MySQLConnection> openConnection() async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    _connection = await MySQLConnection.createConnection(
      host: 'localhost',
      port: 3306,
      userName: 'root',
      password: 'root',
      databaseName: 'contacts_db',
    );

    await _connection!.connect();
    return _connection!;
  }

  /// Closes the current database connection if it's active.
  ///
  /// Sets internal reference to null after closing.
  Future<void> closeConnection() async {
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
      _connection = null;
    }
  }
}
