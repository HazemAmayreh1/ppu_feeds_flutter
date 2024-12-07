import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseCommentsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  CourseCommentsPage({required this.courseId, required this.sectionId, required this.postId});

  @override
  _CourseCommentsPageState createState() => _CourseCommentsPageState();
}

class _CourseCommentsPageState extends State<CourseCommentsPage> {
  List<dynamic> comments = [];
  final _storage = FlutterSecureStorage();
  String? _errorMessage;
  Map<int, bool> likedComments = {}; // To store the like status locally

  @override
  void initState() {
    super.initState();
    fetchLikedStates(); // Load saved like states
    fetchComments();
  }

  /// Load liked states from SharedPreferences
  Future<void> fetchLikedStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      likedComments = prefs.getKeys().fold<Map<int, bool>>({}, (map, key) {
        if (key.startsWith('liked_')) {
          int commentId = int.parse(key.split('_')[1]);
          map[commentId] = prefs.getBool(key) ?? false;
        }
        return map;
      });
    });
  }

  /// Save liked state to SharedPreferences
  Future<void> saveLikedState(int commentId, bool isLiked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liked_$commentId', isLiked);
  }

  Future<void> fetchComments() async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) throw Exception('No session token found.');

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          comments = json.decode(response.body)['comments'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load comments. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load comments. $e';
      });
    }
  }

  Future<void> deleteComment(int commentId, int index) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) throw Exception('No session token found.');

      final response = await http.delete(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          comments.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comment deleted successfully')));
      } else {
        setState(() {
          _errorMessage = 'Failed to delete comment. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete comment. $e';
      });
    }
  }

  Future<void> addComment(String body) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) throw Exception('No session token found.');

      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments'),
        headers: {'Authorization': ' $token', 'Content-Type': 'application/json'},
        body: json.encode({'body': body}),
      );

      if (response.statusCode == 200) {
        setState(() {
          fetchComments();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comment added successfully')));
      } else {
        setState(() {
          _errorMessage = 'Failed to add comment. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add comment. $e';
      });
    }
  }

  Future<void> toggleLike(int commentId, int index) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) throw Exception('No session token found.');

      bool isLiked = likedComments[commentId] ?? false;
      final newStatus = isLiked ? 'unlike' : 'like';

      // Toggle like/unlike
      final toggleResponse = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/$newStatus'),
        headers: {'Authorization': ' $token'},
      );

      if (toggleResponse.statusCode == 200) {
        // Fetch updated likes count from the server
        final likesCountResponse = await http.get(
          Uri.parse(
              'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/likes'),
          headers: {'Authorization': ' $token'},
        );

        if (likesCountResponse.statusCode == 200) {
          int likesCount = json.decode(likesCountResponse.body)['likes_count'];
          
          // Update local state and UI
          setState(() {
            comments[index]['likes_count'] = likesCount;
            likedComments[commentId] = !isLiked; // Update local like state
          });

          // Save like state locally
          await saveLikedState(commentId, !isLiked);
        } else {
          // Handle the error if likes count could not be fetched
          setState(() {
            _errorMessage = 'Failed to fetch updated likes count.';
          });
        }
      } else {
        // Handle the error if the toggle operation failed
        setState(() {
          _errorMessage = 'Failed to toggle like status.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update like status. $e';
      });
    }
  }

  void _showAddCommentDialog() {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter your comment here...'),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String comment = commentController.text;
                if (comment.isNotEmpty) {
                  addComment(comment);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Comment cannot be empty')));
                }
              },
              child: Text('Add Comment'),
            ),
          ],
        );
      },
    );
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Comments',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      ),
      backgroundColor: Colors.indigo,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddCommentDialog,
      backgroundColor: Colors.indigo,
      child: Icon(Icons.add, color: Colors.white),
    ),
    body: _errorMessage != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text(_errorMessage!),
                ElevatedButton(
                  onPressed: fetchComments,
                  child: Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                )
              ],
            ),
          )
        : comments.isEmpty
            ? Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
            : ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  String author = comment['author'] ?? 'Anonymous';
                  String body = comment['body'] ?? 'No comment';
                  String datePosted = comment['date_posted'] ?? '';
                  int commentId = comment['id'];
                  bool isLiked = likedComments[commentId] ?? false;
                  int likesCount = comment['likes_count'] ?? 0;

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              author.isNotEmpty ? author[0].toUpperCase() : 'A',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.indigo,
                          ),
                          title: Text(author, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(body),
                              SizedBox(height: 8),
                              Text(
                                'Posted on: $datePosted',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                                      color: isLiked ? Colors.blue : null,
                                    ),
                                    onPressed: () => toggleLike(commentId, index),
                                  ),
                                  Text('$likesCount likes'),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteComment(commentId, index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
  );
}

}
