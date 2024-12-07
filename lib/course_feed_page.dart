import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseFeedPage extends StatefulWidget {
  final int courseId;
  const CourseFeedPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseFeedPageState createState() => _CourseFeedPageState();
}

class _CourseFeedPageState extends State<CourseFeedPage> {
  List<dynamic> posts = [];
  bool isLoading = true;
  final _storage = FlutterSecureStorage(); // For reading the token

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
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/posts'),
        headers: {
          'Authorization': '$token', 
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body)['posts'];
          isLoading = false; // Set loading to false when data is fetched
        });
      } else {
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading in case of an error
      });
      // Show an error dialog or Snackbar for the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load posts: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Feed')),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : posts.isEmpty
              ? Center(child: Text('No posts available')) // Display message if no posts
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(post['body']),
                        subtitle: Text(
                            'Posted by: ${post['author']} on ${post['date_posted']}'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/commentsFeed',
                            arguments: post['id'],
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
