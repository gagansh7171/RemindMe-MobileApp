import 'package:awesome_notifications/awesome_notifications.dart';
import './reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DatabaseHelper helper = DatabaseHelper.instance;

void cancelNotification(int id) {
  AwesomeNotifications().cancelSchedule(id);
}

Future<void> showNotificationAtScheduleCron(Reminder reminder) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminder.id,
        channelKey: 'scheduled',
        title: '<b>${reminder.title}</b>',
        body:
            '${reminder.desc} <br/>  <i>${DateFormat.jm().format(reminder.date)}, ${DateFormat.yMMMd().format(reminder.date)}</i> ',
        notificationLayout: NotificationLayout.BigText,
        payload: {'uuid': 'uuid-test'},
        autoCancel: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP',
          label: 'Mark as Done',
          autoCancel: true,
        )
      ],
      schedule: NotificationCalendar.fromDate(date: reminder.date));
}

void initReminder() {
  AwesomeNotifications().initialize('resource://drawable/res_flutter_icon', [
    NotificationChannel(
        channelKey: 'scheduled',
        channelName: 'Scheduled notifications',
        channelDescription: 'Notifications with schedule functionality',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        vibrationPattern: lowVibrationPattern,
        importance: NotificationImportance.High,
        defaultRingtoneType: DefaultRingtoneType.Alarm),
  ]);

  AwesomeNotifications().actionStream.listen((receivedNotification) {
    int? id = receivedNotification.id;
    if (id != null) helper.toggleReminder(id, false);
  });
}

void checkPermission(
    BuildContext context, Function setState, bool notificationsAllowed) {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    setState(() {
      notificationsAllowed = isAllowed;
    });

    if (!isAllowed) {
      requestUserPermission(isAllowed, context, setState, notificationsAllowed);
    }
  });
}

void requestUserPermission(bool isAllowed, BuildContext context,
    Function setState, bool notificationsAllowed) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Color(0xfffbfbfb),
      title: Text('Get Notified!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Allow RemindMe to send you notifications!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () async {
            Navigator.of(context).pop();
            notificationsAllowed =
                await AwesomeNotifications().isNotificationAllowed();
            setState(() {
              notificationsAllowed = notificationsAllowed;
            });
          },
          child: Text('Later', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.deepPurple),
          onPressed: () async {
            Navigator.of(context).pop();
            await AwesomeNotifications().requestPermissionToSendNotifications();
            notificationsAllowed =
                await AwesomeNotifications().isNotificationAllowed();
            setState(() {
              notificationsAllowed = notificationsAllowed;
            });
          },
          child: Text('Allow', style: TextStyle(color: Colors.white)),
        )
      ],
    ),
  );
}
