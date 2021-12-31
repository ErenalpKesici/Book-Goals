import 'package:flutter/material.dart';

import 'book.dart';

class BookDetailsPageSend extends StatefulWidget{
  final Book? book;
  const BookDetailsPageSend(this.book);

  @override
  State<StatefulWidget> createState() {
    return BookDetailsPage(book!);
  }
}
class BookDetailsPage extends State<BookDetailsPageSend>{
  Book book = Book.empty();
  BookDetailsPage(this.book);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title!),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(book.imgUrl!='')
                Image.network(book.imgUrl!),
              ListTile(
                leading: Icon(Icons.title),
                title: Text(book.title!, textAlign: TextAlign.center,),
              ),
              if(book.authors!.isNotEmpty && book.authors![0] != '')
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text(book.authors!.toString(), textAlign: TextAlign.center,),
                ),
              if(book.categories!.isNotEmpty && book.categories![0] != '')
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text(book.categories!.toString(), textAlign: TextAlign.center,),
                ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text(DateUtils.dateOnly(book.datePublished!).toString(), textAlign: TextAlign.center,),
              ),
              if(book.nOfPages != null)
                ListTile(
                  leading: Icon(Icons.pages),
                  title: Text(book.nOfPages!.toString(), textAlign: TextAlign.center,),
                ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text(book.rating!.toString(), textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}