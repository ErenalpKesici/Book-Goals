import 'package:flutter/widgets.dart';

class Book{
  String? id;
  String? title;
  List<String>? categories, authors;
  DateTime? date, datePublished;
  int? nOfPages, rating;
  String? imgUrl;
  Book.empty(){
    id = '';
    title='';
    categories = List.empty(growable: true);
    authors = List.empty(growable: true);
    nOfPages=0;
    rating=5;
    imgUrl = '';
  }
  Book({@required this.id, @required this.title, @required this.categories, @required this.authors, @required this.date, @required this.nOfPages, @required this.rating, @required this.datePublished, @required this.imgUrl});
  Book.fromJson(Map<String, dynamic> json):
    id = json['id'], 
    title = json['title'],
    categories = json['categories'], 
    authors = json['authors'],
    date = json['date'],
    datePublished = json['datePublished'], 
    nOfPages = json['nOfPages'],
    rating = json['rating'],
    imgUrl = json['imgUrl'];
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categories': categories.toString(),
      'authors': authors.toString(),
      'date': date.toString(),
      'datePublished': datePublished.toString(),
      'nOfPages': nOfPages,
      'rating': rating,
      'imgUrl': imgUrl,
    };
  }
  @override
  String toString() {
    return '"'+id.toString()+": " + title.toString() + ((authors == null || authors!.isEmpty)?'':' by ' +authors!.first) + ', published on ' + datePublished.toString()+'"';
  }
}