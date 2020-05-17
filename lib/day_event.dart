import 'todo.dart';

abstract class DayEvent {}

class ChangeDayEvent extends DayEvent{
  DateTime day;
  ChangeDayEvent(this.day);
}

class VerifyAddEvent extends DayEvent {
  Note note;
  VerifyAddEvent(this.note);
}

class InputEvent extends DayEvent{
  DateTime day;
  InputEvent(this.day);
}

class UpdateEvent extends DayEvent{
  int index;
  UpdateEvent(this.index);
}

class PutAt extends DayEvent{
  int index;
  Note note;
  PutAt(this.index,this.note);
}

class DeleteEvent extends DayEvent{
  int index;
  DeleteEvent(this.index);
}
class MarkCompEvent extends DayEvent{
  int index;
  MarkCompEvent(this.index);
}


