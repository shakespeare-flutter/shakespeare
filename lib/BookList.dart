import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/Viewer/Viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SelectedBooks.dart';
import 'package:flutter/widgets.dart' as wid;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image;
import 'package:shakespeare/system.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'epub_view_enhanced.dart';

List<String> bookPath = [];
late Future<List<Book>> booklist;
bool waitingTheList = false;

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    //밑에 세줄은 provider로 이미 저장되어있던 책들을 불러와 리스트를 만드는 과정이다.
    bookListProvider bookListPV = Provider.of<bookListProvider>(context);
    SharedPreferencesProvider userDataPV =
        Provider.of<SharedPreferencesProvider>(context);
    booklist = makeBookList(
        userDataPV.userdata.getStringList('bookPath')!, bookListPV);

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
                    toolbarHeight: 100,
                    backgroundColor: Colors.transparent,
                    bottomOpacity: 0.0,
                    elevation: 0.0,
                    leading: IconButton(
                      icon: Icon(Icons.add), // 햄버거버튼 아이콘 생성
                      onPressed: () async {
                        // 아이콘 버튼 실행
                        print('menu button is clicked');
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          File file = File(result.files.single.path.toString());
                          bookPath =
                              userDataPV.userdata.getStringList('bookPath')!;
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
                            String newPath = file.path.toString();
                            saveBookPath(newPath, userDataPV.userdata);
                            await addBookToPv(
                                newPath, bookListPV, userDataPV.userdata);
                            await checkAndAddBookToServer(
                                userDataPV.userdata,
                                userDataPV,
                                bookListPV,
                                bookListPV.bookList.length - 1);
                            setState(() {});
                          }
                        } else {
                          // User canceled the picker
                        }
                      },
                    ),
                    title: Text("새 책 추가하기",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    /*actions: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        color: Colors.black,
                        onPressed: () async {
                          bookListPV.clearBookAll();
                          clearUserDataAll(userDataPV.userdata);
                          setState(() {});
                        },
                      ),
                    ],*/
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
                                      return AnimatedContainer(
                                          duration: const Duration(seconds: 2),
                                          child: InkWell(
                                            onLongPress: (){
                                             showDelete(context, userDataPV.userdata, bookListPV,userDataPV.userdata.getStringList('bookPath')![index], bookListPV
                                                 .bookList[index].title, index);
                                            },

                                            onTap: () async {
                                              String bookTitleSelected =
                                                  bookListPV
                                                      .bookList[index].title;
                                              if (bookListPV
                                                          .bookList[index].id !=
                                                      [] &&
                                                  bookListPV.bookList[index]
                                                          .isExistInServer ==
                                                      true) {
                                                bookListPV.bookList[index]
                                                        .analyzedData =
                                                    await waitingResult(
                                                        bookListPV
                                                            .bookList[index].id,
                                                        bookListPV
                                                            .bookList[index]
                                                            .title);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Viewer(
                                                            openBookPath: File(userDataPV
                                                                    .userdata
                                                                    .getStringList(
                                                                        'bookPath')![
                                                                index]),
                                                            bookTitle:
                                                                bookTitleSelected,
                                                            responseBody: bookListPV
                                                                .bookList[index]
                                                                .analyzedData)));
                                              } else if (bookListPV
                                                      .bookList[index]
                                                      .isExistInServer ==
                                                  true) {
                                                //for test
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Viewer(
                                                            openBookPath: File(userDataPV
                                                                    .userdata
                                                                    .getStringList(
                                                                        'bookPath')![
                                                                index]),
                                                            bookTitle:
                                                                bookTitleSelected,
                                                            responseBody: bookListPV
                                                                .bookList[index]
                                                                .analyzedData)));
                                                /*await bookInfoToServer(bookTitleSelected);
                                                await waitingResult(bookTitleSelected);
                                                saveBookServerBool(bookTitleSelected, userDataPV.userdata);
                                                bookListPV.bookList[index].isExistInServer=true;
                                                setState(() {});*/
                                              } else {}
                                            },
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 115,
                                                      height: 170,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              bookListPV
                                                                  .bookList[
                                                                      index]
                                                                  .cover),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 160,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        15,
                                                                        0,
                                                                        5),
                                                                child: Text(
                                                                  bookListPV
                                                                      .bookList[
                                                                          index]
                                                                      .title,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          25,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              if (bookListPV
                                                                  .bookList[
                                                                      index]
                                                                  .isExistInServer) ...[
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                    bookListPV
                                                                        .bookList[
                                                                            index]
                                                                        .author,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ] else ...[
                                                                Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                30),
                                                                    child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          CircularProgressIndicator(),
                                                                          OutlinedButton(onPressed: (){
                                                                            clearBook(userDataPV.userdata, bookListPV, userDataPV.userdata.getStringList('bookPath')![index],bookListPV.bookList[index].title,index);
                                                                            setState(() {});
                                                                          }, child: Text('작업 취소',style: TextStyle(color: Colors.green),))
                                                                        ]))
                                                              ],
                                                            ]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: 15,
                                                )
                                              ],
                                            ),
                                          ));
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

  Future<void> checkAndAddBookToServer(
      SharedPreferences prefs,
      SharedPreferencesProvider userDataPV,
      bookListProvider bookListPV,
      int index) async {
    bookListPV.bookList[index].id = await bookInfoToServer(
        prefs.getStringList('bookPath')![index],
        bookListPV.bookList[index].title);
    if(bookListPV.bookList[index].id==''){
      Navigator.of(context).pop();
      showServerError(context);
      clearBook(prefs, bookListPV, prefs.getStringList('bookPath')![index],bookListPV.bookList[index].title,index);
      return;
    }
    prefs.setString(
        bookListPV.bookList[index].title + 'id', bookListPV.bookList[index].id);
    bookListPV.bookList[index].analyzedData = await waitingResult(
        bookListPV.bookList[index].id, bookListPV.bookList[index].title);

    prefs.setBool(bookListPV.bookList[index].title + 'isInServer', true);
    bookListPV.bookList[index].isExistInServer = true;

    setState(() {});
  }

  Future<List<Book>> addBookToPv(String bookPath, bookListProvider bookListPV,
      SharedPreferences prefs) async {
    Book abook;
    String coverstr = 'assets/samplecover.jpg';
    var targetFile = new File(bookPath);
    List<int> bytes = targetFile.readAsBytesSync();
// Opens a book and reads all of its content into memory

    EpubBook epubBook = await EpubReader.readBook(bytes);
    String info = "very fun";
    String? title = epubBook.Title;
    String? author = epubBook.Author;

    coverstr = 'assets/samplecover.jpg';

    List<String>? bookMark;
    bool? isInServer;
    String? id;
    await prefs.setStringList(title! + 'bookmarks', <String>[]);
    bookMark = prefs.getStringList(title! + 'bookmarks');
    await prefs.setBool(title! + 'isInServer', false);
    isInServer = prefs.getBool(title! + 'isInServer');
    await prefs.setString(title! + 'id', '');
    id = prefs.getString(title! + 'id');

    abook = Book(title!, author!, info, coverstr, bookMark!,
        bookListPV.bookList.length, isInServer!, id!);
    bookListPV.addBook(abook);
    setState(() {});
    return bookListPV.bookList;
  }

  void showDelete(var context, SharedPreferences prefs, bookListProvider bookListPV,
      String path, String title, int index) {
    showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 50,
                    width: 300,
                    margin: EdgeInsets.fromLTRB(0, 2, 0, 5),
                    child: Center(child: Text('책을 리스트에서 지우겠습니까?'))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      IconButton(
                          onPressed: () {
                            clearBook(prefs, bookListPV, path, title, index);
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.check_circle_outline)),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.cancel_outlined))
                    ]
                )
              ],
            ),
          );
        });
  }


}

Future<List<Book>> makeBookList(
    List<String> bookPath, bookListProvider bookListPV) async {
  return bookListPV.bookList;
}

Future<bool> checkBookInServer() async {
  bool isExist = false;
  String strUrl = CommonUri + "/music_info?id=1";
  String id = 'default';
  var url = Uri.parse(strUrl);
  var response = await http.get(url);
  int result = response.statusCode;
  if (result == 200) {
    isExist = true;
  }
  var decodedJson = json.decode(response.body);
  var decodedJson2 = decodedJson["ENG"];
  return isExist;
}

Future<String> bookInfoToServer(String filePath, String booktitle) async {
  String strUrl = CommonUri + "/book";
  var url = Uri.parse(strUrl);
  var dio = Dio();
  var formData = FormData.fromMap(
      {'book': await MultipartFile.fromFile(filePath, filename: booktitle)});
  var id = '';
  try {
    var response = await dio.post(strUrl, data: formData);
    int? result = response.statusCode;
    Map<String, dynamic> responseMap = response.data;
    id = responseMap['id'];
  } on DioError catch (e) {
    if (e.response?.statusCode == 500) {
      print(e.response?.statusCode);
    } else {
      print(e.message);
    }
  }

  return id;
}

Future<List<dynamic>> waitingResult(String id, String booktitle) async {
  String strUrl = CommonUri + "/book?id=" + id;
  const timeOut = Duration(seconds: 5);
  var url = Uri.parse(strUrl);
  bool isEnd = false;
  List<dynamic> decodedJson2 = [];
  List<Data> listdatas = [];
  while (isEnd == false) {
    var response = await http.get(url);
    int? result = response.statusCode;
    if (result != 200) {
      Logger().d("not yet request data repeat process");
      await Future.delayed(const Duration(milliseconds: 3000));
    } else {
      Map decodedJson = jsonDecode(jsonDecode(response.body));
      decodedJson2 = decodedJson["data"];
      isEnd = true;
      break;
    }
  }

  Logger().d("receive result");

  return decodedJson2;
}

void saveBookPath(String bookP, SharedPreferences prefs) {
  List<String>? temppaths = prefs.getStringList('bookPath');
  temppaths?.add(bookP);
  prefs.setStringList('bookPath', temppaths!);
}

Future<void> saveBookId(
    String title, String id, SharedPreferences prefs) async {
  if (!prefs.containsKey(title! + 'id')) {
    await prefs.setString(title! + id, id);
  }
}

void clearUserDataAll(SharedPreferences prefs) {
  List<String> temppaths = [];
  prefs.setStringList('bookPath', temppaths);
}

void clearBook(SharedPreferences prefs, bookListProvider bookListPV,
    String path, String title, int index) {
  List<String>? temppaths = prefs.getStringList('bookPath');
  int? indexSH = temppaths?.indexOf(path);

  temppaths?.removeAt(indexSH!);
  prefs.setStringList('bookPath', temppaths!);

  prefs.remove(title! + 'bookmarks');
  prefs.remove(title! + 'isInServer');
  prefs.remove(title! + 'id');

  bookListPV.bookList.removeAt(index);
}

void showWaiting(var context) {
  showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                width: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              Container(
                  height: 50,
                  width: 300,
                  margin: EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Center(child: Text('책을 분석중입니다...'))),
            ],
          ),
        );
      });
}

void showServerError(var context) {
  showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: 50,
                  width: 300,
                  margin: EdgeInsets.fromLTRB(0, 2, 0, 5),
                  child: Center(child: Text('통신 에러가 발생했습니다'))),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.check))
            ],
          ),
        );
      });
}


