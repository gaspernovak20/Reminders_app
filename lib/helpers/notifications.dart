import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';

Future<void> createReminderNotification({
  String id,
  String title,
  String body,
  DateTime date,
}) async {
  DateTime time = date;
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(10000),
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        color: Color(0xFFFF9800),
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        customSound: 'resource://raw/notification_app_sound',
        //customSound: 'resource://raw/notification_app_sound',
      ),
      actionButtons: [
        NotificationActionButton(key: 'MARK_OPEN', label: 'OPEN'),
      ],
      schedule: NotificationCalendar.fromDate(date: time));
}
