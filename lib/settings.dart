import 'package:flutter/material.dart';

import 'book.dart';

class Settings{
  int? goalBooks, goalDuration;
  String? goalDurationType;
  List<Book>? books = List.empty(growable: true);
  Settings({@required this.goalBooks, @required this.goalDuration, @required this.goalDurationType, this.books});
  Settings.empty({this.goalBooks = 0, this.goalDuration=0, this.goalDurationType = '',});
  Settings.fromJson(Map<String, dynamic> json): 
    goalBooks = json['goalBooks'],
    goalDuration = json['goalDuration'], 
    goalDurationType = json['goalDurationType'],
    books = json['books'];
  Map<String, dynamic> toJson() {
    return {
      'goalBooks': goalBooks.toString(),
      'goalDuration': goalDuration.toString(),
      'goalDurationType': goalDurationType,
      'books': books,
    };
  }
  @override
  String toString() {
    return books!.length.toString() +"/" + goalBooks.toString()+" in " + goalDuration.toString() + " " + goalDurationType.toString() +" : " + books.toString();
  }
}