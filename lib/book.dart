import 'package:flutter/widgets.dart';

class Book{
  String? name;
  int? nOfPages, rating;
  Book.empty({name = '', nOfPages = 0, rating = 0});
  Book({@required this.name, @required this.nOfPages, @required this.rating});
  @override
  String toString() {
    return '"'+name.toString()   +" - " + nOfPages.toString()+" - " + rating.toString()+'"';
  }
}