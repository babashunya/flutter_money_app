import 'package:flutter/material.dart';
import 'package:flutter_money_app/models/money.dart';
import 'package:flutter_money_app/utils/database_helper.dart';

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
          children: <Widget>[
            TextFormField(
              controller: _ctrlCategoryId,
              decoration: InputDecoration(labelText: 'category id'),
              onSaved: (val) =>
                  setState(() => _money.categoryId = int.parse(val)),
              validator: (val) =>
                  (val.length == 0 ? 'This field is required' : null),
            ),
            TextFormField(
              controller: _ctrlAmount,
              decoration: InputDecoration(labelText: 'Amount'),
              onSaved: (val) => setState(() => _money.amount = int.parse(val)),
              validator: (val) =>
                  (val.length == 0 ? 'This field is required' : null),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                onPressed: () => _onSubmit(),
                child: Text('Submit'),
                color: Colors.black,
                textColor: Colors.white,
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
      _money.id = null;
    });
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
                    leading: Icon(Icons.account_circle,
                        color: dartBlueColor, size: 40.0),
                    title: Text(
                      _moneys[index].amount.toString(),
                      style: TextStyle(
                          color: dartBlueColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_moneys[index].categoryId.toString()),
                    trailing: IconButton(
                        icon: Icon(Icons.delete_sweep, color: Colors.black),
                        onPressed: () async {
                          await _dbHelper.deleteMoney(_moneys[index].id);
                          _resetForm();
                          _refreshMoneyList();
                        }),
                    onTap: () {
                      setState(() {
                        _money = _moneys[index];
                        _ctrlCategoryId.text =
                            _moneys[index].categoryId.toString();
                        _ctrlAmount.text = _moneys[index].amount.toString();
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
