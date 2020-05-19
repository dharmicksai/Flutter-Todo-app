import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/day_event.dart';
import 'package:todo/day_state.dart';

import 'todo.dart';
class DayBloc extends Bloc<DayEvent,DayState>{
  @override
  //initial state
  DayState get initialState => InitialState();
  //converrting functions to events
  void Changeday(DateTime day)
  {
    dispatch(ChangeDayEvent(day));
  }

  void AddTodo(String title,String description,TimeOfDay time,DateTime date)
  {
    //creating note to add to_do
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,false);
    print(Date);
    dispatch(VerifyAddEvent(note));
  }

  void Putat(int index,String title,String description,TimeOfDay time,DateTime date)
  {
    //creating updated note
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,Hive.box('todo').getAt(index).completed);
    print(Date);
    dispatch((PutAt(index, note)));
  }

  void Input(DateTime day){
    //providing event
    dispatch(InputEvent(day));
  }

  void Update(int index){
    //providing event
    dispatch(UpdateEvent(index));
  }

  void Delete(int index){
    //providing event
    dispatch(DeleteEvent(index));
  }


  void MarkComp(int index){
    //providing event
    dispatch(MarkCompEvent(index));
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