import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../utils/Extensions/decorations.dart';


class ImageHover extends StatefulWidget {
  @override
  _ImageHoverState createState() => _ImageHoverState();
}

class _ImageHoverState extends State<ImageHover> {
  double elevation = 4.0;
  double scale = 1.0;
  Offset translate = Offset(0,0);
  @override
  Widget build(context) {
    return InkWell(
      onTap: (){},
      onHover: (value){
        print(value);
        if(value){
          setState((){
            elevation = 20.0;
            scale = 2.0;
            translate = Offset(20,20);
          });
        }else{
          setState((){
            elevation = 4.0;
            scale = 1.0;
            translate = Offset(0,0);
          });
        }
      },
      child: Transform.translate(
        offset: translate ,
        child: Transform.scale(
          scale: scale,
          child: Material(
            elevation: elevation,
            child:Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(60)),
              child: IconButton(icon: Icon(Ionicons.fast_food_outline, size: 45), onPressed: () {}),
            ),
          ),
        ),
      ),
    );
  }
}