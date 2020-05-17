import 'package:hive/hive.dart';
import 'todo.dart';

abstract class DayState{
  final todobox=Hive.box('todo');
  DateTime day=DateTime.now();
  int index;


}
class InitialState extends DayState{

}

class InputTodo extends DayState{

}

class ShowTodo extends DayState {
}

class UpdateTodo extends DayState {

}

class LoadingState extends DayState {

}

