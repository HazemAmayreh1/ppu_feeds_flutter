import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCommentPage extends StatefulWidget {
  final int postId;
  const AddCommentPage({Key? key, required this.postId}) : super(key: key);

  @override
  _AddCommentPageState createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> addComment() async {
    final response = await http.post(
      Uri.parse('http://feeds.ppu.edu/api/v1/posts/${widget.postId}/comments'),
      headers: {'Authorization': '<auth_token>'},
      body: {'body': _controller.text},
    );
    if (response.statusCode == 201) {
      Navigator.pop(context); 
    } else {
      throw Exception('Failed to add comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Comment')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter your comment'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addComment,
              child: Text('Post Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
