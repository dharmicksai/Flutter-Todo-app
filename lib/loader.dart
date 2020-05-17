import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';


class loader extends StatefulWidget { //animated widget
  @override
  _loaderState createState() => _loaderState();
}

class _loaderState extends State<loader> with SingleTickerProviderStateMixin{ // provides data for every frame
  AnimationController controller; //controller for animation
  Animation<double> animation_rotation; //animation for rotation
  Animation<double> animation_radius_in; //animation for radius in
  Animation<double> animation_radius_out; //animation for radius out
  double initialradius = 30 ; //initial radius
  double radius=0.0; //radius druing execution

  @override
  void initState(){ //initialisation of animations
    super.initState();
    Timer(Duration(seconds: 1), (){  //setting time of animation to 5 seconds
    } );
    controller=AnimationController(vsync: this,duration: Duration(seconds: 1)); //initialising controller

    animation_rotation = Tween<double>(
      begin: 0.0, // start of value of rotation
      end: -1.0, //end of value of rotation
    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.0,1.0,curve: Curves.linear)));// linear transition between values and during start to end time


    animation_radius_in = Tween<double>(
      begin: 1.0, //start value of radius
      end:0.0, //end value of radius

    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.75, 1,curve: Curves.elasticIn)));//elasticin transition between values and during last quarter of time
    animation_radius_out = Tween<double>(
      begin: 0.0,//start value of radius
      end:1.0,//end value of radius

    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 0.25,curve: Curves.elasticOut)));//elasticout transition between values and during first quarter of time
    controller.addListener((){ //changes value of radius
      setState(() {
        if(controller.value>=0.75&&controller.value<=1.0) //if last quarter of rotation
        {
          radius=initialradius*animation_radius_in.value; //use radius in
        }else if(controller.value>=0.0&&controller.value<=0.25) //if first quarter of rotation
        {
          radius=initialradius*animation_radius_out.value; //use radius out
        }
      });

    });
    controller.repeat(); //repeats the actions of controller

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      child: Center(
        child: RotationTransition( //Widget which rotates
          turns: animation_rotation, //animation rotation controlls rotation of this widget
          child: Stack( //stack widgets one above the other
            children: <Widget>[
              Dot( //center Dot
                radius:20.0,
                color: Colors.white,
              ),
              Transform.translate(//sets position of smaller dots
                offset: Offset(radius*cos(pi/4), radius*sin(pi/4)),
                child: Dot( //dot object
                  radius: 10.0,
                  color: Colors.black12,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(pi/2), radius*sin(pi/2)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.blue,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(3*pi/4), radius*sin(3*pi/4)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.greenAccent,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(pi), radius*sin(pi)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.yellow,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(5*pi/4), radius*sin(5*pi/4)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.orange,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(3*pi/2), radius*sin(3*pi/2)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(7*pi/4), radius*sin(7*pi/4)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.red,
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(2*pi), radius*sin(2*pi)),
                child: Dot(
                  radius: 10.0,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {

  final double radius;
  final Color color;

  const Dot({ this.radius, this.color}) ;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(//provides circle shape to container
          color: this.color,
          shape: BoxShape.circle,
        ),

      ),
    );
  }
}
