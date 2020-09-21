import 'package:flutter/services.dart';
import 'package:rigorous_app/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rigorous_app/db/item.dart';

class AddItemsScreen extends StatefulWidget {
  @override
  _AddItemsScreen createState() => _AddItemsScreen();
}

class _AddItemsScreen extends State<AddItemsScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  bool multiple = false;
  ItemObject item;
  final DatabaseHelper db = DatabaseHelper.instance;
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    item = ItemObject();

    for (var i = 0; i < 4; i++) {
      controllers.add(TextEditingController());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: AppTheme.notWhite,
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
                        child: Icon(Icons.border_clear),
                      ),
                      onTap: () async {
                        bool isClear = await confirmClear();
                        if (isClear) {
                          clear();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 货物名称
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      itemLabel('名称'),
                      styledTextInput(context, (String name) {
                        item.name = name;
                      }, '货物名称', MediaQuery.of(context).size.width * 0.8,
                          controllers[0]),
                    ],
                  ),
                  // 数量 & 单位
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      itemLabel('数量'),
                      styledTextInput(context, (String amt) {
                        int val = int.parse(amt);
                        item.amount = val;
                        setState(() {
                          item.resetTotal();
                        });
                      }, '0', MediaQuery.of(context).size.width * 0.4,
                          controllers[1]),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                        child: Row(
                          children: <Widget>[
                            itemLabel('单位'),
                            styledTextInput(context, (String unit) {
                              item.unit = unit;
                            },
                                '个，箱...',
                                MediaQuery.of(context).size.width * 0.2,
                                controllers[2]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      itemLabel('价格'),
                      styledTextInput(context, (String p) {
                        double val = double.parse(p);
                        item.price = val;
                        setState(() {
                          item.resetTotal();
                        });
                      }, '0', MediaQuery.of(context).size.width * 0.2,
                          controllers[3]),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '元',
                          style: TextStyle(),
                        ),
                      ),
                    ],
                  ),
                  // 总价
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        itemLabel('总价'),
                        itemLabel('${item.total}'),
                        itemLabel('元'),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                              child: Text(
                                '修改',
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline),
                              ),
                              onTap: () async {
                                String num = await totalChange();
                                if (num != null && num != "") {
                                  setState(() {
                                    item.total = double.parse(num);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 项目类型
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      itemLabel('项目类型'),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text('入库'),
                          ),
                          Checkbox(
                            value: item.isWarehouse == 1,
                            activeColor: Colors.red, //选中时的颜色
                            onChanged: (bool value) {
                              setState(() {
                                item.isWarehouse = value ? 1 : 0;
                              });
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 4.0),
                            child: Text('出库'),
                          ),
                          Checkbox(
                            value: item.isWarehouse == 0,
                            activeColor: Colors.red, //选中时的颜色
                            onChanged: (bool value) {
                              setState(() {
                                item.isWarehouse = value ? 0 : 1;
                              });
                            },
                          )
                        ],
                      ),
                      Center(
                        child: RaisedButton(
                          child: Text('添加'),
                          onPressed: () async {
                            if (item.name == "") {
                              return await showAlert("货物名称不能为空！");
                            }
                            FocusScope.of(context).unfocus();
                            int id = await db.insertItem(item);
                            await confirm(item.name);
                            clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clear() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      item = ItemObject();
      // item.total = 0;
    });
  }

  Future<void> confirm(String name) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("已添加新项目${name}"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  child: Text("确定")),
            ],
          );
        });
  }

  Future<bool> confirmClear() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("清空所有已输入内容？"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => {Navigator.of(context).pop(false)},
                  child: Text("取消")),
              FlatButton(
                  onPressed: () => {Navigator.of(context).pop(true)},
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.redAccent),
                  )),
            ],
          );
        });
  }

  Future<void> showAlert(String text) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "警告",
              style: TextStyle(fontSize: 25, color: Colors.redAccent),
            ),
            content: Text(
              text,
              style: TextStyle(fontSize: 20.0),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  child: Text("确定")),
            ],
          );
        });
  }

  Future<String> totalChange() {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        offset: const Offset(1.0, 2.0),
                        blurRadius: 0)
                  ]),
              height: AppBar().preferredSize.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.nearlyBlue,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "请输入合计金额：",
                          border: InputBorder.none,
                          helperStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: HexColor('#B9BABC'),
                          ),
                          labelStyle: AppTheme.body2,
                          fillColor: AppTheme.notWhite),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "取消",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () => Navigator.of(context).pop(), // 关闭对话框
              ),
              FlatButton(
                  onPressed: () => {Navigator.of(context).pop(controller.text)},
                  child: Text("确定")),
            ],
          );
        });
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

Widget textInput(String label, TextEditingController controller,
    {isNumeric: false}) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'WorkSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.nearlyBlue,
            ),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
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
            // onEditingComplete: () async {
            //   controller.text()
            //   setState(() {
            //     items = filtered;
            //   });
            // },
          ),
        ),
      )
    ],
  );
}

Widget itemLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget styledTextInput(BuildContext context, Function onChanged, String label,
    double width, TextEditingController controller) {
  return SizedBox(
    width: width,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(1.0, 2.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: TextField(
          autofocus: false,
          onChanged: onChanged,
          controller: controller,
          style: const TextStyle(
            fontSize: 18,
          ),
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
          ),
        ),
      ),
    ),
  );
}
