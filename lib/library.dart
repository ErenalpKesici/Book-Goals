import 'package:flutter/material.dart';

import 'book.dart';

class Library{
  Book? book;
  String? message;
  Library({@required this.book, @required this.message});
  Library.empty();
  Library.fromJson(Map<String, dynamic> json): 
    book = json['book'],
    message = json['message'];
  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'message': message,
    };
  }
}