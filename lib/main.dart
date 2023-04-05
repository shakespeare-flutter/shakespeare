import 'dart:io';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BookList.dart';
import 'SelectedBooks.dart';
import 'system.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/widgets.dart' as wid;
import 'SelectedBooks.dart';


late SharedPreferences pref;
List<String> bookPath = [];

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
        ChangeNotifierProvider(create: (_)=>bookPathProvider()),
        ChangeNotifierProvider(create: (_)=>SharedPreferencesProvider())
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
    initBookList(bookPath, bookListPV);

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
    List<String> bookPath, bookListProvider bookListPV) async {
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
    abook = Book(title!, author!, info, coverstr, i);
    bookListPV.addBook(abook);
  }
}