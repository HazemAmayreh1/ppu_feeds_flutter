import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projectppufeeds/course_comment_page.dart';


class CoursePostsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;

  CoursePostsPage({required this.courseId, required this.sectionId});

  @override
  _CoursePostsPageState createState() => _CoursePostsPageState();
}

class _CoursePostsPageState extends State<CoursePostsPage> {
  List<dynamic> posts = [];
  final _storage = FlutterSecureStorage();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts'),
        headers: {
          'Authorization': ' $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body)['posts'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load posts. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts. $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Posts',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4,
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.redAccent)))
          : posts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the comments page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseCommentsPage(
                                courseId: widget.courseId,
                                sectionId: widget.sectionId,
                                postId: post['id'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black38,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Post Body (Main content)
                                Text(
                                  post['body'] ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                // Post Date with time icon
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                                    SizedBox(width: 8.0),
                                    Text(
                                      post['date_posted'] ?? 'No date available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                // Author Section with an icon
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey[600], size: 16),
                                    SizedBox(width: 8.0),
                                    Text(
                                      post['author'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Divider between posts for cleaner look
                                Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
