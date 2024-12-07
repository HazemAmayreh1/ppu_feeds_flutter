import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionsPage extends StatefulWidget {
  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? token;
  int _selectedIndex = 0;

  Future<List<Map<String, dynamic>>> fetchSubscriptions() async {
    try {
      token = await _storage.read(key: 'session_token');
      if (token == null || token!.isEmpty) {
        throw Exception('Session token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/subscriptions'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('subscriptions')) {
          return List<Map<String, dynamic>>.from(data['subscriptions']);
        } else {
          throw Exception('No subscriptions found in the API response.');
        }
      } else {
        throw Exception('Failed to load subscriptions. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error fetching subscriptions: $e');
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
        Navigator.pushNamed(context, '/feeds');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.blueAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchSubscriptions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
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
                  'No subscriptions found.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            } else {
              final subscriptions = snapshot.data!;
              return ListView.builder(
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.school, size: 50, color: Colors.indigo),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subscription['section'] ?? 'Unnamed Section',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Course: ${subscription['course'] ?? 'Unnamed Course'}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Lecturer: ${subscription['lecturer'] ?? 'Unknown Lecturer'}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text(
                                      subscription['subscription_date'] ?? 'Unknown Date',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
