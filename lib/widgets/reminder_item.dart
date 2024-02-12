import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../screens/reminder_add-edit_screen.dart';
import '../providers/reminders.dart';
import '../screens/reminders_main_screen.dart';

//datoteka ki določa obliko opomnika

// ignore: must_be_immutable
class ReminderItem extends StatelessWidget {
  final String id;
  final String title;
  final String notes;
  final String url;
  bool isFlaged;
  bool isCompleted;
  final DateTime notifyTime;
  bool isNotifyDays;
  bool isNotifyHours;
  final _timeNow = DateTime.now();

  ReminderItem({
    @required this.id,
    @required this.title,
    this.notes,
    this.url,
    @required this.isFlaged,
    @required this.isCompleted,
    @required this.notifyTime,
    @required this.isNotifyDays,
    @required this.isNotifyHours,
  });

  //funkcija ki odpre link ko stisnemo naje
  void openLink(_url) async {
    await canLaunchUrl(_url) ? await launchUrl(_url) : throw 'Could not launch $_url';
  }

  // funkcija ze čitliv izpis časa
  String dateShow({
    DateTime notifyTime,
    DateTime now,
    bool isNotifyHours,
    bool isNotifyDays,
  }) {
    if (notifyTime != null) {
      //preverimo če imamo čas za obveščanjne
      if (!isNotifyDays) {
        return '';
      } else if (isNotifyDays && !isNotifyHours) {
        //izvedemo če je določen le dan obveščanja
        int dateDifference =
            DateTime(notifyTime.year, notifyTime.month, notifyTime.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;
        // izračunamo čez koliko dni bo obvestilo
        if (dateDifference == 0) {
          return 'Today';
        } else if (dateDifference == 1) {
          return 'Tomorrow';
        } else if (dateDifference == -1) {
          return 'Yesterday';
        } else {
          return '${DateFormat('dd/MM/yyyy').format(notifyTime)}';
        }
        //
        //vrnemo besedilo glede na oddaljenost: Danes, včera, jutri ali pa prikažemo datum
        //
      } else {
        //izvedemo če je določen dan in čas
        int dateDifference =
            DateTime(notifyTime.year, notifyTime.month, notifyTime.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;
        // izračunamo čez koliko dni bo obvestilo
        if (dateDifference == 0) {
          return 'Today ${DateFormat('kk:mm').format(notifyTime)}';
        } else if (dateDifference == 1) {
          return 'Tomorrow ${DateFormat('kk:mm').format(notifyTime)}';
        } else if (dateDifference == -1) {
          return 'Yesterday ${DateFormat('kk:mm').format(notifyTime)}';
        } else {
          return '${DateFormat('dd/MM/yyyy, kk:mm').format(notifyTime)}';
        }
        //vrnemo besedilo glede na oddaljenost: Danes, včera, jutri ali pa prikažemo datum
      }
    } else {
      //če ni določen čas za obveščanje ne vrnemo nič
      return 'null';
    }
  }

  //zgradba obvestila
  @override
  Widget build(BuildContext context) {
    return Slidable(
      controller: RemindersMainScreen.slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Divider(
            color: Theme.of(context).backgroundColor.withOpacity(0.24),
            thickness: 1,
            height: 0,
            indent: 52,
          ),
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //prikaz ikone ki nam pove ali smo opravili
                Container(
                  margin: EdgeInsets.only(left: 8),
                  width: MediaQuery.of(context).size.width * 0.1 - 8,
                  child: IconButton(
                    icon: isCompleted
                        // ikono spreminjamo glede na to ali je opomnik že opravljen ali ni
                        ? Icon(
                            //če je opravljen
                            Icons.radio_button_checked,
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                        : Icon(
                            //če ni opravljen
                            Icons.brightness_1_outlined,
                            color: Theme.of(context)
                                .backgroundColor
                                .withOpacity(0.24),
                          ),
                    onPressed: () =>
                        //izvedba funkcije ki spremeni vrednost če je opravilo opravljeno ali ni
                        Provider.of<Reminders>(context, listen: false)
                            .isCompleted(id),
                  ),
                ),
                //prikaz besedila v reminderju
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  // določanje prostora glede na FLAG ikono
                  width: isFlaged
                      ? MediaQuery.of(context).size.width * 0.8 - 44
                      : MediaQuery.of(context).size.width * 0.8 - 20,
                  //Stolp v katerem se izpisejo TITLE, NOTES, URL
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      //izpis naslova
                      Container(
                        margin: notes.isEmpty && url.isEmpty
                            ? EdgeInsets.only(top: 15)
                            : EdgeInsets.fromLTRB(0, 15, 0, 6),
                        child: Text(
                          //naslov in izgled
                          title,
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // prikaz opomb in časa
                      notes.isNotEmpty || isNotifyDays
                          ? Container(
                              margin: url.isEmpty
                                  ? EdgeInsets.only(bottom: 16)
                                  : EdgeInsets.only(bottom: 6),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    //izpis datuma
                                    text: dateShow(
                                      notifyTime: notifyTime,
                                      now: _timeNow,
                                      isNotifyDays: isNotifyDays,
                                      isNotifyHours: isNotifyHours,
                                      // vnesemo vse potrebne podatke
                                    ),
                                    //izgled in oblika besedilas
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: isNotifyDays
                                            ? notifyTime.isAfter(_timeNow)
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color
                                                : Colors.red
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                        //če je čas za opravilo že potekel se nam čas izpiše z rdečo barvo
                                        ),
                                  ),
                                  TextSpan(
                                    text: isNotifyDays ? '\n$notes' : notes,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    //prilagodimo izgled opomnika glede na podatke ki jih moramo prikazati
                                  ),
                                ]),
                              ),
                            )
                          : Container(),
                      // prikaz URL-ja
                      url.isEmpty
                          //najprej previrimo če imamo podan URL
                          ? Container()
                          : Container(
                              height: 40,
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.15),
                              ),
                              child: TextButton(
                                onPressed: () => openLink(url),
                                //ob stisku na url se nam ta odpre
                                child: Text(
                                    url.replaceAll(RegExp('https://www.'), ''),
                                    // za lepši izgled odstranimo https://www. iz URL-ja
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              ),
                            ),
                    ],
                  ),
                ),
                // prikaz Zastavice
                isFlaged
                    ? Container(
                        //preverimo če jo prikažemo ali ne
                        margin: EdgeInsets.only(top: 12),
                        child: Icon(
                          // prikaz ikona
                          Icons.flag_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      )
                    : Container(),
                // prikaz ikone za nastavitve
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: IconButton(
                      alignment: Alignment.centerRight,
                      icon: Icon(
                        // prikaz ikone
                        Icons.info_outline,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      onPressed: () {
                        // zagon ekrana za urejanje ob pritisku
                        Navigator.pushNamed(
                          context,
                          ReminderAddEditScreen.routName,
                          arguments: id,
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
      // prikaz MENIJ če obvestilo potegnemo na levo
      secondaryActions: [
        //okno za odpiranje ekrana za nastavitve
        SlideAction(
          key: Key('Details'),
          child: Text(
            'Details',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          color: HexColor('#48484a'),
          onTap: () {
            //izvedba funkcije ki odpre ekran za urejanje
            Navigator.pushNamed(context, ReminderAddEditScreen.routName,
                arguments: id);
          },
        ),
        //okno za spreminjanje prikaza zastavice
        SlideAction(
          key: Key('Flag'),
          child: Text(
            'Flag',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          color: HexColor('#fe9f0c'),
          onTap: () =>
              Provider.of<Reminders>(context, listen: false).isFlaged(id),
          // funkcija ki spremeni vrednost zastavice
        ),
        //okno za izbris opomnika
        SlideAction(
          key: Key('Delete'),
          child: Text(
            'Delete',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          color: Colors.red,
          onTap: () =>
              Provider.of<Reminders>(context, listen: false).delete(id),
          //izvedba funkcije ki izbriše opomnik
        ),
      ],
    );
  }
}
