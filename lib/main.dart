import 'package:flutter/material.dart';
import './reminder.dart';
import './reminderList.dart';
import './addReminder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Reminder>? _reminders = [];
  bool loading = true;
  void _addReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddReminder(_reminders, setState)),
    );
  }

  @override
  void initState() {
    super.initState();
    getReminders();
  }

  void getReminders() async {
    var fetchedData = await helper.queryReminder();
    setState(() {
      loading = false;
      _reminders = fetchedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RemindMe'),
      ),
      body: loading
          ? Center(
              child: SpinKitRing(
                color: Colors.blue,
              ),
            )
          : ReminderList(_reminders, setState),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        tooltip: 'Add New Reminder',
        child: Icon(Icons.add),
      ),
    );
  }
}
