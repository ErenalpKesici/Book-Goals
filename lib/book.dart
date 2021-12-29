import 'package:flutter/widgets.dart';

class Book{
  String? name;
  DateTime? date;
  int? nOfPages, rating;
  Book.empty({name = '', nOfPages = 0, rating = 0});
  Book({@required this.name, @required this.date, @required this.nOfPages, @required this.rating});
  @override
  String toString() {
    return '"'+name.toString() +" - " + date.toString()  +" - " + nOfPages.toString()+" - " + rating.toString()+'"';
  }
}