import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/todo.dart';
//this provides the notification details such as priority
NotificationDetails get ongoing{
  final androidChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'channel description',
    importance: Importance.Max,
    priority: Priority.Max,
    ongoing:true,
    autoCancel: true,
  );
  final IOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, IOSChannelSpecifics);
}

Future showOngoingNotification(
FlutterLocalNotificationsPlugin notifications,
{
   @required String title,
   @required String body,
   @required int id=0,
   @required DateTime date,
}
){
  //scheduling notification
  notifications.schedule(id,title,body,date,ongoing, );
}

Future onSelectNotification(String payload) async{
//Todo implement payload
}
//this reinitialises all notifications after index
Future initialise_notifications(FlutterLocalNotificationsPlugin notifications,int index)
async{
  int f=0;
  for(int i= index+1;i<Hive.box('todo').length+1;i++)
  {
    Note note=Hive.box('todo').getAt(i);
      //saving notification at id:index
      if(DateTime.now().difference(note.date).isNegative&&Hive.box('todo').getAt(i).completed==false)
        await showOngoingNotification(notifications,title:note.title,body:note.description,date:note.date.subtract(Duration(hours: 1)),id:i-1);


  }
}
