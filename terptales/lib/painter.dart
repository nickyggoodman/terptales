import 'package:flutter/material.dart';
// code taken from: https://github.com/dannndi/flutter_drawing_app/tree/main


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
     'color': color.value, // Store color as an int value
     'width': width,
   };
 }
}
