import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:provider/provider.dart';
import 'SelectedBooks.dart';

List<Book> booklist = [
  Book("칼의노래", "김훈", "재밌다",
      "http://image.yes24.com/momo/TopCate0001/kepub/L_81346.jpg"),
  Book("데미안", "헤르만헤세", "재밌다",
      "https://image.aladin.co.kr/product/26/0/cover500/s742633278_1.jpg")
];

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text("새 책 추가하기"),
        ),




    body: Column(
      children: [
    Padding(
    padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
         ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: booklist.length,
             shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(top: 20),
            width: 400,
            height: 200,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Image.network(
                  booklist[index].cover,
                  width: 150,
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            booklist[index].title,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            booklist[index].author,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            booklist[index].info,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        })
            ]
        )
    )
      ],
    )
    );
  }
}
