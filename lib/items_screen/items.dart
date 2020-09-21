import 'package:rigorous_app/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class PluginTrials extends StatefulWidget {
  @override
  _PluginTrials createState() => _PluginTrials();
}

class _PluginTrials extends State<PluginTrials> {
  @override
  void initState() {
    super.initState();
  }

  bool multiple = false;

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
                      '组件测试',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return ItemBlock(items[index]['content'],
                      items[index]['itemCnt'], multiple);
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: multiple ? 2 : 1,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                  childAspectRatio: multiple ? 1.1 : 5, // 条目宽高比
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
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
}

class ItemBlock extends StatefulWidget {
  const ItemBlock(this.content, this.itemCnt, this.isMulti, {Key key})
      : super(key: key);

  final String content;
  final int itemCnt;
  final bool isMulti;

  @override
  _ItemBlock createState() => _ItemBlock();
}

class _ItemBlock extends State<ItemBlock> {
  int itemCnt;

  @override
  void initState() {
    itemCnt = widget.itemCnt;
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
                    widget.content.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: 22.0,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1, right: 2.0),
                  child: Text(
                    "计数：$itemCnt",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppTheme.darkText.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.isMulti
                ? Container()
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.grey.withOpacity(0.2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32.0)),
                            child: Icon(Icons.add),
                            onTap: () {
                              setState(() {
                                itemCnt += 1;
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                itemCnt += 10;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 4),
                        child: Material(
                          color: Colors.transparent,
//                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                          child: InkWell(
                            splashColor: Colors.grey.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32.0)),
                            child: Icon(Icons.remove),
                            onTap: () {
                              if (itemCnt > 0) {
                                setState(() {
                                  itemCnt -= 1;
                                });
                              }
                            },
                            onLongPress: () {
                              if (itemCnt > 9) {
                                setState(() {
                                  itemCnt -= 10;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

const items = [
  {"content": "one", "itemCnt": 0},
  {"content": "two", "itemCnt": 2222},
  {"content": "项目二", "itemCnt": 33}
];
