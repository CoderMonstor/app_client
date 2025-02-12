import 'package:flutter/material.dart';
class MassageList extends StatefulWidget {
  const MassageList({super.key});

  @override
  State<MassageList> createState() => _MassageListState();
}

class _MassageListState extends State<MassageList> {
  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/head.jpg'),
    ),
      title: Text('Jane Doe'),
      subtitle: Text('Hello! How are you?'),
      trailing: Text('10:30 AM'),
    );
  }
}
