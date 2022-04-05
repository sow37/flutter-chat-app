import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupListPage extends StatefulWidget {
  final SharedPreferences prefs;
  GroupListPage({this.prefs});
  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final db = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();

  @override
  initState() {
    super.initState();
  }

 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group List'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: null
      ),
    );
  }
}
