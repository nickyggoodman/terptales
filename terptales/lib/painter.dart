/* This file defines a `DrawingPoint` class used for representing points 
in a drawing application. Each `DrawingPoint` contains an `id`, a list of 
`offsets`, a `color`, and a `width`. The `copyWith` method is implemented 
to create a copy of a `DrawingPoint` with optional parameters. 
Additionally, the `toJson` method is provided to serialize a `DrawingPoint` 
object into a JSON format for storage or transmission. This class is used 
in conjunction with the drawing functionality implemented in the referenced 
GitHub repository.
-Shreya M*/

// code taken from: https://github.com/dannndi/flutter_drawing_app/tree/main

import 'package:flutter/material.dart';



class DrawingPoint {
 final int id;
 final List<Offset> offsets;
 final Color color;
 final double width;


 DrawingPoint({
   required this.id,
   required this.offsets,
   required this.color,
   required this.width,
 });


 DrawingPoint copyWith({
   int? id,
   List<Offset>? offsets,
   Color? color,
   double? width,
 }) {
   return DrawingPoint(
     id: id ?? this.id,
     offsets: offsets ?? this.offsets,
     color: color ?? this.color,
     width: width ?? this.width,
   );
 }


 Map<String, dynamic> toJson() {
   return {
     'id': id,
     'offsets': offsets.map((offset) => {'x': offset.dx, 'y': offset.dy}).toList(),
     'color': color.value, 
     'width': width,
   };
 }
}
