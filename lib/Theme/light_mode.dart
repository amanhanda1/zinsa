import 'package:flutter/material.dart';
ThemeData lightMode=ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(background: const Color.fromARGB(255, 224, 224, 224),
  primary: Colors.grey.shade200,
  secondary: Color.fromARGB(255, 95, 91, 91),
  inversePrimary: Colors.grey.shade800),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: const Color.fromARGB(255, 36, 34, 34),
    displayColor: Colors.black
  )
);