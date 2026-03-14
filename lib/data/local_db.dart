import 'package:drift/drift.dart';

import 'connection.dart' as impl;

part 'local_db.g.dart';

@DataClassName('Vendor')
class Vendors extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get name => text()();
  TextColumn get contactInfo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get sku => text().nullable().customConstraint('UNIQUE')();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductPrice')
class ProductPrices extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get productId => text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get vendorId => text().references(Vendors, #id, onDelete: KeyAction.cascade)();
  RealColumn get price => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Vendors, Products, ProductPrices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 1;
}
