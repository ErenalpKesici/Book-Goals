import 'package:flutter/material.dart';

import 'book.dart';

class ImageDetailsSend extends StatefulWidget {
  final Book book;
  ImageDetailsSend(this.book);

  @override
  State<StatefulWidget> createState() {
    return ImageDetails(book);
  }
}

class ImageDetails extends State<ImageDetailsSend> {
  final Book book;
  ImageDetails(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Hero(
            tag: book.id!,
            child: InteractiveViewer(
              minScale: 1,
              child: Image.network(
                book.imgUrl!,
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
