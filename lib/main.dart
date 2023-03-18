import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:provider/provider.dart';
import 'BookList.dart';
import 'SelectedBooks.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>SelectedBook())
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
        '/Milk': (context) => const MilkPage(),
        '/SweetCoffee': (context) => const SweetCoffeePage(),
        '/CoffeeAgain': (context) => const CoffeeAgainPage(),
        '/Result': (context) => const ResultPage(),*/
      },
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
