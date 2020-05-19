import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:todo/day_event.dart';
import 'package:todo/todo.dart';
import 'day_block.dart';
import 'day_state.dart';
import 'widget/loader.dart';
import 'widget/OnCompleteWiggle.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  //finding path for app directory
  final directory =
      await getApplicationDocumentsDirectory();
  //initialising hive
  Hive.init(directory.path);
  //registering note adapter
  Hive.registerAdapter(NoteAdapter());
  runApp(Start());
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
    //future builder
    return FutureBuilder(
        future: Hive.openBox('todo'), //opening hive box
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //checks if box is open
            //checks if it has error
            if (snapshot.hasError)
            {
              //shows error
              return Text(snapshot.error.toString());
            } else {
              //returns home screen
              return HomePage();
            }
          } else {
            //hive is not yet open
            return Scaffold(
              body: CircularProgressIndicator(),
            ); //return scaffold till box is opened

          }
        });
  }

  @override
  void dispose() {
    //closing hive
    Hive.close();
    super.dispose();
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //declaring variables
  final notifications = FlutterLocalNotificationsPlugin();
  CalendarController _controller;
  TextEditingController _eventController;
  final _dayblock = DayBloc();
  @override
  void initState() {
    //initialising variables

    _controller = CalendarController();
    _eventController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            RaisedButton(onPressed: () {
              //closing drawer
              Navigator.pop(context);
              //building page2
              Navigator.of(context).push(createRoute());
            },
              child:

                  Text("Completed events",style: TextStyle(
                    fontFamily: 'Banger',
                    fontSize: 20.0,
                    fontWeight:FontWeight.w700,

                  ),)


            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Your Todo',style:  TextStyle(
          color: Colors.black87,
          fontSize: 50.0,    //font size
          fontFamily: "Bangers",  //font family
        ),),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    //seting Background colour using gradient of colors
                    colors: [
                  Colors.lightBlueAccent,
                  Colors.black12
                ], //set staring colour to green and end color to blue
                    begin: Alignment
                        .topCenter, //starting point is top center corner of screen
                    end: Alignment
                        .bottomCenter //ending point is bottom center corner
                    )),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  //callender
                  child:
                  BlocBuilder(
                    bloc: _dayblock,
                    builder: (context, DayState state) {
                      return TableCalendar(
                        //setting initial day to present day
                        initialSelectedDay: DateTime.now(),
                        //on selecting day sending event to change state
                        onDaySelected: (date, events) {
                          _dayblock.Changeday(date);
                          setState(() {});
                        },
                        events: _dayblock.currentState.events,


                        calendarController: _controller,
                        //colors for date text
                        calendarStyle: CalendarStyle(
                          todayColor: Colors.blueGrey,
                          selectedColor: Colors.blue,
                        ),
                        headerStyle: HeaderStyle(
                          //style for header of callender
                          centerHeaderTitle: true,
                          formatButtonDecoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20.0)),
                          formatButtonTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                          //shows current state of callender
                          formatButtonShowsNext: false,
                        ),
                        //seting starting day to monday
                        startingDayOfWeek: StartingDayOfWeek.monday,
                      );
                    }
                  ),
                ),
                BlocProvider(
                  //block provider to share blloc with its children
                  bloc: _dayblock,
                  child: BlocBuilder(
                    bloc: _dayblock,
                    builder: (context, DayState state) {
                      //changing ui based on state
                      if (state is InitialState) {
                        return Container(
                          child: Center(
                            child: Text("Please selecte Date"),
                          ),
                        );
                      }
                      if (state is ShowTodo) {
                        return ListTodo();
                      }
                      if (state is InputTodo) {
                        return InputForm();
                      }
                      if (state is UpdateTodo) {
                        return UpdateForm();
                      }
                      if (state is LoadingState) {
                        return Container(child: Center(child: loader()));
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      //button to add to_do to present selected date
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _dayblock.Input(_controller.selectedDay);
          }),
    );
  }

  @override
  void dispose() {
    //disposing bloc
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
      //inheriting bloc from provider
        bloc: BlocProvider.of<DayBloc>(context),
        builder: (context, DayState state) {
          return ValueListenableBuilder(
            //this rebuilds when there is change in hive box
            valueListenable: state.todobox.listenable(),
            builder: (context, Box todos, _) {
              //checking if there are no todos
              if(state.todobox.length==0)
                {
                  return Center(child: Text('Press the +'+' button to add todo',style: TextStyle(fontFamily: 'Bangers',fontSize: 20.0),));
                }
              return ListView.builder(
                //builder that provides list of all task
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) {
                  final todo = todos.getAt(index);
                  //checking the day of to_do
                  if (state.day == null)
                    return SizedBox(
                      height: 0,
                    );
                  if ((state.day.day != todo.date.day) ||
                      (state.day.month != todo.date.month) ||
                      (state.day.year != todo.date.year)) {
                    return SizedBox(
                      height: 0,
                    );
                  } else {
                    int hour = todo.date.hour;
                    int minutes = todo.date.minute;
                    String ti;
                    if (hour >= 12) {
                      if (hour > 12) hour = hour - 12;
                      ti = "pm";
                    } else
                      ti = "am";
                    return Column(
                      children: <Widget>[
                        //showing deadline
                        Text(
                          "Deadline: ${hour} : $minutes " + ti,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Bangers',
                            fontSize: 20.0,
                          ),
                        ),
                        Container(
                          //providing margin and border radius
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  10.0)), //providing circular edges
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black,
                              ),
                              //changing color based on if it is completed or not
                              color: (todo.completed)
                                  ? Colors.lightGreenAccent
                                  : Colors.orangeAccent),
                          //this wiggles the task when marked completed
                          child: OnCompletionWiggle(
                            ExpansionTile(
                              //providing key
                              key: Key(todo.date.toString()),
                              title: Row(
                                children: <Widget>[
                                  Text(todo.title.toString(),style: TextStyle(
                                      fontFamily: 'Bangers',  //font family for style
                                      fontSize: 30.0
                                  ),),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  (todo.completed==true)?
                                     Icon(Icons.assignment_turned_in):SizedBox()
                                ],
                              ),
                              children: <Widget>[
                                //on tap on widget children r shown
                                Text("description : "+todo.description.toString(),style:TextStyle(
                                  fontFamily: 'Satisfy',
                                  fontSize: 20.0,
                                  fontWeight:FontWeight.w700,

                                )),
                                //buttons in a row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      tooltip: "Update Todo",
                                      onPressed: () {
                                        //sending event of update to bloc
                                        BlocProvider.of<DayBloc>(context)
                                            .Update(index);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      //changing icon based on state of to_do
                                      icon: (todo.completed)
                                          ? Icon(Icons.update)
                                          : Icon(Icons.done),
                                      tooltip: (todo.completed)
                                          ? "Mark as in-complete"
                                          : "Mark as completed",
                                      onPressed: () {
                                        //on presed Mark as complete event is sent to bloc
                                        BlocProvider.of<DayBloc>(context)
                                            .MarkComp(index);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        tooltip: "Delete todo",
                                        onPressed: () {
                                          //on presed delete action is sent to bloc
                                          BlocProvider.of<DayBloc>(context)
                                              .Delete(index);
                                          setState(() {});
                                        })
                                  ],
                                )
                              ],
                            ),
                            todo.completed,
                          ),
                        )
                      ],
                    );
                  }
                },
              );
            },
          );
        });
  }
}
//input form for creation of to_do
class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  @override
  Widget build(BuildContext context) {
    //declaring variables
    String todo;
    String description;
    DateTime date = BlocProvider.of<DayBloc>(context).currentState.day;
    TimeOfDay _time = TimeOfDay.now();
    TimeOfDay _pikedtime;
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
      //providing form widget
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              //pading for feilds
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: 'todo'),
                //saving to_do as soon as there is change
                onChanged: (input) {
                  todo = input;
                },
                //providing validation
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                //saving as soon as input is changed
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
              //time picker to provide time
                onPressed: () async {
                  print(_time);
                  _pikedtime = await showTimePicker(
                      context: context, initialTime: _time);
                  _time = _pikedtime;
                },
                child: Text("Pick Deadline time")),
            RaisedButton(
                child: Text("Save"),
                onPressed: () {
                  //checking if both validators  are passed
                  if (_formKey.currentState.validate()) {
                    //sending event of save to bloc
                    BlocProvider.of<DayBloc>(context)
                        .AddTodo(todo, description, _time, date);
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                })
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
    //initialising variables
    int index = BlocProvider.of<DayBloc>(context).currentState.index;
    String todo = BlocProvider.of<DayBloc>(context)
        .currentState
        .todobox
        .getAt(index)
        .title;
    String description = BlocProvider.of<DayBloc>(context)
        .currentState
        .todobox
        .getAt(index)
        .description;

    DateTime date = BlocProvider.of<DayBloc>(context)
        .currentState
        .todobox
        .getAt(index)
        .date;
    TimeOfDay time = TimeOfDay(hour: date.hour, minute: date.minute);
    TimeOfDay pikedtime;
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Form(
        //form for to_do update
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              //providing padding
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: TextFormField(
                initialValue: todo,
                decoration: InputDecoration(
                  labelText: 'todo',
                ),
                onChanged: (input) {
                  //saving changes to input
                  todo = input;
                },
                //checking for errors
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (input) {
                  //saving changes
                  description = input;
                },
                validator: (value) {
                  //checking for errors in input
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            RaisedButton(
              //picking time from time picker
                onPressed: () async {
                  pikedtime =
                      await showTimePicker(context: context, initialTime: time);
                  time = pikedtime;

                  print(time);
                },
                child: Text("Pick Deadline time")),
            RaisedButton(
                child: Text("Save"),
                onPressed: () {
                  //sending save event to bloc
                  if (_formKey.currentState.validate()) {
                    BlocProvider.of<DayBloc>(context)
                        .Putat(index, todo, description, time, date);
                    setState(() {});
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                })
          ],
        ),
      ),
    );
  }
}

// i just put this for fun
Route createRoute() {
  //page builder for transition
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Page2(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //finding size of screen
      var screenSize = MediaQuery.of(context).size;
      var width = screenSize.width;
      //aplying rotation and transition
      return Transform(
        transform: Matrix4(
          1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0.003,
          0, 0, 0, 1,
        )
          ..translate(width * (1 - animation.value))
          ..rotateY(-pi / 4 + animation.value * pi / 4),
        child: child,
      );
    },
  );
}
//page2 is for showing all completed task
class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Completed todos",style: TextStyle(
            fontFamily: 'Banger',
            color: Colors.black87,
            fontSize: 30.0,
          ),),
        ),
        body:Stack(
          children: <Widget>[
            //providing background image
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/avengers.jpg"),
                    fit: BoxFit.cover,

                  )
              ),

            ),
            ValueListenableBuilder(
              valueListenable: Hive.box('todo').listenable(),
              builder: (context, Box todos, _) {
                return ListView.builder(

                  itemCount: todos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final todo = todos.getAt(index);
                    //checking if task is completed
                    if (todo.completed==false)
                      return SizedBox(
                        height: 0,
                      );
                    else {
                      int hour = todo.date.hour;
                      int minutes = todo.date.minute;
                      String ti;
                      if (hour >= 12) {
                        if (hour > 12) hour = hour - 12;
                        ti = "pm";
                      } else
                        ti = "am";
                      return Column(
                        //displaying time and date
                        children: <Widget>[
                          SizedBox(
                            height: 20.0,
                          ),
                          //making the widget blend with background
                          Opacity(
                            opacity: 0.75,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10.0)),
                                  //providing circular edges
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.black,
                                  ),
                                  color: (todo.completed)
                                      ? Colors.lightGreenAccent
                                      : Colors.orangeAccent),
                              child: ExpansionTile(
                                key: Key(todo.date.toString()),
                                title: Text(todo.title.toString(),style: TextStyle(
                                    fontFamily: 'Bangers',  //font family for style
                                    fontSize: 30.0

                                ),),
                                children: <Widget>[
                                  Text(todo.description.toString(),style:TextStyle(
                                    fontFamily: 'Satisfy',
                                    fontSize: 20.0,
                                    fontWeight:FontWeight.w700,

                                  ),),

                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  },
                );
              },
            )
          ],
        )
    );
  }
}
