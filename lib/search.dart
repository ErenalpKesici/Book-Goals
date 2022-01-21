import 'package:book_goals/library.dart';
import 'package:flutter/material.dart';

import 'book.dart';
import 'book_action_details.dart';
import 'book_details.dart';
import 'helper_functions.dart';
import 'main.dart';

class SearchPageSend extends StatefulWidget {
  SearchPageSend();
  @override
  State<StatefulWidget> createState() {
    return SearchPage();
  }
}
class SearchPage extends State<SearchPageSend>{
  int currentNavIdx = 1;
  TextEditingController tecQuery = TextEditingController(text: '');
  List<Book> booksFound = List.empty(growable: true);
  Future? futureTitles;
  List<String> bookAction = List.empty();
  @override
  void initState() {
    futureTitles = queryBooks(tecQuery.text);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    FocusNode? focusNode;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIdx,
        onTap: (int idx){
          if(currentNavIdx != idx) {
            setState(() {
              updateNav(idx, currentNavIdx, context);
            });
          }
        },
        items: getNavs(),
      ),
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              focusNode: focusNode,
              controller: tecQuery,
               decoration: InputDecoration(labelText: 'Book Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
              onChanged: (String? value){
                setState(() {
                  futureTitles = queryBooks(tecQuery.text);
                });
              },
            ),
          ),
          FutureBuilder(
            future: futureTitles,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
              if(snapshot.hasData) {
                bookAction = List.filled(snapshot.data.length, '');
                return Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          Book book = snapshot.data[index];
                          if(book.title == null)return Container();
                          return Card(
                            child: ListTile(
                              minVerticalPadding: 10,
                              isThreeLine: true,
                              title: Text(book.title!),
                              subtitle: Text(book.authors!.isNotEmpty==true?book.authors!.first:''),
                              onTap: (){
                                focusNode?.unfocus();
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BookActionDetailsPageSend(book)));
                              },
                            ),
                          );
                        },
                        itemCount: snapshot.data.length,
                      );
                    },
                  ),
                );
              }
              else{
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
      drawer: getDrawer(context),
    );
  }
}