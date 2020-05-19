import 'dart:math';

import 'package:flutter/material.dart';

class OnCompletionWiggle extends StatelessWidget {
  final Widget child;
  bool completed;
  OnCompletionWiggle(this.child,this.completed){
   if(completed==true)
     this._endValue=2*pi;
   else
     this._endValue=0;
  }

  double _endValue;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0,end: _endValue),
        duration: Duration(milliseconds: 200),
        child: child,
        builder: (_,double value,Widget child){
          double offset = sin(value);
          return Transform.translate(
              offset: Offset(0, offset*5),
            child: child,
          );
        }
    );
  }
}
