import 'package:awesome_notifications/awesome_notifications.dart';
import './reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void cancelNotification(int id){
  AwesomeNotifications().cancelSchedule(id);
}

Future<void> showNotificationAtScheduleCron(Reminder reminder) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminder.id,
        channelKey: 'scheduled',
        title: reminder.title,
        body:
            '${reminder.desc} at  ${DateFormat.jm().format(reminder.date)}, ${DateFormat.yMMMd().format(reminder.date)} ',
        notificationLayout: NotificationLayout.BigPicture,
        payload: {'uuid': 'uuid-test'},
        autoCancel: false,
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'SNOOZE', label: 'SNOOZE', autoCancel: true),
        NotificationActionButton(
          key: 'STOP',
          label: 'STOP',
          autoCancel: true,
        )
      ],
      schedule: NotificationCalendar.fromDate(date: reminder.date));
}

void initReminder() {
  AwesomeNotifications().initialize(
      'resource://drawable/res_flutter_icon',
      [
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
          // Image.asset(
          //   'assets/images/animated-bell.gif',
          //   height: 200,
          //   fit: BoxFit.fitWidth,
          // ),
          Text(
            'Allow Awesome Notifications to send you beautiful notifications!',
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
