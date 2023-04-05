import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SharedPreferencesProvider with ChangeNotifier{
  late SharedPreferences _userdata;
  void intializeUserData(var shop){
    _userdata=shop;
  }



  SharedPreferences get userdata => _userdata;
}
