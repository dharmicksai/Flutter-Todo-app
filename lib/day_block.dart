import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:todo/day_event.dart';
import 'package:todo/day_state.dart';

import 'LocalNotificationHelper.dart';
import 'todo.dart';



Future onSelectNotification(String payload) async{

}

Future initialise_notifications(FlutterLocalNotificationsPlugin notifications,int index)
async{
  int f=0;
  for(int i= 0;i<Hive.box('todo').length;i++)
    {
      Note note=Hive.box('todo').getAt(index);
      if(i==index)
        {
          f=1;
          continue;
        }
      if(f==1)
        {
          if(DateTime.now().difference(note.date).isNegative&&Hive.box('todo').getAt(index).completed==false)
          await showOngoingNotification(notifications,title:note.title,body:note.description,date:note.date.subtract(Duration(hours: 1)),id:index-1);
        } else
        {
          if(DateTime.now().difference(note.date).isNegative&&Hive.box('todo').getAt(index).completed==false)
          await showOngoingNotification(notifications,title:note.title,body:note.description,date:note.date.subtract(Duration(hours: 1)),id:index);
        }
    }
}

class DayBloc extends Bloc<DayEvent,DayState>{
  final notifications = FlutterLocalNotificationsPlugin();
  @override
  //initial state
  DayState get initialState => InitialState();
  //converrting functions to events
  DayBloc()  {
    final settingAndroid = AndroidInitializationSettings('app_icon');
    final settingIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id,title,body,payload){
          onSelectNotification(payload);
        }
    );
    notifications.initialize(
        InitializationSettings(settingAndroid, settingIOS),
        onSelectNotification:onSelectNotification
    );

  }


  void Changeday(DateTime day)
  {
    dispatch(ChangeDayEvent(day));
  }

  Future<void> AddTodo(String title,String description,TimeOfDay time,DateTime date)
  async {
    //creating note to add to_do
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,false);
    print(Date);
    if(DateTime.now().difference(Date).isNegative)
      await showOngoingNotification(notifications,title:title,body:description,date: Date.subtract(Duration(hours: 1)),id:Hive.box('todo').length);
    dispatch(VerifyAddEvent(note));

  }

  void Putat (int index,String title,String description,TimeOfDay time,DateTime date)
  async{
    //creating updated note
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,Hive.box('todo').getAt(index).completed);
    print(Date);
    dispatch((PutAt(index, note)));
    if(DateTime.now().difference(Date).isNegative&&Hive.box('todo').getAt(index).completed==false)
    await showOngoingNotification(notifications,title:title,body:description,date: Date.subtract(Duration(hours: 1)),id:index);
  }

  void Input(DateTime day){
    //providing event
    dispatch(InputEvent(day));
  }

  void Update(int index){
    //providing event
    dispatch(UpdateEvent(index));
  }

  void Delete(int index)async{
    notifications.cancelAll();
    await initialise_notifications(notifications, index);
    dispatch(DeleteEvent(index));
  }


  void MarkComp(int index)async{
    dispatch(MarkCompEvent(index));

    notifications.cancel(index);


  }

  @override
  Stream<DayState> mapEventToState(
      DayState currentState,
      DayEvent event
      )async* {
    if(event is ChangeDayEvent){
      yield LoadingState();
      //providing artificial loading time
      Future nal = await Future.delayed(Duration(seconds: 1));
      yield ShowTodo()..day=event.day;
    }else if(event is VerifyAddEvent){
      //adding task to hive db
        currentState..todobox.add(event.note);
       yield ShowTodo()..day=currentState.day;
    }else if(event is InputEvent ){
      //changing to input state
      yield InputTodo()..day=event.day;
    }else if(event is UpdateEvent){
      //providing date and index to update
      yield UpdateTodo()..day=currentState.day..index=event.index;
    }else if(event is DeleteEvent){
      yield ShowTodo()..todobox.deleteAt(event.index)..day=currentState.day;
    }else if(event is MarkCompEvent){
      //updating event by changing completed status
      final todobox=currentState.todobox;
      final note=Note(todobox.getAt(event.index).title, todobox.getAt(event.index).description, todobox.getAt(event.index).date, !(todobox.getAt(event.index).completed));
      yield ShowTodo()..todobox.putAt(event.index,note )..day=currentState.day;
    }else if(event is PutAt){
      //updating db

      yield ShowTodo()..todobox.putAt(event.index,event.note )..day=currentState.day;
    }


  }
}