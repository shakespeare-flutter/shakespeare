import 'package:flutter/material.dart';
import 'package:image/image.dart';

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

class bookPathProvider with ChangeNotifier{
  List<String> _bookPathList =[];
  List<String> get bookPathList => _bookPathList;

  void addBookP(var shop){
    _bookPathList.add(shop);
    notifyListeners();
  }

  void addBookPL(List<String> path){
    _bookPathList=path;
    notifyListeners();
  }


  void removeBookP(var shop){
    _bookPathList.remove(shop);
    notifyListeners();
  }
}

class Book{
  String title,author,info,cover;
  List<String> bookmark;
  int idx;
  Book(this.title, this.author, this.info,this.cover,this.bookmark,this.idx);
}