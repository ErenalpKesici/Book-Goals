import 'package:flutter/widgets.dart';

class Book{
  String? title;
  List<String>? categories, authors;
  DateTime? date, datePublished;
  int? nOfPages, rating;
  Book.empty(){
    title='';
    categories = List.empty(growable: true);
    authors = List.empty(growable: true);
    date=DateTime.now();
    datePublished=DateTime.now();
    nOfPages=0;
    rating=5;
  }
  Book({@required this.title, @required this.categories, @required this.authors, @required this.date, @required this.nOfPages, @required this.rating, @required this.datePublished});
  Book.fromJson(Map<String, dynamic> json): 
    title = json['title'],
    categories = json['categories'], 
    authors = json['authors'],
    date = json['date'],
    datePublished = json['datePublished'], 
    nOfPages = json['nOfPages'],
    rating = json['rating'];
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'categories': categories.toString(),
      'authors': authors.toString(),
      'date': date.toString(),
      'datePublished': datePublished.toString(),
      'nOfPages': nOfPages,
      'rating': rating,
    };
  }
  @override
  String toString() {
    return '"'+title.toString() + ((authors == null || authors!.isEmpty)?'':' by ' +authors!.first) + ', published on ' + datePublished.toString()+'"';
  }
}