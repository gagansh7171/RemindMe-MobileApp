import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './addReminder.dart';

class ReminderList extends StatelessWidget {
  final _reminders;
  final Function change;
  const ReminderList(this._reminders, this.change, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
      itemBuilder: (cts, index) => Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddReminder(_reminders, change, editIndex: index)),
            );
          },
          child: Row(children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.fromLTRB(10, 15, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reminders[index].title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _reminders[index].desc,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                      '${DateFormat.yMMMd().format(_reminders[index].date)}  ${DateFormat.jm().format(_reminders[index].date)}',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )),
            Switch(
              value: _reminders[index].toggle,
              onChanged: (bool val) {
                change(() {
                  _reminders[index].toggle = !_reminders[index].toggle;
                });
              },
            ),
            IconButton(
                onPressed: () {
                  change(() {
                    _reminders.removeAt(index);
                  });
                },
                color: Colors.red,
                icon: Icon(Icons.delete_forever_outlined)),
          ]),
        ),
      ),
      itemCount: _reminders.length,
    );
  }
}
