import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

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
  notifications.schedule(id,title,body,date,ongoing, );
}

Future showNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      @required NotificationDetails type,
      @required DateTime date,
      int id=0,


    }


)=>notifications.schedule(id,title,body,date,type, );