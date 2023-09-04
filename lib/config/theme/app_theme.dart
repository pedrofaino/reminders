import 'package:flutter/material.dart';

const Color whiteSmoke = Color(0xFFF5F5F5);
const Color secondary = Color(0xFFBCDFDF);
const Color customColor5 = Color(0xFFd5c7bc);
const Color customColor6 = Color(0xFFDEE8D5);
const Color customColor2 = Color(0xFF879EA9);
const Color customColor3 = Color(0xFF182847);
const Color customColor4 = Color(0xFF727A84);

const List <Color> _colorThemes = [
  secondary,
  customColor2,
  customColor3,
  customColor4,
  customColor5,
  customColor6,
  whiteSmoke,
  Colors.orange,
  Colors.yellow
];

class AppTheme {
  final int selectedColor;

  AppTheme({
    this.selectedColor = 1
  }):assert(selectedColor >= 0 && selectedColor <= _colorThemes.length - 1,'Colors must be between 0 and ${_colorThemes.length}');

  ThemeData theme(){
    return  ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
    );
  }
}