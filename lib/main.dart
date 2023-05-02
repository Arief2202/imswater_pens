// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, non_constant_identifier_names, prefer_interpolation_to_compose_strings, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:onparking_mobile/Dashboard.dart';
// import 'package:onparking_mobile/Dashboard_Admin.dart';
import 'package:monitor_gas/loginPage.dart';
import 'package:monitor_gas/dashboard.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:monitor_gas/global_var.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;
import 'notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // scaffoldBackgroundColor: Color(0xFF736AB7),
      ),
      home: LoaderOverlay(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    notif.initialize(flutterLocalNotificationsPlugin);
    autoLogIn();
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user_email = prefs.getString('user_email');
    final String? user_password = prefs.getString('user_password');

    if (user_email != null && user_password != null) {
      setState(() {
        globals.loadingAutologin = true;
      });
      context.loaderOverlay.show();
      var url = Uri.parse(globals.api + '/login.php');
      final response = await http.post(url, body: {'email': user_email, 'password': user_password});

      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', (parsed['data']['id']).toString());
        await prefs.setString('user_name', parsed['data']['name']);
        await prefs.setString('user_email', parsed['data']['email']);
        await prefs.setString('user_password', globals.user_password);
        await prefs.setString('user_password_encrypted', parsed['data']['password']);
        setState(() {
          globals.user_id = (parsed['data']['id']).toString();
          globals.user_name = parsed['data']['name'];
          globals.user_email = parsed['data']['email'];
          globals.user_password_encrypted = parsed['data']['password'];
          globals.isLoggedIn = true;
        });
      } else {
        await prefs.remove('user_id');
        await prefs.remove('user_name');
        await prefs.remove('user_email');
        await prefs.remove('user_password');
        await prefs.remove('user_password_encrypted');
        setState(() {
          globals.user_id = "";
          globals.user_name = "";
          globals.user_email = "";
          globals.user_password = "";
          globals.user_password_encrypted = "";
          globals.isLoggedIn = false;
        });
        Alert(
          context: context,
          type: AlertType.info,
          title: "Login Failed!",
          desc: "Please relogin",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ).show();
      }
      setState(() {
        globals.loadingAutologin = false;
      });
      context.loaderOverlay.hide();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return globals.loadingAutologin ? Scaffold() : Scaffold(body: globals.isLoggedIn ? Dashboard() : LoginPage());
  }
}