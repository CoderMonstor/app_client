import 'package:client/core/theme/theme_mode.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier{
  //initially, set it as light mode
  ThemeData _themeData =lightMode;

  //get the current theme
  ThemeData get themeData =>_themeData;


  //is it dark mode currently?
  bool get isDarkMode =>_themeData==darkMode;

  //set the theme
  set themeData(ThemeData themeData){
    _themeData=themeData;

    //update UI
    notifyListeners();
  }

  //toggle between dark & light mode
  void toggleTheme(){
    if(_themeData==lightMode){
      themeData=darkMode;
    }else{
      themeData=lightMode;
    }
  }

}