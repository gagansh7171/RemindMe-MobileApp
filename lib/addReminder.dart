import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import './reminder.dart';
import './notificationUtils.dart';

class AddReminder extends StatefulWidget {
  AddReminder(this._reminders, this._add, {this.editIndex = -1, Key? key})
      : super(key: key);
  final Function _add;
  final List? _reminders;
  final int editIndex;
  @override
  _AddReminderState createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  String title = '';
  String desc = '';
  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper helper = DatabaseHelper.instance;

  void onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Reminder reminder = Reminder(
        title: title,
        desc: desc,
        toggle: true,
        date: date,
      );
      if (widget.editIndex == -1) {
        int? id = await helper.insert(reminder);
        reminder.id = id;
        showNotificationAtScheduleCron(reminder);
        widget._add(() {
          widget._reminders?.add(reminder);
        });
        Navigator.pop(context);
      } else {
        await helper.update(reminder, widget._reminders![widget.editIndex].id);
        reminder.id = widget._reminders![widget.editIndex].id;
        widget._add(() {
          widget._reminders![widget.editIndex] = reminder;
        });
        cancelNotification(widget._reminders![widget.editIndex].id);
        showNotificationAtScheduleCron(widget._reminders![widget.editIndex]);
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editIndex != -1) {
      title = widget._reminders![widget.editIndex].title;
      desc = widget._reminders![widget.editIndex].desc;
      date = widget._reminders![widget.editIndex].date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.editIndex != -1 ? 'Update Reminder' : 'Add Reminder'),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (val) {
                  setState(() {
                    title = val;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: desc,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (val) {
                  setState(() {
                    desc = val;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              DateTimePicker(
                type: DateTimePickerType.dateTimeSeparate,
                dateMask: 'd MMM, yyyy',
                initialValue: date.toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                icon: Icon(Icons.event),
                dateLabelText: 'Date',
                timeLabelText: "Time",
                onChanged: (val) {
                  setState(() {
                    date = DateTime.parse(val);
                  });
                },
              ),
              Container(
                  padding: EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                      onPressed: () => onSubmit(context), child: Text('Save'))),
            ],
          ),
        ),
      ),
    );
  }
}
