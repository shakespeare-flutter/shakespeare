import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/SelectedBooks.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/widgets.dart' as wid;
import 'package:shakespeare/SpotifyAPi/music.dart';

import '../epub_view_enhanced.dart';
import '../system.dart';

class Viewer extends StatefulWidget {
  const Viewer(
      {Key? key,
      required this.openBookPath,
      required this.bookTitle,
      required this.responseBody})
      : super(key: key);
  final File openBookPath;
  final String bookTitle;
  final List<dynamic> responseBody;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with WidgetsBindingObserver {
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
    String bookName = widget.bookTitle + 'bookmarks';
    List<String>? temp1 = userDataPV.userdata.getStringList(bookName);
    Future<List<String>> bookMarks = updateBookMark(temp1!);
    MusicProvider musicPV = Provider.of<MusicProvider>(context);
    void _openEndDrawer() {
      _scaffoldKey.currentState!.openEndDrawer();
    }

    void _closeEndDrawer() {
      Navigator.of(context).pop();
    }

    return wid.WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75,
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          key: _scaffoldKey,
          title: AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(musicPV.mention),
              FadeAnimatedText('')
            ],
            totalRepeatCount: 1,
            onTap: () {
              print("Tap Event");
            },
          ),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.bookmark_border_outlined),
                color: Colors.black,
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
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(FullScreenModal());
                }),
            IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.black,
                onPressed: () {
                  MusicPlayer.instance.pause();
                  musicPV.voidMusic();
                  Navigator.pop(context);
                  setState(() {});
                }),
          ],
        ),
        drawer: Drawer(
          child: EpubViewTableOfContents(controller: _epubReaderController),
        ),

        endDrawer: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                height: 60.0,
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        child: Text(
                      "bookmarks",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    )),
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: 30,
                        color: Colors.black,
                        onPressed: () {
                          _closeEndDrawer();
                        }),
                  ],
                ),
              ),
              FutureBuilder(
                  future: bookMarks,
                  // a previously-obtained Future<String> or null
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return Expanded(
                            child: ListView.builder(
                          itemCount: (userDataPV.userdata
                                  .getStringList(widget.bookTitle + 'bookmarks')
                                  ?.length)! +
                              1,
                          itemBuilder: (BuildContext context, int index) {
                            if ((index <
                                    (userDataPV.userdata
                                        .getStringList(
                                            widget.bookTitle + 'bookmarks')
                                        ?.length)!) &&
                                (0 !=
                                    userDataPV.userdata
                                        .getStringList(
                                            widget.bookTitle + 'bookmarks')
                                        ?.length)) {
                              return Dismissible(
                                  key: Key(userDataPV.userdata.getStringList(
                                      widget.bookTitle + 'bookmarks')![index]),
                                  onDismissed: (direction) {
                                    List<String>? tempStr = userDataPV.userdata
                                        .getStringList(
                                            widget.bookTitle + 'bookmarks');
                                    tempStr?.removeAt(index);
                                    userDataPV.userdata.setStringList(
                                        widget.bookTitle + 'bookmarks',
                                        tempStr!);
                                  },
                                  child: InkWell(
                                      onTap: () {
                                        _epubReaderController.gotoEpubCfi(
                                            userDataPV.userdata.getStringList(
                                                widget.bookTitle +
                                                    'bookmarks')![index]);
                                      },
                                      child: Container(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                Icon(Icons.bookmark, size: 30),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 40),
                                                    height: 80.0,
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          cfiToBookmarkC(userDataPV
                                                                      .userdata
                                                                      .getStringList(
                                                                          widget.bookTitle +
                                                                              'bookmarks')![
                                                                  index]) +
                                                              ' - ' +
                                                              cfiToBookmarkI(userDataPV
                                                                  .userdata
                                                                  .getStringList(
                                                                      widget.bookTitle +
                                                                          'bookmarks')![index]),
                                                          style: TextStyle(
                                                              fontSize: 30),
                                                        ))),
                                              ]),
                                              /*Container(
                                      height: 30.0,
                                      child: Text(
                                        'Index : '+cfiToBookmarkI(userDataPV.userdata.getStringList(widget.bookTitle+'bookmarks')![index]),
                                        style: TextStyle(fontSize: 25),
                                      )
                                  ),
                                  Container(
                                      child: Divider(color: Colors.red, thickness: 2.0))*/
                                            ]),
                                      )));
                            }
                            if (index ==
                                (userDataPV.userdata
                                    .getStringList(
                                        widget.bookTitle + 'bookmarks')
                                    ?.length)!) {
                              return Container(
                                  height: 60.0,
                                  width: 100.0,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.black,
                                    onPressed: () {
                                      String? newCfi = _epubReaderController
                                          .generateEpubCfi();
                                      List<String>? temppaths = userDataPV
                                          .userdata
                                          .getStringList(bookName);
                                      temppaths?.add(newCfi!);
                                      userDataPV.userdata
                                          .setStringList(bookName, temppaths!);
                                      setState(() {});
                                    },
                                  ));
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
                              String? newCfi =
                                  _epubReaderController.generateEpubCfi();
                              List<String>? temppaths =
                                  userDataPV.userdata.getStringList(bookName);
                              temppaths?.add(newCfi!);
                              userDataPV.userdata
                                  .setStringList(bookName, temppaths!);
                              setState(() {});
                            },
                          ));
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
            musicPV: musicPV),
      ),
      onWillPop: () async {
        MusicPlayer.instance.pause();
        musicPV.voidMusic();
        Navigator.pop(context);
        return false;
      },
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
              setState(() {});
            },
          ),
        ),
      );
    }
  }
}

Future<List<String>> updateBookMark(List<String> bookMark) async {
  return bookMark;
}

void clearUserData(SharedPreferencesProvider prefs, String booktitle) {
  List<String> temppaths = [];
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
    MusicProvider musicPV2 =
        Provider.of<MusicProvider>(context); //widget 내부에 이처럼 정의
    String musicName = musicPV2.ENG; // 업데이트된 클래스 사용

    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            MusicMetaData(musicPV2: musicPV2),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (musicPV2.musicLock == false) ...{
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(fixedSize: const Size(150,60)
                    ,side: BorderSide(color: Colors.white, width: 5),),
                    onPressed: () {
                      musicPV2.lock();
                    }, child: Text('MUTE',style: TextStyle(color: Colors.white,fontSize: 20))
                  )
                } else ...{
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(fixedSize: const Size(150,60)
                      ,side: BorderSide(color: Colors.white, width: 5),),
                    onPressed: () {
                      musicPV2.unLock();
                    },child: Text('UNMUTE',style: TextStyle(color: Colors.white,fontSize: 20))
                  )
                }
              ],
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
