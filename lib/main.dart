import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:todo/day_event.dart';
import 'package:todo/todo.dart';
import 'day_block.dart';
import 'day_state.dart';
import 'loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory(); //finding directory path
  Hive.init(directory.path);
  Hive.registerAdapter(NoteAdapter());
  runApp(
      Start()
  );
}
class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: Myapp(),
    );
  }
}


class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Hive.openBox('todo'),                             //opening hive box
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.done){    //checks if box is open
            if(snapshot.hasError)                                  //checks if it has error
                {
              return Text(snapshot.error.toString());            //shows error
            }else{

              return HomePage();                                 //returns home screen
            }
          }else{
            return Scaffold(
              body: CircularProgressIndicator(),
            );                                      //return scaffold till box is opened

          }
        }
    );
  }
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;
  TextEditingController _eventController;
  final _dayblock = DayBloc();
  @override
  void initState() {
    _controller= CalendarController();
    _eventController=TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Todo'),
        centerTitle: true,
      ),
      body:  Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(                      //seting Background colour using gradient of colors
                    colors: [Colors.blue,Colors.black],        //set staring colour to green and end color to blue
                    begin: Alignment.topCenter,                 //starting point is top left corner of screen
                    end:Alignment.bottomCenter                  //ending point is bottom right corner
                )
            ),

          ),
          SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(


                        child: TableCalendar(
                          initialSelectedDay: DateTime.now(),
                          onDaySelected: (date, events) {
                            _dayblock.Changeday(date);
                            setState(() {

                            });
                          },

                          calendarController: _controller,
                          calendarStyle: CalendarStyle(
                            todayColor: Colors.blueGrey,
                            selectedColor: Colors.blue,
                          ),
                          headerStyle: HeaderStyle(
                            centerHeaderTitle: true,
                            formatButtonDecoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20.0)
                            ),
                            formatButtonTextStyle: TextStyle(
                              color: Colors.white,
                            ),
                            formatButtonShowsNext: false,
                          ),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                        ),
                      ),
                      BlocProvider(
                          bloc: _dayblock,
                          child: BlocBuilder(
                              bloc: _dayblock,
                              builder: ( context, DayState state){
                                if(state is InitialState)
                                  {
                                    return Container(
                                      child: Center(
                                        child: Text("Please selecte Date"),
                                      ),
                                    );
                                  }
                                if(state is ShowTodo)
                                  {
                                    return  ListTodo();
                                  }
                                if(state is InputTodo)
                                  {
                                    return InputForm();
                                  }
                                if(state is UpdateTodo){
                                  return UpdateForm();
                                }
                                if(state is LoadingState){
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                      ),
                      )
                    ],
                  ),
                ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _dayblock.Input(_controller.selectedDay);
    }

      ),
    );
  }
  @override
  void dispose() {
    _dayblock.dispose();
    super.dispose();
  }
}


class ListTodo extends StatefulWidget {

  @override
  _ListTodoState createState() => _ListTodoState();
}

class _ListTodoState extends State<ListTodo> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<DayBloc>(context),

        builder: (context,DayState state){
          return ValueListenableBuilder(
            valueListenable: state.todobox.listenable(),
            builder: ( context,Box todos,_){
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: todos.length,
                itemBuilder: (BuildContext context,int index){
                  final todo = todos.getAt(index);
                  if(state.day==null)
                    return SizedBox(height: 0,);
                  if((state.day.day!=todo.date.day) || (state.day.month!=todo.date.month)||(state.day.year!= todo.date.year)) {
                    return SizedBox(height: 0,);
                  } else {
                    int hour= todo.date.hour;
                    int minutes=todo.date.minute;
                    String ti;
                    if(hour>=12) {
                      if(hour>12)
                        hour=hour-12;
                      ti = "pm";
                    }
                    else
                      ti = "am";
                    return Column(
                      children: <Widget>[
                                Text("${hour} : $minutes "+ti,style: TextStyle(
                                  color: Colors.white,
                                ),),
                              Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius:BorderRadius.all(Radius.circular(10.0)),    //providing circular edges
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black,
                                    ),
                                    color: (todo.completed)?Colors.lightGreenAccent:Colors.orangeAccent
                                ),
                                child: ExpansionTile(

                                  key: Key(todo.date.toString()),

                                  title: Text(todo.title.toString()),
                                      children: <Widget>[
                                            Text(todo.description.toString()),
                                                Text(""),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget>[
                                                                  IconButton(
                                                                  icon: Icon(Icons.edit),
                                                                    tooltip: "Update Todo",
                                                                      onPressed:(){
                                                                        BlocProvider.of<DayBloc>(context).Update(index);
                                                                        setState(() {

                                                                        });
                                                                        } ,

                                                      ),
                                                      IconButton(
                                                       icon: (todo.completed)?Icon(Icons.update):Icon(Icons.done),
                                                       tooltip: (todo.completed)?"Mark as in-complete":"Mark as completed",
                                                       onPressed: (){
                                                       BlocProvider.of<DayBloc>(context).MarkComp(index);
                                                       setState(() {

                                                         });
                                                       } ,
                                                      ),
                                                      IconButton(
                                                      icon: Icon(Icons.delete),
                                                      tooltip: "Delete todo",
                                                      onPressed: (){
                                                      BlocProvider.of<DayBloc>(context).Delete(index);
                                                      setState(() {

                                                      });
                                                      }
                    )
                   ] ,
                   )
                   ],
                   ),
                              )
                      ],
                    );
                  }

                },

              );
            },
          );
        }
    );
  }
}


class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  @override
  Widget build(BuildContext context) {
    String todo;
    String description;
    DateTime date = BlocProvider.of<DayBloc>(context).currentState.day;
    TimeOfDay _time = TimeOfDay.now();
    TimeOfDay _pikedtime;
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Form(
        key: _formKey,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical:10.0,horizontal:20.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'todo'
                ),
                onChanged: (input) {
                  todo = input;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical:10.0,horizontal:20.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Description'
                ),
                onChanged: (input) {
                  description = input;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            RaisedButton(
                onPressed: () async {
                  print(_time);
                  _pikedtime = await showTimePicker(
                      context: context, initialTime: _time);

                  _time=_pikedtime;

                },
                child: Text("Pick Deadline time")
            ),
            RaisedButton(
                child: Text("Save"),
                onPressed: (){
                  if(_formKey.currentState.validate()) {
                    BlocProvider.of<DayBloc>(context).AddTodo(
                        todo, description, _time, date);
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context)
                        .showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }

                }
            )
          ],
        ),
      ),
    );
  }
}

class UpdateForm extends StatefulWidget {
  @override
  _UpdateFormState createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  @override
  Widget build(BuildContext context) {
    int index=BlocProvider.of<DayBloc>(context).currentState.index;
    String todo=BlocProvider.of<DayBloc>(context).currentState.todobox.getAt(index).title;
    String description=BlocProvider.of<DayBloc>(context).currentState.todobox.getAt(index).description;

    DateTime date = BlocProvider.of<DayBloc>(context).currentState.todobox.getAt(index).date;
    TimeOfDay time = TimeOfDay(hour: date.hour, minute: date.minute);
    TimeOfDay pikedtime;
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical:10.0,horizontal:20.0),
              child: TextFormField(
                initialValue: todo,
                decoration: InputDecoration(
                    labelText: 'todo',

                ),
                onChanged: (input) {
                  todo = input;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical:10.0,horizontal:20.0),
              child: TextFormField(
                initialValue: description,
                decoration: InputDecoration(
                    labelText: 'Description'
                ),
                onChanged: (input) {
                  description = input;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            RaisedButton(
                onPressed: () async {
                  pikedtime = await showTimePicker(
                      context: context, initialTime: time);
                  time = pikedtime;

                  print(time);
                },
                child: Text("Pick Deadline time")
            ),
            RaisedButton(
                child: Text("Save"),
                onPressed: (){
                  if (_formKey.currentState.validate()) {
                    BlocProvider.of<DayBloc>(context).Putat(index, todo, description, time, date);
                    setState(() {

                    });
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Processing Data')));
                  }
                }
            )
          ],
        ),
      ),
    );
  }
}

