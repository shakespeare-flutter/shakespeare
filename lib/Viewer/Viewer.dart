import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/SelectedBooks.dart';
import 'dart:async';
import 'package:epub_view_enhanced/epub_view_enhanced.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/widgets.dart' as wid;
import 'package:shakespeare/SpotifyAPi/music.dart';

import '../system.dart';


class Viewer extends StatefulWidget {
  const Viewer({Key? key, required this.openBookPath, required this.bookTitle, required this.responseBody})
      : super(key: key);
  final File openBookPath;
  final String bookTitle;
  final List<dynamic> responseBody;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer>with WidgetsBindingObserver {
  late EpubController _epubReaderController;
  late String openedBook;
  //final ValueNotifier<String> counterValueNotifier;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(widget.openBookPath),
      epubCfi:
           'epubcfi(/6/0[pgepubid00016]!/4/2[pgepubid00004]/2)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    SharedPreferencesProvider userDataPV =
        Provider.of<SharedPreferencesProvider>(context);
    String bookName=widget.bookTitle+'bookmarks';
    List<String>? temp1=userDataPV.userdata.getStringList(bookName);
    Future<List<String>> bookMarks=updateBookMark(temp1!);
    void _openEndDrawer() {
      _scaffoldKey.currentState!.openEndDrawer();
    }

    void _closeEndDrawer() {
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        key: _scaffoldKey,
        title: EpubViewActualChapter(
          controller: _epubReaderController,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        actions: <Widget>[
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.bookmark_border_outlined),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
                //_showCurrentEpubCfi(context);
                /*String? newCfi=_epubReaderController.generateEpubCfi();
                List<String>? temppaths= userDataPV.userdata.getStringList(bookName);
                temppaths?.add(newCfi!);
                userDataPV.userdata.setStringList(bookName, temppaths!);
                setState(() {});*/
              },
            );
          }),
          IconButton(
              icon: const Icon(Icons.music_note),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(FullScreenModal());
              }),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
              onPressed: () {

                Navigator.pop(context);
                setState(() {});
              }
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubReaderController),
      ),

      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.orange,
              height: 65.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(4.0),
                      width: 100.0,
                      child: Text(
                        "북마크",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      )),
                ],
              ),
            ),

               FutureBuilder(
                future: bookMarks, // a previously-obtained Future<String> or null
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return Expanded(child: ListView.builder(
                          itemCount: (userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')?.length)!+1,
                          itemBuilder: (BuildContext context, int index) {
                            if((index<(userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')?.length)!)&&
                                (0!=userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')?.length)) {
                              return InkWell(
                                  onTap: () {
                                    _epubReaderController.gotoEpubCfi(userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')![index]);
                                  },
                                child: Container(
                                  color: Colors.blue,
                                  height: 57.0,
                                  width: 100.0,
                                  child: Text(
                                    userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')![index],
                                    style: TextStyle(fontSize: 18),
                                  )
                                )
                              );
                            }
                            if(index==(userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')?.length)!) {
                              return Container(
                                  color: Colors.green,
                                  height: 57.0,
                                  width: 100.0,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.orange,
                                    onPressed: () {
                                      String? newCfi=_epubReaderController.generateEpubCfi();
                                      List<String>? temppaths= userDataPV.userdata.getStringList(bookName);
                                      temppaths?.add(newCfi!);
                                      userDataPV.userdata.setStringList(bookName, temppaths!);
                                      setState(() {});
                                    },
                                  )

                              );
                            }
                          },
                        ));
                      }
                    } else {
                      return Container(
                          color: Colors.green,
                          height: 57.0,
                          width: 100.0,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            color: Colors.orange,
                            onPressed: () {
                              String? newCfi=_epubReaderController.generateEpubCfi();
                              List<String>? temppaths= userDataPV.userdata.getStringList(bookName);
                              temppaths?.add(newCfi!);
                              userDataPV.userdata.setStringList(bookName, temppaths!);
                              setState(() {});
                            },
                          )

                      );
                    }
                  }))

          ],
        ),
      ),
      // Disable opening the end drawer with a swipe gesture.
      endDrawerEnableOpenDragGesture: false,

      body: EpubView(
        controller: _epubReaderController,
        jsonBody: widget.responseBody,
      ),
    );
  }

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi()!;


    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController.gotoEpubCfi(cfi);
              setState(() {

              });
            },
          ),
        ),
      );
    }
  }
}

Future<List<String>> updateBookMark(
    List<String> bookMark) async {

  return bookMark;
}

void clearUserData(SharedPreferencesProvider prefs,String booktitle) {
  List<String> temppaths= [];
  prefs.userdata.setStringList(booktitle, temppaths);
}

class FullScreenModal extends ModalRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.6);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  // TODO: MUSIC PLAYER
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            MusicMetaData(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [MusicControlButton(), NextMusicButton()],
            )
          ])),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        // add scale animation
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }
}
