import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Use this context to open the drawer
              },
            );
          },
        ),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/course_images/weppu.png'), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to PPU Feeds App!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'PPU Feeds is your gateway to accessing courses, feeds, and course details from PPU University. With our app, you can easily stay updated with all academic and course-related content.',
                style: TextStyle(fontSize: 18, height: 1.6),
              ),
              SizedBox(height: 20),
              // Logo Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/course_images/ppu.png'), 
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'App Features:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FeatureCardItem(
                        icon: Icons.book,
                        text: 'View available courses and their details',
                      ),
                      FeatureCardItem(
                        icon: Icons.rss_feed,
                        text: 'Browse course feeds and posts',
                      ),
                      FeatureCardItem(
                        icon: Icons.comment,
                        text: 'Interact with other students via comments',
                      ),
                      FeatureCardItem(
                        icon: Icons.notifications,
                        text: 'Receive notifications about course updates',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('App Information'),
                          content: Text(
                            'PPU Feeds App helps you stay connected with academic resources, '
                            'browse course feeds, and interact with other students effectively.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Learn More', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCardItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureCardItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.indigo,
          size: 30,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class AppDrawer extends StatelessWidget {
  final _storage = FlutterSecureStorage(); // To access secure storage for logout

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PPU Feeds App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your academic companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.indigo),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.feed, color: Colors.indigo),
            title: Text('Feeds'),
            onTap: () {
              Navigator.pushNamed(context, '/feeds');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment, color: Colors.indigo),
            title: Text('Course Feed'),
            onTap: () {
              Navigator.pushNamed(context, '/courseFeed');
            },
          ),
          ListTile(
            leading: Icon(Icons.comment, color: Colors.indigo),
            title: Text('Comments Feed'),
            onTap: () {
              Navigator.pushNamed(context, '/commentsFeed');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.indigo),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.indigo),
            title: Text('Logout'),
            onTap: () async {
              // Clear session data
              await _storage.delete(key: 'session_token');

              // Ensure proper navigation after logout
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/', 
                (route) => false, // Remove all routes
              );
            },
          ),
        ],
      ),
    );
  }
}
