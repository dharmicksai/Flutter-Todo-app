import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/day_event.dart';
import 'package:todo/day_state.dart';

import 'todo.dart';
class DayBloc extends Bloc<DayEvent,DayState>{
  @override

  DayState get initialState => InitialState();
  void Changeday(DateTime day)
  {
    dispatch(ChangeDayEvent(day));
  }

  void AddTodo(String title,String description,TimeOfDay time,DateTime date)
  {
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,false);
    print(Date);
    dispatch(VerifyAddEvent(note));
  }

  void Putat(int index,String title,String description,TimeOfDay time,DateTime date)
  {
    final Date=DateTime(date.year,date.month,date.day,time.hour,time.minute);
    final note= Note(title,description,Date,Hive.box('todo').getAt(index).completed);
    print(Date);
    dispatch((PutAt(index, note)));
  }

  void Input(DateTime day){
    dispatch(InputEvent(day));
  }

  void Update(int index){
    dispatch(UpdateEvent(index));
  }

  void Delete(int index){
    dispatch(DeleteEvent(index));
  }


  void MarkComp(int index){
    dispatch(MarkCompEvent(index));
  }

  @override
  Stream<DayState> mapEventToState(
      DayState currentState,
      DayEvent event
      )async* {
    if(event is ChangeDayEvent){
      yield LoadingState();
      Future nal = await Future.delayed(Duration(seconds: 1));
      yield ShowTodo()..day=event.day;
    }else if(event is VerifyAddEvent){
        currentState..todobox.add(event.note);
       yield ShowTodo()..day=currentState.day;
    }else if(event is InputEvent ){
      yield InputTodo()..day=event.day;
    }else if(event is UpdateEvent){
      yield UpdateTodo()..day=currentState.day..index=event.index;
    }else if(event is DeleteEvent){
      yield ShowTodo()..todobox.deleteAt(event.index)..day=currentState.day;
    }else if(event is MarkCompEvent){
      final todobox=currentState.todobox;
      final note=Note(todobox.getAt(event.index).title, todobox.getAt(event.index).description, todobox.getAt(event.index).date, !(todobox.getAt(event.index).completed));
      yield ShowTodo()..todobox.putAt(event.index,note )..day=currentState.day;
    }else if(event is PutAt){

      yield ShowTodo()..todobox.putAt(event.index,event.note )..day=currentState.day;
    }


  }
}