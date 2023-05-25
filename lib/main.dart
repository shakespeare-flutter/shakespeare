import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BookList.dart';
import 'SelectedBooks.dart';
import 'epub_view_enhanced.dart';
import 'system.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/widgets.dart' as wid;
import 'SelectedBooks.dart';

/*sharedpreferenc란, 핸드폰의 간단한 내부저장소 느낌.
추가된 책의 경로들(string)을 string list를 저장해두고,
메인화면 로딩에서 그 리스트들을 불러와, 그걸 기반으로 책(selectedbooks에
 선언한 class) 리스트 provider(어플 내내 손쉽게
 접근할 수 있는 일종의 전역변수 같은 것. 어떤화면에서도 접근하기 용의함)를 만든다.
 즉, 초기화 한다.
 */
late SharedPreferences pref;

List<String> bookPath = [];

//메인함수
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();
  if(!pref.containsKey('bookPath')){
    await pref.setStringList('bookPath', <String>[]);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>bookListProvider()),
        ChangeNotifierProvider(create: (_)=>SharedPreferencesProvider()),
        ChangeNotifierProvider(create: (_)=>MusicProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SharedPreferencesProvider userDataPV = Provider.of<SharedPreferencesProvider>(context);
    userDataPV.intializeUserData(pref);
    bookListProvider bookListPV = Provider.of<bookListProvider>(context);

    bookPath = userDataPV.userdata.getStringList('bookPath')!;
    initBookList(bookPath, bookListPV,userDataPV);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        //'/': (context) => const MyHomePage(),
        '/': (context) => const BookList(),
        // '/RestaurantInfo': (context) => const RestaurantInfoPage(),
        // '/RestaurantList': (context) => const RestaurantListPage(),
        // '/Map': (context) => const MapPage(),
        /*
        '/RestaurantList': (context) => const RestaurantListPage(),
        '/JuiceOrLatte': (context) => const JuiceOrLattePage(),
       */
      },
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


Future<void> initBookList(
    List<String> bookPath, bookListProvider bookListPV,SharedPreferencesProvider userDataPV) async {
  Book abook;
  String coverstr = 'assets/samplecover.jpg';
  for (int i = 0; i < bookPath.length; i++) {
    var targetFile = new File(bookPath[i]);
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
    if(!pref.containsKey(title!+'bookmarks')){
      await pref.setStringList(title!+'bookmarks', <String>[]);
      bookMark=pref.getStringList(title!+'bookmarks');
    }
    else {
      bookMark=pref.getStringList(title!+'bookmarks');
    }
    if(!pref.containsKey(title!+'isInServer')){
      await pref.setBool(title!+'isInServer', false);
      isInServer=pref.getBool(title!+'isInServer');
    }
    else {
      isInServer=pref.getBool(title!+'isInServer');
    }
    if(!pref.containsKey(title!+'id')){
      await pref.setString(title!+'id', '');
      id=pref.getString(title!+'id');
    }
    else {
      id=pref.getString(title!+'id');
    }

    abook = Book(title!, author!, info, coverstr, bookMark!,i,isInServer!,id!);
    bookListPV.addBook(abook);
  }
}