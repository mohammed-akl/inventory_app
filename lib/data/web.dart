// lib/data/web.dart
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'inventory_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    
    // In a real application, you'd handle MissingBrowserFeaturesException etc.
    return result.resolvedExecutor;
  }));
}
