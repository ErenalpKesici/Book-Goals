import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListBookPageSend extends StatefulWidget{
  const ListBookPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListBookPage();
  }
}
class ListBookPage extends State<ListBookPageSend>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books Read"),
      ),
      body: ListView.builder(itemCount: save.books.length, itemBuilder: (builder, idx){
        return SizedBox(
          height: 100, 
          child: 
            Card(elevation: 1, child: 
              ListTile(
                leading: Text(save.books[idx].name!),
                trailing: Text(save.books[idx].rating.toString()+" stars"),
              ),
            )
        );
      }),
    );
  }

}