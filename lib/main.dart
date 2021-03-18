import 'package:flutter/material.dart';
import 'package:flutter_money_app/models/money.dart';
import 'package:flutter_money_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

const dartBlueColor = Color(0xff486579);

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Money _money = Money();
  List<Money> _moneys = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _ctrlCategoryId = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlDescription = TextEditingController();
  String categoryDropdown = Money.category.values.toList()[0];

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshMoneyList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _form(),
            _list(),
          ],
        ),
      ),
    );
  }

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          // TODO: バリデータを追加する
          children: <Widget>[
            Center(
              child: Text(_money.date == null
                  ? '日付を選択してください'
                  : DateFormat.yMMMd().format(_money.date)),
            ),
            new RaisedButton(
              onPressed: () => _selectDate(context),
              child: new Text('日付選択'),
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Category'),
              value: categoryDropdown,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              onSaved: (val) =>
                  setState(() => _money.categoryId = reverseCategoryMap()[val]),
              onChanged: (String newValue) {
                setState(() {
                  categoryDropdown = newValue;
                });
              },
              items: Money.category.values
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              controller: _ctrlAmount,
              decoration: InputDecoration(labelText: 'Amount'),
              onSaved: (val) => setState(() => _money.amount = int.parse(val)),
              validator: (val) =>
                  (val.length == 0 ? 'This field is required' : null),
            ),
            TextFormField(
              controller: _ctrlDescription,
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (val) => setState(() => _money.description = val),
            ),
            Container(
              child: ElevatedButton(
                child: Text('Submit'),
                onPressed: () => _onSubmit(),
              ),
            ),
          ],
        ),
      ));

  _refreshMoneyList() async {
    List<Money> x = await _dbHelper.fetchMoneys();
    setState(() {
      _moneys = x;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_money.id == null)
        await _dbHelper.insertMoney(_money);
      else
        await _dbHelper.updateMoney(_money);
      _refreshMoneyList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _ctrlCategoryId.clear();
      _ctrlAmount.clear();
      _ctrlDescription.clear();
      _money.id = null;
      _money.date = null;
      categoryDropdown = Money.category.values.toList()[0];
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) setState(() => _money.date = picked);
  }

  Map<String, int> reverseCategoryMap() {
    Map<String, int> map = {};
    Money.category.forEach((k, v) => map[v] = k);
    return map;
  }

  _list() => Expanded(
      child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.shopping_bag,
                        color: dartBlueColor, size: 40.0),
                    title: Text(
                      Money.category[_moneys[index].categoryId],
                      style: TextStyle(
                          color: dartBlueColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_moneys[index].description == null
                        ? ''
                        : _moneys[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(_moneys[index].amount.toString(),
                            style: TextStyle(
                              color: dartBlueColor,
                              fontWeight: FontWeight.bold,
                            )),
                        IconButton(
                            icon: Icon(Icons.delete_sweep, color: Colors.black),
                            onPressed: () async {
                              await _dbHelper.deleteMoney(_moneys[index].id);
                              _resetForm();
                              _refreshMoneyList();
                            }),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _money = _moneys[index];
                        _ctrlCategoryId.text =
                            _moneys[index].categoryId.toString();
                        _ctrlAmount.text = _moneys[index].amount.toString();
                        _ctrlDescription.text = _moneys[index].description;
                        print(Money.category[_moneys[index].categoryId]);
                        categoryDropdown =
                            Money.category[_moneys[index].categoryId];
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                  ),
                ],
              );
            },
            itemCount: _moneys.length,
          )));
}
