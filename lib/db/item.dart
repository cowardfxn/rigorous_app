import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:json_annotation/json_annotation.dart';

// database table and column names
final String tableNm = 'items';
final List<String> colNms = [
  'id',
  'name',
  'amount',
  'unit',
  'price',
  'total',
  'isWarehouse',
  'updatedAt',
  'updatedBy',
  'createdAt',
  'createdBy'
];

@JsonSerializable(nullable: false)
class ItemObject {
  ItemObject({
    this.id,
    this.name = '',
    this.amount = 0,
    this.unit = '',
    this.price = 0,
    this.total = 0,
    this.isWarehouse = 0,
    this.updatedAt,
    this.updatedBy,
    this.createdAt,
    this.createdBy,
  }) {
    this.total = this.amount * this.price;
  }

  int id;
  String name;
  int amount;
  String unit;
  double price;
  double total;
  int isWarehouse;
  String updatedAt;
  String updatedBy;
  String createdAt;
  String createdBy;

  void resetTotal() {
    this.total = this.amount * this.price;
  }

  @override
  String toString() {
    return "ItemObject {id: $id, name: '$name', amount: $amount, unit: '$unit',"
        " price: $price, total: $total, isWarehouse: $isWarehouse,"
        " updatedAt: $updatedAt, updatedBy: $updatedBy,"
        " createdAt: $createdAt, createdBy : $createdBy"
        "}";
  }

  factory ItemObject.fromJson(Map<String, dynamic> json) =>
      _$ItemObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ItemObjectToJson(this);
}

ItemObject _$ItemObjectFromJson(Map<String, dynamic> json) {
  return ItemObject(
    id: json['id'] as int,
    name: json['name'] as String,
    amount: json['amount'] as int,
    unit: json['unit'] as String,
    price: json['price'] as double,
    total: json['total'] as double,
    isWarehouse: json['isWarehouse'] as int,
    updatedAt: json['updatedAt'] as String,
    updatedBy: json['updatedBy'] as String,
    createdAt: json['createdAt'] as String,
    createdBy: json['createdBy'] as String,
  );
}

Map<String, dynamic> _$ItemObjectToJson(ItemObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'unit': instance.unit,
      'price': instance.price,
      'total': instance.total,
      'isWarehouse': instance.isWarehouse,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
    };

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "rigorous_app.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // await deleteDatabase(path);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableNm (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                amount INTEGER,
                unit TEXT,
                price DOUBLE,
                total DOUBLE,
                isWarehouse INTEGER,
                updatedAt TEXT,
                updatedBy TEXT,
                createdAt TEXT,
                createdBy TEXT
              )
              ''');
  }

  // Database helper methods:

  Future<int> insertItem(ItemObject item) async {
    Database db = await database;
    if (item.createdAt == null) {
      item.updatedAt = DateTime.now().toString();
      item.createdAt = DateTime.now().toString();
    }
    int id = await db.insert(tableNm, item.toJson());
    return id;
  }

  Future<ItemObject> queryItem(String name) async {
    Database db = await database;
    List<Map> maps = await db
        .query(tableNm, columns: colNms, where: 'name = ?', whereArgs: [name]);
    if (maps.length > 0) {
      return ItemObject.fromJson(maps.first);
    }
  }

  Future<List<Map>> queryItemByName(String name) async {
    Database db = await database;
    List<Map> maps = await db.query(
      tableNm,
      columns: colNms,
      where: "name like '%$name%'",
    );
    return maps;
  }

  Future<List<Map>> queryAllItems() async {
    Database db = await database;
    List<Map> maps =
        await db.query(tableNm, columns: colNms, orderBy: "updatedAt");
    return maps;
  }

  Future<int> deleteItem(String name) async {
    Database db = await database;
    return await db.delete(tableNm, where: 'name = ?', whereArgs: [name]);
  }

  Future<int> clearDB() async {
    Database db = await database;
    return await db.delete(tableNm);
  }

  Future<int> updateItem(ItemObject item) async {
    Database db = await database;
    item.updatedAt = DateTime.now().toString();
    return await db
        .update(tableNm, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future close() async {
    Database db = await database;
    await db.close();
  }
}

Future<void> dummy() async {
  DatabaseHelper db = DatabaseHelper.instance;
  for (var d in dummyData) {
    ItemObject rec = ItemObject.fromJson(d);
    await db.insertItem(rec);
  }
}

const dummyData = [
  {
    "name": "清单",
    "amount": 25,
    "unit": "条",
    "price": 31.41,
    "total": 785.25,
    "isWarehouse": 1,
    "updatedAt": "2020-01-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-01-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "所",
    "amount": 3,
    "unit": "根",
    "price": 65.97,
    "total": 197.91,
    "isWarehouse": 1,
    "updatedAt": "2020-02-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-02-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "列",
    "amount": 91,
    "unit": "枝",
    "price": 78.41,
    "total": 7135.31,
    "isWarehouse": 0,
    "updatedAt": "2020-03-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-03-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "对象",
    "amount": 47,
    "unit": "张",
    "price": 7.39,
    "total": 347.33,
    "isWarehouse": 1,
    "updatedAt": "2020-04-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-04-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "包括",
    "amount": 57,
    "unit": "颗",
    "price": 54.92,
    "total": 3130.44,
    "isWarehouse": 0,
    "updatedAt": "2020-05-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-05-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "伊朗",
    "amount": 49,
    "unit": "粒",
    "price": 1.27,
    "total": 62.23,
    "isWarehouse": 0,
    "updatedAt": "2020-06-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-06-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "导弹",
    "amount": 64,
    "unit": "个",
    "price": 53.5,
    "total": 3424.0,
    "isWarehouse": 0,
    "updatedAt": "2020-07-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-07-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "项目",
    "amount": 30,
    "unit": "双",
    "price": 11.58,
    "total": 347.4,
    "isWarehouse": 0,
    "updatedAt": "2020-08-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-08-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "采购",
    "amount": 91,
    "unit": "对",
    "price": 23.58,
    "total": 2145.78,
    "isWarehouse": 1,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-09-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "网络",
    "amount": 71,
    "unit": "斗",
    "price": 28.75,
    "total": 2041.25,
    "isWarehouse": 0,
    "updatedAt": "2020-10-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-10-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "成员",
    "amount": 21,
    "unit": "公斤",
    "price": 7.93,
    "total": 166.53,
    "isWarehouse": 1,
    "updatedAt": "2020-11-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-11-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "以及",
    "amount": 76,
    "unit": "公里",
    "price": 28.99,
    "total": 2203.24,
    "isWarehouse": 1,
    "updatedAt": "2020-12-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "项目",
    "amount": 62,
    "unit": "亩",
    "price": 98.98,
    "total": 6136.76,
    "isWarehouse": 0,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "的",
    "amount": 11,
    "unit": "对",
    "price": 2.36,
    "total": 25.96,
    "isWarehouse": 1,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "高级官员",
    "amount": 57,
    "unit": "斗",
    "price": 81.53,
    "total": 4647.21,
    "isWarehouse": 0,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "科学家",
    "amount": 69,
    "unit": "公斤",
    "price": 81.59,
    "total": 5629.71,
    "isWarehouse": 0,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "和",
    "amount": 72,
    "unit": "颗",
    "price": 9.22,
    "total": 663.84,
    "isWarehouse": 1,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  },
  {
    "name": "专家",
    "amount": 7,
    "unit": "粒",
    "price": 80.48,
    "total": 563.36,
    "isWarehouse": 0,
    "updatedAt": "2020-09-17 15:08:15.066076",
    "updatedBy": "abc",
    "createdAt": "2020-12-17 15:08:15.066076",
    "createdBy": "def"
  }
];
