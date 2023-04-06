import 'package:epub_view/epub_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/Viewer/Viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SelectedBooks.dart';
import 'package:flutter/widgets.dart' as wid;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image;
import 'package:shakespeare/system.dart';

List<String> bookPath = [];
late Future<List<Book>> booklist;
bool intialize = false;

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {



  void start() {}

  @override
  Widget build(BuildContext context) {
    //밑에 세줄은 provider로 이미 저장되어있던 책들을 불러와 리스트를 만드는 과정이다.
    bookListProvider bookListPV = Provider.of<bookListProvider>(context);
    SharedPreferencesProvider userDataPV =
        Provider.of<SharedPreferencesProvider>(context);
    booklist = makeBookList(userDataPV.userdata.getStringList('bookPath')!, bookListPV);


    return FutureBuilder(
        future: booklist,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              // hasData
              return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: Icon(Icons.add), // 햄버거버튼 아이콘 생성
                      onPressed: () async {
                        // 아이콘 버튼 실행
                        print('menu button is clicked');
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          File file = File(result.files.single.path.toString());
                          bookPath=userDataPV.userdata.getStringList('bookPath')!;
                          if (bookPath.contains(file.path.toString())) {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('중복 확인'),
                                content: const Text('이미 리스트에 존재하는 책입니다.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('확인'),
                                  ),
                                ],
                              ),
                            );
                            setState(() {});
                          } else {
                            String newPath=file.path.toString();
                            saveBookPath(newPath, userDataPV.userdata);
                            addBookToPv(newPath, bookListPV);
                            setState(() {});
                          }
                        } else {
                          // User canceled the picker
                        }
                      },
                    ),
                    title: Text("새 책 추가하기"),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        color: Colors.white,
                        onPressed: () async{
                          bookListPV.clearBook();
                          clearUserData(userDataPV.userdata);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListView.builder(
                                    padding: const EdgeInsets.all(20),
                                    itemCount: bookListPV.bookList.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Viewer(openBookPath: File(userDataPV.userdata.getStringList('bookPath')![index]))));
                                        },
                                        child: Column(
                                          children: [
                                          Row(
                                          children: [
                                            wid.Image.asset(
                                              bookListPV.bookList[index].cover,
                                              width: 115,
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        bookListPV
                                                            .bookList[index]
                                                            .title,
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        bookListPV
                                                            .bookList[index]
                                                            .author,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        bookListPV
                                                            .bookList[index]
                                                            .info,
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                            Container(
                                              height: 15,
                                            )
                                          ],
                                        ),
                                      );

                                    })
                              ])),

                    ],
                  ));
            }
          } else {
            return const Center(
              child: Text('No data found'),
            );
          }
        }));
  }
}

Future<List<Book>> makeBookList(
    List<String> bookPath, bookListProvider bookListPV) async {

  return bookListPV.bookList;
}

void saveBookPath(String bookP, SharedPreferences prefs) {
  List<String>? temppaths= prefs.getStringList('bookPath');
  temppaths?.add(bookP);
  prefs.setStringList('bookPath', temppaths!);
}

void clearUserData(SharedPreferences prefs) {
  List<String> temppaths= [];
  prefs.setStringList('bookPath', temppaths);
}



Future<List<Book>> addBookToPv(String bookPath, bookListProvider bookListPV) async {
  Book abook;
  String coverstr = 'assets/samplecover.jpg';

  var targetFile = new File(bookPath);
  List<int> bytes = targetFile.readAsBytesSync();
// Opens a book and reads all of its content into memory

  EpubBook epubBook = await EpubReader.readBook(bytes);
  String info = "very fun";
  String? title = epubBook.Title;
  String? author = epubBook.Author;
  image.Image? cover = epubBook.CoverImage;
  if (File('location/' + title.toString() + '.png').existsSync()) {
    print("File exists");
  } else {
    if (cover != null) {
      File('location/' + title.toString() + '.png')
          .writeAsBytesSync(image.encodePng(cover!));
      coverstr = 'location/' + title.toString() + '.png';
    } else {
      print("Error Saving Cover Image");
      coverstr = 'assets/samplecover.jpg';
    }
  }
  abook = Book(title!, author!, info, coverstr, bookListPV.bookList.length);
  bookListPV.addBook(abook);

  return bookListPV.bookList;
}
