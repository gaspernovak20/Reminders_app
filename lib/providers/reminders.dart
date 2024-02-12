import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';

import '../helpers/database.dart';
import '../models/reminder.dart';

// opomniki provider shranjene funkcije ki jih pogličemo iz drugih datotek

class Reminders with ChangeNotifier {
  // list kjer se shranjujejo opomniki v aplikaciji
  List<Reminder> _reminders = [];

  var showIncomplet = true;

  // to funkcijo pokličemo ko želimo pridobiti opomnike
  List<Reminder> get reminders {
    if (showIncomplet) {
      //poda opomnike ki niso dokončani
      return _reminders.where((item) => !item.isCompleted).toList();
    } else {
      //poda vse opomnike
      return _reminders.reversed.toList();
    }
  }

  void hideIncomplete() {
    showIncomplet = false;
    notifyListeners();
  }

  void showIncomplete() {
    showIncomplet = true;
    notifyListeners();
  }

  Reminder newReminder;

  //funkcija ki spremeni dateTime v besedilo (zatu da lahko shranimo datum v napravo)
  String dateTimeToString(DateTime notifyTime) {
    if (notifyTime != null) {
      //preverimo če imamo podan datum
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      //izberemo format datuma
      String dateTimeString = dateFormat.format(notifyTime);
      //spremenimo in vrenemo datum v obliki besedila
      print('DATEstring: $dateTimeString');
      return dateTimeString;
    } else {
      return null;
    }
  }

  //funkcija ki spremeni datum v obliki teksta v dateTime (zato ker smo pridobili datum iz naprav v kateri je bi shranjen v obliki besedila)
  DateTime dateTimeToOrig(String notifyTime) {
    if (notifyTime != null) {
      //preverimo če imamo podan datum
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      //izberemo format datuma
      DateTime dateTime = dateFormat.parse(notifyTime);
      //spremenimo in vrenemo datum v obliki dateTime
      return dateTime;
    } else {
      return null;
    }
  }

// dodajanje novih opomnikov
  void addReminder(
      //informacije ki jih potrebujemo za dodajanje opomnika
      {
    String title,
    String notes,
    String url,
    bool isFlaged,
    bool isCompleted,
    DateTime notifyTime,
    bool isNotifyDays,
    bool isNotifyHours,
  }) {
    print('add reminder: $notifyTime');
//ustvarimo opomnik
    newReminder = Reminder(
      id: DateTime.now().toString(),
      title: title,
      notes: notes,
      url: url,
      isFlaged: isFlaged,
      isCompleted: isCompleted,
      notifyTime: notifyTime,
      isNotifyDays: isNotifyDays,
      isNotifyHours: isNotifyHours,
    );

    //shranimo opomnik v seznam (v aplikaciji)
    _reminders.add(newReminder);

    //shranjevanje opomnika v napravos
    DBHelper.insert(
      // določimo vse informacij ki so shranjene pod imenom
      'USER_REMINDERS',
      {
        'id': newReminder.id,
        'title': newReminder.title,
        'notes': newReminder.notes,
        'url': newReminder.url,
        'isFlaged': newReminder.isFlaged ? 1 : 0,
        'isCompleted': newReminder.isCompleted ? 1 : 0,
        'notifyTime': dateTimeToString(newReminder.notifyTime),
        'isNotifyDays': newReminder.isNotifyDays ? 1 : 0,
        'isNotifyHours': newReminder.isNotifyHours ? 1 : 0
      },
    );
    print('Add data');

    notifyListeners();
    // opomnimo vse strani da se je dodal nov opomnik (zato da se te znova naložijo)
  }

  //
  //fetchdata je funkcija ki poskrbi da se fetchAnfSetReminders izvede samo enkrat
  //
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  fetchData() {
    // pridobitev vseh opomnikov iz naprave ki se shranijo v aplikaciji (to se zvede ob zagonu aplikacije)
    return this._memoizer.runOnce(() async {
      print('Fetch data');
      final dataList = await DBHelper.getData('USER_REMINDERS');
      //izberemo mapo v katero smo shranili podatke (USER_REMINDERS)
      _reminders = dataList
          .map((reminder) => Reminder(
                id: reminder['id'],
                title: reminder['title'],
                notes: reminder['notes'],
                url: reminder['url'],
                notifyTime: dateTimeToOrig(reminder['notifyTime']),
                isFlaged: reminder['isFlaged'] == 1 ? true : false,
                isCompleted: reminder['isCompleted'] == 1 ? true : false,
                isNotifyDays: reminder['isNotifyDays'] == 1 ? true : false,
                isNotifyHours: reminder['isNotifyHours'] == 1 ? true : false,
              ))
          .toList();
      print('Fetch data');
      notifyListeners();
      // opomnimo vse strani da smo pridobili opomnike
    });
  }

  Future<void> fetchAnfSetReminders() async {
    print('Fetffffch data');
    final dataList = await DBHelper.getData('USER_REMINDERS');
    _reminders = dataList
        .map((reminder) => Reminder(
              id: reminder['id'],
              title: reminder['title'],
              notes: reminder['notes'],
              url: reminder['url'],
              notifyTime: dateTimeToOrig(reminder['notifyTime']),
              isFlaged: reminder['isFlaged'] == 1 ? true : false,
              isCompleted: reminder['isCompleted'] == 1 ? true : false,
              isNotifyDays: reminder['isNotifyDays'] == 1 ? true : false,
              isNotifyHours: reminder['isNotifyHours'] == 1 ? true : false,
            ))
        .toList();
    print('Feddddtch data');
    notifyListeners();
  }

// shranjevanje spremembpri opomnikih ki smo jih urejeli
  void editReminder(Reminder reminderItem) {
    //dobimo spremenjen opomnik
    final reminderIndex =
        _reminders.indexWhere((reminder) => reminder.id == reminderItem.id);
    //ponajdemo mesto kjer se nahaja ta opomnik
    _reminders[reminderIndex] = reminderItem;
    //zamenjamo opomnik z novim spremenjenim opomnikom

    //ta opomnik spremenimo tudi v napravi samo vstavimo nove podatke
    DBHelper.update(
      'USER_REMINDERS',
      {
        'id': reminderItem.id,
        'title': reminderItem.title,
        'notes': reminderItem.notes,
        'url': reminderItem.url,
        'isFlaged': reminderItem.isFlaged ? 1 : 0,
        'isCompleted': reminderItem.isCompleted ? 1 : 0,
        'notifyTime': newReminder.notifyTime != null
            ? dateTimeToString(newReminder.notifyTime)
            : '',
        'isNotifyDays': reminderItem.isNotifyDays ? 1 : 0,
        'isNotifyHours': reminderItem.isNotifyHours ? 1 : 0
      },
    );
    print('Edit data');
    notifyListeners();
    // obvestimo vse datoteke da smo spremenili enega izmed opomnikov
  }

//funkcija ki nam poda opomnik z določenim id-jem
  Reminder findById(String id) {
    //dobimo željen id
    return reminders.firstWhere((reminder) => reminder.id == id);
  }

//funkcija ki izbriže opomnik
  void delete(String id) {
    final reminderIndex = _reminders.indexWhere((element) => element.id == id);
    _reminders.removeAt(reminderIndex);
    // odstrani opomnik iz seznama

    DBHelper.delete('USER_REMINDERS', id);
    //odstrani opomnik iz naprave
    notifyListeners();
    //obvestimo datoteke da je eden izmed opomnikov zbrisan
  }

// funkcija ki doda ali umakne zastavico določenemu opomniku
  void isFlaged(String id) {
    final reminderId = _reminders.indexWhere((element) => element.id == id);
    _reminders[reminderId].isFlaged = !_reminders[reminderId].isFlaged;
    //dodamo ali umaknemo zastavico

    final intValue = _reminders[reminderId].isFlaged ? 1 : 0;
    // true ali false spremenimo v 1 ali 0 kar laho v napravo shranimo samo besedilo
    DBHelper.boolUpdate('USER_REMINDERS', 'isFlaged', id, intValue);
    //shranimo v napravi
    notifyListeners();
    //obvestimo vse datoteke o spremembi
  }

// funkcija kijer spremenimo če je opomnik opravljen ali ne
  void isCompleted(String id) {
    final reminderId = _reminders.indexWhere((element) => element.id == id);
    _reminders[reminderId].isCompleted = !_reminders[reminderId].isCompleted;
    // spremenimo vrednost če je opravljeno ali ni

    final intValue = _reminders[reminderId].isCompleted ? 1 : 0;
    // true ali false spremenimo v 1 ali 0 kar laho v napravo shranimo samo besedilo
    DBHelper.boolUpdate('USER_REMINDERS', 'isCompleted', id, intValue);
    //shranimo v napravi
    notifyListeners();
    //obvestimo vse datoteke o spremembi
  }
}
