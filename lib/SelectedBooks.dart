import 'package:flutter/material.dart';


class SelectedBook with ChangeNotifier{
  List<String> _shoplist =["kimchi"];
  List<String> get shoplist => _shoplist;

  void addshop(var shop){
    _shoplist.add(shop);
    notifyListeners();
  }

  void removeshop(var shop){
    _shoplist.remove(shop);
    notifyListeners();
  }

}

class Book{
  String title,author,info,cover;
  Book(this.title, this.author, this.info,this.cover);
}