import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders_app/providers/theme_provider.dart';
import 'package:reminders_app/widgets/reminder_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../providers/reminders.dart';
import './reminder_add-edit_screen.dart';

//glavni ekran "main screen"

enum FilterOptions {
  All,
  Incomplete,
  DarkMode,
}

class RemindersMainScreen extends StatelessWidget {
  static final SlidableController slidableController = SlidableController();
  static const routName = '/reminders-main-screen';

  @override
  Widget build(BuildContext context) {
    //registriranje providerjev na temu delu kode
    final reminderProvider = Provider.of<Reminders>(context, listen: false);
    final reminders = Provider.of<Reminders>(context).reminders;
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          border: Border(bottom: BorderSide(color: Colors.transparent)),
          padding: EdgeInsetsDirectional.fromSTEB(0, 5, 6, 0),
          backgroundColor: Theme.of(context).primaryColor,
          leading: TextButton.icon(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.blue,
              size: 27,
            ),
            label: Text(
              'Done',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.blue),
            ),
            onPressed: () {},
          ),
          // middle: ChangeThemeButton(),

          //meni za izbiranje nastavitev
          trailing: PopupMenuButton(
              onSelected: (selectedValue) {
                if (selectedValue == FilterOptions.Incomplete) {
                  //prikaz neopravljenih obvestil
                  reminderProvider.showIncomplete();
                } else if (selectedValue == FilterOptions.All) {
                  //prikaz vseh obvestil
                  reminderProvider.hideIncomplete();
                } else {
                  //sprememba barvne teme
                  theme.toggleTheme();
                }
              },
              // gumb za dodatne nastavitve
              icon: Icon(
                Icons.more_vert,
                color: Colors.blue,
              ),
              itemBuilder: (_) => [
                    reminderProvider.showIncomplet
                        ? PopupMenuItem(
                            //opcija za prikaz vseh (opravljenih in neopravljenih) obvestil
                            child: Text(
                              'Show Complete',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.blue),
                            ),
                            value: FilterOptions.All)
                        : PopupMenuItem(
                            //opcija za prikaz samo neopravljenih obvestil
                            child: Text(
                              ' Hide Complete',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.blue),
                            ),
                            value: FilterOptions.Incomplete),
                    PopupMenuItem(
                        //opcija za zamenjavo barvne teme
                        child: Text(
                          theme.isDarkMode ? 'DarkMorde OFF' : 'DarkMode ON',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.blue),
                        ),
                        value: FilterOptions.DarkMode),
                  ]),
        ),
        body: FutureBuilder(
          //izvedba funkcije ki pridobi shranjene opomnike iz naprave
          future: Provider.of<Reminders>(context).fetchData(),
          builder: (ctx, snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //glavni naslov (Reminders)
              Container(
                margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: reminders.length,
                    //grajenje vseh obvestil
                    itemBuilder: (ctx, i) => ReminderItem(
                      //id obvestila
                      id: reminders[i].id,
                      //naslov obvestila
                      title: reminders[i].title,
                      //opombe obvestila
                      notes:
                          reminders[i].notes == null ? '' : reminders[i].notes,
                      // url/link obvestila
                      url: reminders[i].url == null ? '' : reminders[i].url,
                      //vrednost je obvestilo pomembno
                      isFlaged: reminders[i].isFlaged,
                      //vrednost ali je opravljeno
                      isCompleted: reminders[i].isCompleted,
                      //čas za opombo
                      notifyTime: reminders[i].notifyTime,
                      isNotifyDays: reminders[i].isNotifyDays,
                      isNotifyHours: reminders[i].isNotifyHours,
                    ),
                  ),
                ),
              ),
              //spodnja upravna vrstica
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      // Gumb za dodajanje obvestil
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        label: Text(
                          'New Reminder',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            ReminderAddEditScreen.routName,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
