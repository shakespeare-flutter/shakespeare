
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:shakespeare/SpotifyAPi/music.dart';
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
  void clearBookAll(){
    _bookList.clear();
  }
  void clearBook(int index){
    _bookList.removeAt(index);
  }


}

class MusicProvider with ChangeNotifier{
  String _music=''; //stream url 담김
  String ENG='',KOR='',GENRE='',TEMPO='',MOOD='',INSTRUMENT='';
  String get music => _music;
  bool musicLock=false;
  String mention = '';
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
    if(!musicLock) {
      MusicPlayer.instance.play(music);
    }
  }

  void update(){
    if(!musicLock) {
    mention = '음악 변경됨.';
    notifyListeners();
    }
  }



  void playMusic(){
    if(!musicLock) {
      MusicPlayer.instance.play(music);
    }
  }


  void voidMusic(){ //음악비우기
    MusicPlayer.instance.pause();
    mention='';
    notifyListeners();
  }

  void lock(){
    musicLock=true;
    mention='';
    MusicPlayer.instance.pause();
    notifyListeners();
  }

  void unLock(){
    musicLock=false;
    notifyListeners();
    MusicPlayer.instance.play(music);
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