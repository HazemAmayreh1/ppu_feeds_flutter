import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projectppufeeds/section_details_page.dart';

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  List<dynamic> courses = [];
  final _storage = FlutterSecureStorage();
  Map<String, dynamic>? userProfile;

  int _selectedIndex = 1; // Set default to the Feeds page index

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = json.decode(response.body)['courses'];
        });
      } else {
        throw Exception('Failed to load courses. Status: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load courses. $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String getCourseImage(String courseName) {
    switch (courseName) {
      case 'Object Oriented Programming':
        return 'assets/course_images/object_oriented_programming.png';
      case 'Mobile Applications Developments':
        return 'assets/course_images/mobile_app_development.png';
      case 'Data Structures':
        return 'assets/course_images/data_structures.png';
      case 'Database Programming':
        return 'assets/course_images/database_programming.png';
      case 'Operating Systems':
        return 'assets/course_images/operating_systems.png';
      default:
        return 'assets/course_images/default_course_image.png'; 
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/subscriptions');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text(
          'Available Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            if (userProfile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    title: Text(
                      userProfile!['name'] ?? 'No Name',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      userProfile!['email'] ?? 'No Email',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: courses.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        var course = courses[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to CourseSectionPage on tapping the course card
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseSectionPage(courseId: course['id']),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display course image
                                    Image.asset(
                                      getCourseImage(course['name']),
                                      width: 450,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      course['name'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      course['college'] ?? 'No college specified',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed, size: 28),
            label: 'Feeds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions, size: 28),
            label: 'subscriptions',
          ),
        ],
      ),
    );
  }
}
