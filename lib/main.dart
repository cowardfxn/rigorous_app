import 'package:flutter/material.dart';
import 'package:rigorous_app/app_theme.dart';
import 'package:rigorous_app/daily_items_screen.dart';
import 'package:rigorous_app/add_item_screen.dart';
import 'package:rigorous_app/db/item.dart';
import 'package:rigorous_app/chart_screen.dart';
import 'package:rigorous_app/utils/file_access.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '欢迎使用'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 3.0,
            crossAxisSpacing: 6.0,
            childAspectRatio: 3 / 1, // 条目宽高比
          ),
          children: getPages(context).map(
              (p) =>  cardBuilder(p['title'], p['icon'], p['onTap'])
          ).toList(),
        ),
      ),
    );
  }
}

Future<bool> confirm(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("提示"),
        content: Text("确定清除数据？"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => {Navigator.of(context).pop(false)},
            child: Text("取消")),
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            child: Text("确定", style: TextStyle(color: Colors.redAccent))),
        ],
      );
    });
}

Future<void> popup(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("提示"),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            onPressed: () => {Navigator.of(context).pop()},
            child: Text("确定")),
        ],
      );
    });
}

Widget cardBuilder(String title, Icon icon, Function onTap) {
  return Card(
    // color: Colors.blueAccent,
    //z轴的高度，设置card的阴影
    elevation: 6.0,
    //设置shape，这里设置成了R角
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    //对Widget截取的行为，比如这里 Clip.antiAlias 指抗锯齿
    clipBehavior: Clip.antiAlias,
    semanticContainer: false,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        // borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18.0),
            ),
            icon
          ],
        ),
      ),
    ),
  );
}

List<Map<String, Object>> getPages(BuildContext context) {
  List<Map<String, Object>> pages = [
    {
      "title": "每日事项",
      "icon": Icon(Icons.calendar_today_rounded),
      "onTap": () {
        Navigator.of(context).push(MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => DailyItemsScreen(),
        ));
      },
    },
    {
      "title": "添加事项",
      "icon": Icon(Icons.library_add),
      "onTap": () {
        Navigator.of(context).push(MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => AddItemsScreen(),
        ));
      },
    },
    {
      "title": "图表",
      "icon": Icon(Icons.stacked_line_chart),
      "onTap": () {
        Navigator.of(context).push(MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ChartScreen(),
        ));
      },
    },
    {
      "title": "清除数据",
      "icon": Icon(Icons.border_clear),
      "onTap": () async {
        bool confirmed = await confirm(context);
        if (confirmed != null && confirmed) {
          final db = DatabaseHelper.instance;
          await db.clearDB();
          await popup(context, "已清空数据，请重新输入");
        }
      },
    },
    {
      "title": "导出数据",
      "icon": Icon(Icons.drive_file_move_outline),
      "onTap": () async {
        String path = await dumpData();
        await popup(context, "导出数据至本地文件 $path");
      },
    },
    {
      "title": "生成测试数据",
      "icon": Icon(Icons.youtube_searched_for),
      "onTap": () async {
        await dummy();
        await popup(context, '已生成测试数据');
      },
    },
  ];

  return pages;
}
