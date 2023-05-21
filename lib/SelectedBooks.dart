import 'package:epub_view_enhanced/epub_view_enhanced.dart';
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