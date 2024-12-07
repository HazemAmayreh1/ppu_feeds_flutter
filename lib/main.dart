import 'package:flutter/material.dart';
import 'course_feed_page.dart';
import 'subscribe_course_page.dart';
import 'login_page.dart';
import 'feeds_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PPU Feeds App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.grey[800],
          textTheme: ButtonTextTheme.primary,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => MyHomePage(), 
        '/feeds': (context) => FeedsPage(),
        '/courseFeed': (context) {
          final courseId = ModalRoute.of(context)!.settings.arguments as int;
          return CourseFeedPage(courseId: courseId);
        },
        '/subscriptions': (context) => SubscriptionsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

 
  final List<Widget> _pages = [
    HomePage(),
    SubscriptionsPage(),
    
    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          // Add more items as needed
        ],
      ),
    );
  }
}
