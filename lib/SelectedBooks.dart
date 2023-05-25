
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:shakespeare/system.dart';

class bookListProvider with ChangeNotifier{
  List<Book> _bookList =[];
  List<Book> get bookList => _bookList;
  void addBook(var shop){
    _bookList.add(shop);
  }
  void removeBook(var shop){
    _bookList.remove(shop);
  }
  void clearBook(){
    _bookList.clear();
  }
}

class MusicProvider with ChangeNotifier{
  String _music=''; //stream url 담김
  String ENG='',KOR='',GENRE='',TEMPO='',MOOD='',INSTRUMENT='';
  String get music => _music;
  void updateMusic(var shop,String ENGI,String KORI,String GENREI,String TEMPOI,
      String MOODI,String INSTRUMENTI){ //음악 바뀔때마다 음악 정보 업데이트 됨
    _music=shop;
    KOR=KORI;
    ENG=ENGI;
    GENRE=GENREI;
    TEMPO=TEMPOI;
    MOOD=MOODI;
    INSTRUMENT=INSTRUMENTI;
    notifyListeners();
  }
}

class currentMusic{
  String _musicstream='';
  String ENG='',KOR='',GENRE='',TEMPO='',MOOD='',INSTRUMENT='';
  String get music => _musicstream;
  void updateMusic(var musicstream,String ENGI,String KORI,String GENREI,String TEMPOI,
      String MOODI,String INSTRUMENTI){
    _musicstream=musicstream;
    KOR=KORI;
    ENG=ENGI;
    GENRE=GENREI;
    TEMPO=TEMPOI;
    MOOD=MOODI;
    INSTRUMENT=INSTRUMENTI;
  }
}

class Data{
  String cfi,color,weather;
  Map<String, dynamic> emotion;

  Data(this.cfi,this.emotion,this.color,this.weather);

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(json['cfi'] as String, json['emotion'] as Map<String, dynamic>,json['color'] as String,json['weather'] as String,);
  }
  Map<String, dynamic> toJson() => {
    'cfi': cfi,
    'emotion': emotion,
    'color' : color,
    'weather' : weather
  };
}


class Book{
  String title,author,info,cover;
  bool isExistInServer;
  List<String> bookmark;
  List<dynamic> analyzedData=[];
  String responseBody='';
  int idx;
  Map analyzedMap={};
  String id;
  Book(this.title, this.author, this.info,this.cover,this.bookmark,this.idx,this.isExistInServer,this.id);
}