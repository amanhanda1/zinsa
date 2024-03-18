import 'package:flutter/material.dart';
ThemeData darkMode=ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(background: Colors.grey.shade700,
  primary: Colors.grey.shade800,
  secondary: Colors.grey.shade900,
  inversePrimary: Colors.grey.shade800),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade300,
    displayColor: Colors.white
  )
);