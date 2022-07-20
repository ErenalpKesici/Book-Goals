import 'package:book_goals/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'helper_functions.dart';
import 'book.dart';

class AddBookPageSend extends StatefulWidget {
  const AddBookPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBookPage();
  }
}

class AddBookPage extends State<AddBookPageSend> {
  TextEditingController tecBookNOfPages = TextEditingController(text: '');
  int? rating = 5;
  List<Color> starColors = List.filled(5, Colors.yellow);
  Book bookSelected = Book.empty();
  List<Book>? books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Book as Read"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Autocomplete<String>(
                    onSelected: (String selected) {
                      bookSelected = books!
                          .firstWhere(((element) => element.title == selected));
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                            labelText: 'Book Title',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onFieldSubmitted: (String value) {
                          focusNode.unfocus();
                        },
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      bookSelected.title = textEditingValue.text;
                      books = await queryBooks(textEditingValue.text);
                      if (books!.isNotEmpty) {
                        List<String> ret = List.empty(growable: true);
                        for (Book book in books!) {
                          ret.add(book.title!);
                        }
                        return ret;
                      }
                      return const Iterable.empty();
                    },
                  )),
              if (books != null && books!.isNotEmpty)
                ElevatedButton.icon(
                    onPressed: () {
                      reviewBook(context, bookSelected);
                    },
                    icon: const Icon(Icons.reviews),
                    label: Text('review'.tr())),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              ElevatedButton.icon(
                  onPressed: () async {
                    if (bookSelected.title == '') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context).hintColor,
                          content: const Text(
                              'Please enter the title of the book.')));
                    } else if (!data.goals.last.books!
                        .any((element) => element.id == bookSelected.id)) {
                      data.goals.last.books!.add(bookSelected);
                      writeSave();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context).hintColor,
                          content: const Text("Book already exists.")));
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
                  },
                  icon: const Icon(Icons.task_alt_rounded),
                  label: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
