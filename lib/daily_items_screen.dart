import 'package:rigorous_app/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rigorous_app/db/item.dart';
import "package:sprintf/sprintf.dart";
import "package:intl/intl.dart";

class DailyItemsScreen extends StatefulWidget {
  @override
  _DailyItemsScreen createState() => _DailyItemsScreen();
}

class _DailyItemsScreen extends State<DailyItemsScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  bool multiple = false;
  final DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String, dynamic>> items;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    prepare();

    super.initState();
  }

  void prepare() async {
    var data = await getData();
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            // upper most status bar (battery, signal etc.)
            SizedBox(
              height: MediaQuery.of(context).padding.top,
              child: Container(),
            ),
            Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: AppBar().preferredSize.height + 40,
//                  height: AppBar().preferredSize.height,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32.0)),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '每日事项',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                Container(
                  width: AppBar().preferredSize.height + 20,
//                  height: AppBar().preferredSize.height,
                ),
                Container(
                  color: Colors.transparent,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey.withOpacity(0.8),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32.0)),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.tune),
                      ),
                      onTap: () {
                        setState(() {
                          multiple = !multiple;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            getSearchBarUI(),
            Divider(
              height: 1,
            ),
            FutureBuilder(
              future: getData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData || items == null || items.length == 0) {
                  return const SizedBox();
                } else {
                  // items = snapshot.data;
                  return Expanded(
                    child: GridView.builder(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ItemBlock(items[index], multiple);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: multiple ? 2 : 1,
                        mainAxisSpacing: 6.0,
                        crossAxisSpacing: 6.0,
                        childAspectRatio: multiple ? 1.1 : 3.6, // 条目宽高比
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getData() async {
    // await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return await db.queryAllItems();
  }

  double resizeCalc(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int _crossAxisCount = multiple ? 2 : 1;
    double _crossAxisSpacing = 8.0;

    double itemWidth =
        (screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
            _crossAxisCount;
//     var height = width / _aspectRatio;
    return screenHeight / itemWidth;
  }

  Widget getSearchBarUI() {
    TextEditingController filterController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#F8FAFB'),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextField(
                          controller: filterController,
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.nearlyBlue,
                          ),
                          // keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: '搜索名称',
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('#B9BABC'),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: HexColor('#B9BABC'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: InkWell(
                        splashColor: Colors.grey.withOpacity(0.4),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32.0)),
                        child: Icon(Icons.search, color: HexColor('#B9BABC')),
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          var filtered =
                              await db.queryItemByName(filterController.text);
                          setState(() {
                            items = filtered;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }
}

class ItemBlock extends StatefulWidget {
  const ItemBlock(this.item, this.isMulti, {Key key}) : super(key: key);

  final Map<String, dynamic> item;
  final bool isMulti;

  @override
  _ItemBlock createState() => _ItemBlock();
}

class _ItemBlock extends State<ItemBlock> {
  // int itemCnt;

  @override
  void initState() {
    // itemCnt = widget.itemCnt;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.lime.withOpacity(0.6),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(1.0, 2.0),
                blurRadius: 0)
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.item['name'].substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    "名称：${widget.item['name']}",
                    style: TextStyle(
                      fontSize: 22.0,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1, right: 2.0),
                  child: Text(
                    "计数：${widget.item['amount']}",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppTheme.darkText.withOpacity(0.8),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1, right: 2.0),
                  child: Text(
                    "总价：${sprintf("%.2f", [widget.item['total']])}",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppTheme.darkText.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          extraAttrs(!widget.isMulti, widget.item),
        ],
      ),
    );
  }
}

Widget extraAttrs(bool isMulti, Map<String, dynamic> item) {
  if (!isMulti) {
    return Container();
  }

  String formatted = DateFormat("yyyy-MM-dd HH:mm:ss")
      .format(DateTime.parse(item['createdAt']));
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SizedBox(
        height: 37,
      ),
      Text(
        "类型：${item['isWarehouse'] == 1 ? "入库" : "出库"}",
        style: TextStyle(
          fontSize: 20.0,
          color: AppTheme.darkText.withOpacity(0.8),
        ),
      ),
      // Text(
      //   "日期：$formatted",
      //   style: TextStyle(
      //     fontSize: 20.0,
      //     color: AppTheme.darkText.withOpacity(0.8),
      //   ),
      // ),
      Text(
        "单价：${sprintf("%.2f", [item['price']])}",
        style: TextStyle(
          fontSize: 20.0,
          color: AppTheme.darkText.withOpacity(0.8),
        ),
      ),
    ],
  );
}
