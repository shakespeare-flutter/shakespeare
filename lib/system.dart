import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SharedPreferencesProvider with ChangeNotifier{
  late SharedPreferences _userdata;
  void intializeUserData(var shop){
    _userdata=shop;
  }



  SharedPreferences get userdata => _userdata;
}

String GcfiParserForSend(String input){
  int slashNum=0;
  int index=0;
  while(slashNum<3){
    if(input[index]=='/'){
      slashNum++;
    }
    index++;
  }
  String output=input.substring(index,input.length-1);

  return output;
}

String ScfiParserForSend(String input){
  int slashNum=0;
  int index=0;
  while(slashNum<3){
    if(input[index]=='/'){
      slashNum++;
    }
    index++;
  }
  String output=input.substring(index,input.length);

  return output;
}

