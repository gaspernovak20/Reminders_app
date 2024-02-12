import 'package:flutter/material.dart';

// datoteka kjer določimo podatke ki jih vsebuje opomnik
class Reminder {
  //id, naslov,obvestila,url,čas,informacijo če vsebuje zastavico,
  //če je opravljen,če ima določen dan obveščanja in če ima določeno uro obveščanja
  final String id;
  final String title;
  final String notes;
  final String url;
  DateTime notifyTime;
  var isFlaged = false;
  var isCompleted = false;
  var isNotifyDays = false;
  var isNotifyHours = false;

  Reminder({
    @required this.id,
    @required this.title,
    this.notes,
    this.url,
    this.notifyTime,
    @required this.isFlaged,
    @required this.isCompleted,
    @required this.isNotifyDays,
    @required this.isNotifyHours,
  });
}
