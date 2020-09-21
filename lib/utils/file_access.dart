import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:rigorous_app/db/item.dart";

Future<File> _genLocalFile(String fileName) async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return File('$dir/$fileName');
}

Future<String> dumpData() async {
  DatabaseHelper db = DatabaseHelper.instance;
  File outFile = await _genLocalFile("items.json");
  List<Map> data = await db.queryAllItems();
  for (var d in data) {
    outFile.writeAsStringSync(d.toString() + "\n");
  }
  return outFile.path;
}
