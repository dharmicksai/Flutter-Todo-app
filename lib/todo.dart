import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
part 'todo.g.dart';

@HiveType(typeId:0)
class Note{
  @HiveField(0)
  String title;
  @HiveField(1)
  String description;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  bool completed;

  Note(this.title,this.description,this.date,this.completed);
}
