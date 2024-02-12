import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:reminders_app/helpers/notifications.dart';
import 'package:reminders_app/models/reminder.dart';
import 'package:reminders_app/providers/theme_provider.dart';
import 'package:reminders_app/screens/reminders_main_screen.dart';

import '../providers/reminders.dart';

//ekran za dodajanje in urejanje obvestil (add/edit screen)

class ReminderAddEditScreen extends StatefulWidget {
  static const routName = '/reminder-add-edit-screen';

  @override
  _ReminderAddEditScreenState createState() => _ReminderAddEditScreenState();
}

class _ReminderAddEditScreenState extends State<ReminderAddEditScreen> {
  final formKey = GlobalKey<FormState>();

//ustvarjanje vseh spremenljivk
  TextEditingController _controllerUrl;
  var _isInit = true;
  var _dateTime = DateTime.now();
  var _isChanged = false;
  var _titleChech = '';
  var _showCalendar = false;
  var _showTimer = false;
  DateTime _originalNotifyTime;
  final _timeNow = DateTime.now();

  var _editedReminder = Reminder(
    id: null,
    title: '',
    notes: '',
    url: '',
    isFlaged: false,
    isCompleted: false,
    notifyTime: null,
    isNotifyDays: false,
    isNotifyHours: false,
  );

  // izdelujemo REMINDER ali urejamo že obstoječ REMINDER
  @override
  void didChangeDependencies() {
    if (_isInit) {
      // preverimo če dodajamo novo obvestilo ali urejamo staro
      final productId = ModalRoute.of(context).settings.arguments as String;
      //če dodajamo novo obvestilo potem je productId = null ker id za to obvestilo še ne obstaja,
      //če pa obstaja pomeni da urejamo staro obvestilo
      if (productId != null) {
        //sprejemanje podatkov OBVESTILA ki ga urejamo
        _editedReminder = Provider.of<Reminders>(context).findById(productId);
        _controllerUrl = TextEditingController(text: _editedReminder.url);
        _titleChech = Provider.of<Reminders>(context).findById(productId).title;
        _originalNotifyTime = _editedReminder.notifyTime;
      }
    }
    _isInit = false;
    //pridobitev časa in datuma (zato da se v okencu kjer določamo čas za obveščanje prikaže trenuten čas)
    _dateTime = getDateTime();
    super.didChangeDependencies();
  }

  // funkcija DONE shrani podatke
  void _onSave() {
    formKey.currentState.save();

    if (_editedReminder.id != null) {
      //če urejamo shanimo spremembe
      Provider.of<Reminders>(context, listen: false)
          .editReminder(_editedReminder);
    } else {
      //če dodajamo nov opmonik pa ustvarimo nov opomnik
      Provider.of<Reminders>(context, listen: false).addReminder(
        title: _editedReminder.title,
        notes: _editedReminder.notes,
        url: _editedReminder.url,
        isFlaged: _editedReminder.isFlaged,
        isCompleted: _editedReminder.isCompleted,
        notifyTime: _editedReminder.notifyTime,
        isNotifyDays: _editedReminder.isNotifyDays,
        isNotifyHours: _editedReminder.isNotifyHours,
      );
    }

    if (_editedReminder.isNotifyDays != false &&
        _editedReminder.isNotifyHours != false) {
      //če smo izbrali možnost za obveščanje se tukaj ustvari obvestilo ki se bo izvedlo ob določenem času
      createReminderNotification(
          id: _editedReminder.id,
          title: _editedReminder.title,
          body: _editedReminder.notes,
          date: _editedReminder.notifyTime);
      print('Notification Relised');
    }

    Navigator.pop(context);
  }

  // funkcija CANCLE prekliše shranjevanje
  void _cancel(BuildContext _context) {
    // funkcija za prikaz okenca
    //preverimo ali smo kaj spremenili
    if (_isChanged || _originalNotifyTime != _editedReminder.notifyTime) {
      //če smo spremenili prikaže okence
      showCupertinoModalPopup<void>(
        context: _context,
        //grajenje celotne strani
        builder: (ctx) => CupertinoActionSheet(
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: Text('Discard Changes'),
              onPressed: () {
                Navigator.of(context)
                    .popAndPushNamed(RemindersMainScreen.routName);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            isDefaultAction: true,
          ),
        ),
      );
    } else {
      //če nismo nič spremenili nas vrže na HOME SCREEN
      Navigator.pop(context);
    }
  }

  //funkcija ki pridobi čas za prikaz v okencu za urejanje časa za obveščanje
  DateTime getDateTime() {
    if (_editedReminder.isNotifyHours) {
      //če je že določen čas prikažemo njega
      return DateTime(
        _editedReminder.notifyTime.year,
        _editedReminder.notifyTime.month,
        _editedReminder.notifyTime.day,
        _editedReminder.notifyTime.hour,
        _editedReminder.notifyTime.minute,
      );
    } else {
      //če ni določenega časa pa pridobimo sedanji čas
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        00,
      );
    }
  }

  // Funkcija ki izpiše datum obveščanja
  String dateShow({DateTime notifyTime, DateTime now, bool isNotifyDays}) {
    if (isNotifyDays) {
      int dateDifference =
          DateTime(notifyTime.year, notifyTime.month, notifyTime.day)
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
      if (dateDifference == 0) {
        //če je čas za obveščanje danes
        return 'Today';
      } else if (dateDifference == 1) {
        //če je čas za obveščanje jutri
        return 'Tomorrow';
      } else if (dateDifference == -1) {
        //če je čas za obveščanje bil včeraj
        return 'Yesterday';
      } else {
        //če je čas za obveščanje oddaljen za dlje časa
        return '${DateFormat('dd/MM/yyyy').format(notifyTime)}';
      }
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor:
          //ozadje glede na barvno temo
          Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
              ? Theme.of(context).backgroundColor.withOpacity(0.15)
              : Theme.of(context).primaryColor.withOpacity(0.80),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // zgornja upravilna vrstica (CANCEL - DONE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  //gumb za preklic
                  child: Text(
                    "Cancel",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.blue),
                  ),
                  onPressed: () => _cancel(context), // onSave
                ),
                TextButton(
                  //gumb za shranjevanje ali ustvarjanje novih obvestil
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                    ),
                  ),
                  //nslov obestla je obvezen če ni vnesen nemoremo stisniti gumb DONE
                  onPressed: _titleChech.isEmpty ? null : _onSave, // onSave
                ),
              ],
            ),
            //vnosna polja za naslov, opomnike in url
            Container(
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              height: 230,
              width: double.infinity,
              child: Form(
                key: formKey,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // polje za vnos naslova
                        Container(
                          width: constraints.maxWidth,
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 1),
                          child: TextFormField(
                            onChanged: (value) {
                              //shranjevanje da je bilo nekaj spremenjeno
                              _isChanged = true;
                              setState(() {
                                _titleChech = value;
                              });
                            },
                            key: ValueKey('title'),
                            initialValue: _editedReminder.title,
                            style: Theme.of(context).textTheme.bodyText1,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: InputBorder.none,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(0.64),
                                  ),
                            ),
                            //shranjevanje naslova (vse ohranimo razen naslova)
                            onSaved: (value) {
                              _editedReminder = Reminder(
                                id: _editedReminder.id,
                                title: value,
                                notes: _editedReminder.notes,
                                url: _editedReminder.url,
                                isFlaged: _editedReminder.isFlaged,
                                isCompleted: _editedReminder.isCompleted,
                                notifyTime: _editedReminder.notifyTime,
                                isNotifyDays: _editedReminder.isNotifyDays,
                                isNotifyHours: _editedReminder.isNotifyHours,
                              );
                            },
                          ),
                        ),

                        Divider(
                          //črtica med polji za vnos besedila
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.15),
                          thickness: 1,
                          height: 0,
                          indent: 20,
                        ),
                        // polje za vnos NOTES
                        Container(
                          width: constraints.maxWidth,
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: TextFormField(
                            //shranjevanje da je bilo nekaj spremenjeno
                            onChanged: (value) => _isChanged = true,
                            key: ValueKey('note'),
                            initialValue: _editedReminder.notes,
                            style: Theme.of(context).textTheme.bodyText1,
                            decoration: InputDecoration(
                              labelText: 'Note',
                              border: InputBorder.none,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(0.64),
                                  ),
                            ),
                            onSaved: (value) {
                              //shranjevanje opomb (vse ohranimo razen opomb)
                              _editedReminder = Reminder(
                                id: _editedReminder.id,
                                title: _editedReminder.title,
                                notes: value,
                                url: _editedReminder.url,
                                isFlaged: _editedReminder.isFlaged,
                                isCompleted: _editedReminder.isCompleted,
                                notifyTime: _editedReminder.notifyTime,
                                isNotifyDays: _editedReminder.isNotifyDays,
                                isNotifyHours: _editedReminder.isNotifyHours,
                              );
                            },
                          ),
                        ),
                        Divider(
                          //črtica med polji za vnos besedila
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.15),
                          thickness: 1,
                          height: 0,
                          indent: 20,
                        ),

                        // polje za vnos URL-ja
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              width: constraints.maxWidth - 98,
                              child: TextFormField(
                                //shranjevanje da je bilo nekaj spremenjeno
                                onChanged: (value) => _isChanged = true,
                                keyboardType: TextInputType.url,
                                key: ValueKey('URL'),
                                controller: _controllerUrl,
                                style: Theme.of(context).textTheme.bodyText1,
                                decoration: InputDecoration(
                                  labelText: 'URL',
                                  border: InputBorder.none,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        color: Theme.of(context)
                                            .backgroundColor
                                            .withOpacity(0.64),
                                      ),
                                ),
                                onSaved: (value) {
                                  //shranjevanje URL-ja (vse ohranimo razen URL-ja)
                                  _editedReminder = Reminder(
                                    id: _editedReminder.id,
                                    title: _editedReminder.title,
                                    notes: _editedReminder.notes,
                                    //preverimo ali je uporabnik dodal http://www če ni dodamo mi
                                    url: value.contains('https://www.') ||
                                            value.contains('http://www.') ||
                                            value.isEmpty
                                        ? value
                                        : 'https://www.$value',
                                    isFlaged: _editedReminder.isFlaged,
                                    isCompleted: _editedReminder.isCompleted,
                                    notifyTime: _editedReminder.notifyTime,
                                    isNotifyDays: _editedReminder.isNotifyDays,
                                    isNotifyHours:
                                        _editedReminder.isNotifyHours,
                                  );
                                },
                              ),
                            ),

                            // X za brisanje URL-ja
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 15, 10, 0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.20),
                                ),
                                onPressed: () => _controllerUrl.clear(),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                //barva glede na barvno temo
                color: Provider.of<ThemeProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // sestava okna za izbiranje dneva ob katerem te aplikacija opozori
                  ListTile(
                    // če stisnemo na okno se nam prikaže kolendar vendar samo če je časovni opomnik omogočen
                    onTap: _editedReminder.isNotifyDays
                        //preverimo če je časovni opomnik omogočen
                        ? () {
                            setState(() {
                              //prikaz kolendarja
                              _showCalendar = !_showCalendar;
                              if (_showTimer) {
                                //preklic prikaza kolendarja
                                _showTimer = false;
                              }
                            });
                          }
                        : null,
                    leading: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    title: Text(
                      'Date',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(
                      dateShow(
                        //funkcija ki nam prikazuje čas ki smo ga nastavili (takoj se obnavlaj)
                        notifyTime: _editedReminder.notifyTime,
                        now: _timeNow,
                        isNotifyDays: _editedReminder.isNotifyDays,
                      ),
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      //gumb s katerim upravljamo ali želimo imeti časovno obvestilo (vednar samo za dan in ne ure)
                      value: _editedReminder.isNotifyDays,
                      onChanged: (value) {
                        _isChanged = true;
                        setState(() {
                          _showCalendar = value;
                          _editedReminder.isNotifyDays = value;
                          if (value) {
                            _editedReminder.notifyTime = _dateTime;
                          } else {
                            _editedReminder.isNotifyHours = value;
                            _showTimer = false;
                          }
                        });
                      },
                    ),
                  ),
                  // Previrjanje ali želimo da se kolendar prikaže
                  _showCalendar
                      ? Container(
                          //prikaz kolendarja
                          margin: EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: 280,
                            height: 38,
                            child: CupertinoDatePicker(
                              initialDateTime: _dateTime,
                              mode: CupertinoDatePickerMode.date,
                              onDateTimeChanged: (dateTime) {
                                // če zberemo dan se ta dan shrani
                                setState(() {
                                  _editedReminder.notifyTime = dateTime;
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                  Divider(
                    //črtica ki je med izbiro datumoma in ure
                    color: Theme.of(context).backgroundColor.withOpacity(0.15),
                    thickness: 1,
                    height: 0,
                    indent: 72,
                  ),

                  // sestava okna za izbiranje dneva ob katerem te aplikacija opozori
                  ListTile(
                    onTap: _editedReminder.isNotifyHours
                        //preverimo če je časovni opomnik omogočen
                        ? () {
                            setState(() {
                              //če je prikažemo uro
                              _showTimer = !_showTimer;
                              if (_showCalendar) {
                                //in skrijemo kolendar
                                _showCalendar = false;
                              }
                            });
                          }
                        : null,
                    leading: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.schedule_outlined,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    title: Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(
                      //prikaz časa ki smo ga nastavili (takoj se obnavlaj)
                      _editedReminder.isNotifyHours
                          ? DateFormat('kk:mm')
                              .format(_editedReminder.notifyTime)
                          : '',
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      //gumb s katerim upravljamo ali želimo imeti časovno obvestilo (če določimo za ure se samodejno določi tudi za dneve)
                      value: _editedReminder.isNotifyHours,
                      onChanged: (value) {
                        _isChanged = true;
                        setState(() {
                          _showTimer = value;
                          _editedReminder.isNotifyHours = value;
                          if (value) {
                            _editedReminder.isNotifyDays = true;
                            _editedReminder.notifyTime = _dateTime;
                            _showCalendar = false;
                          }
                        });
                      },
                    ),
                  ),
                  // Previrjanje ali želimo da se kolendar prikaže
                  _showTimer
                      ? Container(
                          //prikaz ure
                          margin: EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: 120,
                            height: 40,
                            child: CupertinoDatePicker(
                              minuteInterval: 5,
                              initialDateTime: _dateTime,
                              mode: CupertinoDatePickerMode.time,
                              use24hFormat: true,
                              onDateTimeChanged: (dateTime) {
                                // če določimo uro se ta ura shrani
                                setState(() {
                                  _editedReminder.notifyTime = dateTime;
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Flag notification switch
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                //določanje barve glede na barvno temo
                color: Provider.of<ThemeProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              //okno za določanje ZASTAVICE (pomembnosti)
              child: ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                title: Text(
                  'Flag',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                trailing: CupertinoSwitch(
                  //gumb s katerim upravljamo ali želimo dodati zastavico oziroma umakniti
                  value: _editedReminder.isFlaged,
                  onChanged: (value) {
                    //shranjevanje sprememb
                    _isChanged = true;
                    setState(() {
                      _editedReminder.isFlaged = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
