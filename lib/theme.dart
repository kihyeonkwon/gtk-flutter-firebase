import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var appTheme = ThemeData(
  buttonTheme: const ButtonThemeData().copyWith(
    highlightColor: Colors.deepPurple,
  ),
  primarySwatch: Colors.deepPurple,
  textTheme: GoogleFonts.robotoTextTheme(const TextTheme()),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
