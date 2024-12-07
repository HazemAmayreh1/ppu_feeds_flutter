import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectppufeeds/display_posts_page.dart';

class CourseSectionPage extends StatefulWidget {
  final int courseId;

  CourseSectionPage({required this.courseId});

  @override
  _CourseSectionPageState createState() => _CourseSectionPageState();
}

class _CourseSectionPageState extends State<CourseSectionPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? token;
  Map<int, bool> subscriptionStatus = {}; // Track subscription status for each section
  Map<int, int> subscriptionIds = {}; // Track subscription IDs for each section

  // Fetch sections and token
  Future<List<Map<String, dynamic>>> fetchSections() async {
    try {
      token = await _storage.read(key: 'session_token');

      if (token == null || token!.isEmpty) {
        throw Exception('Session token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections'),
        headers: {
          'Authorization': ' $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('sections')) {
          return List<Map<String, dynamic>>.from(data['sections']);
        } else {
          throw Exception('No sections found in the API response.');
        }
      } else {
        throw Exception('Failed to load sections. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error fetching sections: $e');
    }
  }

  // Subscribe to a section
  Future<void> subscribeToSection(int sectionId) async {
    try {
      token = await _storage.read(key: 'session_token');

      if (token == null || token!.isEmpty) {
        throw Exception('Session token not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/$sectionId/subscribe'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('subscription_id')) {
          setState(() {
            subscriptionStatus[sectionId] = true;
            subscriptionIds[sectionId] = data['subscription_id']; // Store subscription ID
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully subscribed to section $sectionId!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Subscription ID not found in response.');
        }
      } else {
        throw Exception('Failed to subscribe. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while subscribing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Unsubscribe from a section
  Future<void> removeSubscription(int sectionId) async {
    try {
      token = await _storage.read(key: 'session_token');

      if (token == null || token!.isEmpty) {
        throw Exception('Session token not found. Please log in again.');
      }

      final subscriptionId = subscriptionIds[sectionId];
      if (subscriptionId == null) {
        throw Exception('Subscription ID not found for section $sectionId.');
      }

      final response = await http.delete(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/$sectionId/subscribe/$subscriptionId'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'subscription deleted') {
          setState(() {
            subscriptionStatus[sectionId] = false;
            subscriptionIds.remove(sectionId); 
          });
         
        } else {
          throw Exception('Unexpected response: ${response.body}');
        }
      } else {
        throw Exception('Failed to unsubscribe. Status: ${response.statusCode}');
      }
    } catch (e) {
     
       ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully unsubscribed from section $sectionId!'),
              backgroundColor: Colors.green,
            ),
          );
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
          'Course Sections',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchSections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No sections available.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            } else {
              final sections = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  final sectionId = section['id'];
                  final courseName = section['course'];
                  final isSubscribed = subscriptionStatus[sectionId] ?? false;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 8,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['name'] ?? 'Unnamed Section',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Course: $courseName',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Lecturer: ${section['lecturer'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 8),
                          Text(
                                                    'Section ID: $sectionId',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CoursePostsPage(
                                        courseId: widget.courseId,
                                        sectionId: sectionId,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.assignment, color: Colors.indigo),
                                tooltip: 'View Posts',
                              ),
                              IconButton(
                                onPressed: () {
                                  if (isSubscribed) {
                                    removeSubscription(sectionId);
                                  } else {
                                    subscribeToSection(sectionId);
                                  }
                                },
                                icon: Icon(
                                  isSubscribed ? Icons.remove_circle : Icons.add_circle,
                                  color: isSubscribed ? Colors.red : Colors.green,
                                ),
                                tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

