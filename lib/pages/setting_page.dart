import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme_provider.dart';
import '../widget/setting_tile.dart';
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("设置"),
      ),
      //body
      body: Column(
        children: [
          //Dark mode tile
          MySettingsTile(
            title: "浅色模式",
            action: CupertinoSwitch(
              onChanged: (value)=>
                  Provider.of<ThemeProvider>(context,listen: false).toggleTheme(),
              value:
              Provider.of<ThemeProvider>(context,listen: false).isDarkMode,
            ),
          ),

          //Block users tile
          const MySettingsTile(title: "编辑资料", action:Icon(Icons.change_history))
        ],
      ),
    );
  }

}
