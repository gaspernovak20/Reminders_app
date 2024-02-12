import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders_app/providers/theme_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'screens/reminders_main_screen.dart';
import 'screens/reminder_add-edit_screen.dart';
import './providers/reminders.dart';

void main() {
  // osnovne nastavitve obvestil
  AwesomeNotifications().initialize(
    'resource://drawable/notification_app_icon',
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Reminders notifications',
        channelDescription: 'Notification channel for basic tests',
        importance: NotificationImportance.Max,
        defaultColor: Color(0xFFFF9800),
        soundSource: 'resource://raw/notification_app_sound',
        icon: 'resource://drawable/ic_stat_onesignal_default',
      )
    ],
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    //prikaz začetnega okna da odobritev/dovoljenje obvestil
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      // previrim ali so obvestila že odobrjena
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: Text('Allow notifications'),
              content: Text('Out app would like to send you notifications'),
              // gumb za odobritev ali preklic obvestil
              actions: [
                // gumb za odobritev
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Don\'t Allow')),
                // gumb za preklic
                TextButton(
                    onPressed: () => AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then(
                          (_) => Navigator.pop(context),
                        ),
                    child: Text('Allow')),
              ]),
        );
      }
    });

    AwesomeNotifications().createdStream.listen((notification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification created on ${notification.channelKey}'),
        ),
      );
      print('Notification created on ${notification.channelKey}');
    });
  }

  @override
  Widget build(BuildContext context) {
    //registriranje providerjev
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Reminders>(
          create: (context) => Reminders(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      builder: (context, _) {
        final themeprovider =
            Provider.of<ThemeProvider>(context); // dark/white mode provider
        return MaterialApp(
          title: 'Reminders',
          debugShowCheckedModeBanner: false,
          themeMode: themeprovider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: RemindersMainScreen(),
          // registriranje vesh strani
          routes: {
            ReminderAddEditScreen.routName: (ctx) => ReminderAddEditScreen(),
            RemindersMainScreen.routName: (ctx) => RemindersMainScreen(),
          },
        );
      },
    );
  }
}
