import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:monitor_gas/global_var.dart' as globals;
import 'package:monitor_gas/registerPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  List<TextEditingController> _data = [TextEditingController(), TextEditingController()];
  List<bool> _error = [false, false, false, false];
  String _passwordMsg = "Value Can\'t Be Empty";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
                        
            SizedBox(height: MediaQuery.of(context).size.width / 2),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              width: double.infinity,
              // height: MediaQuery.of(context).size.width / 10,
              child: Text("IMSWATER", textAlign: TextAlign.center, style: TextStyle(color: Color.fromARGB(255, 255, 120, 120), fontSize: 35, fontWeight: FontWeight.bold))
            ),     
            SizedBox(height: MediaQuery.of(context).size.width / 35),
            Container(
              //img1
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      labelStyle: TextStyle(fontSize: 20),
                      errorText: _error[0] ? 'Value Can\'t Be Empty' : null,
                    ),
                    controller: _data[0],
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 15),
            Container(
              //img1
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 20),
                      errorText: _error[1] ? 'Value Can\'t Be Empty' : null,
                    ),
                    controller: _data[1],
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              width: double.infinity,
              height: MediaQuery.of(context).size.width / 10,
              child: ElevatedButton(
                onPressed: () {
                  _doLogin(context);
                },
                child: Text(
                  "Log in",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 20),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              width: double.infinity,
              child: Row(
                children: [                
                  Text('Do you not have an account ? '),
                  InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text("Register Now", style: TextStyle(color: Colors.blue))
                )
              ],)
            ),            
          ],
        ),
      ),
    );
  }

  Future _doLogin(context) async {
    bool status = true;
    setState(() {
      _passwordMsg = "Value Can\'t Be Empty";
      for (int a = 0; a < 2; a++) {
        if (_data[a].text.isEmpty) {
          _error[a] = true;
          status = false;
        } else
          _error[a] = false;
      }
    });
    if (status) {
      String _email = _data[0].text;
      String _password = _data[1].text;
      // context.loaderOverlay.show();
      var url = Uri.parse(globals.api + '/login.php');
      final response = await http.post(url, body: {'email': _email, 'password': _password});
      // context.loaderOverlay.hide();

      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', (parsed['data']['id']).toString());
        await prefs.setString('user_name', parsed['data']['name']);
        await prefs.setString('user_email', parsed['data']['email']);
        await prefs.setString('user_password', _password);
        await prefs.setString('user_password_encrypted', parsed['data']['password']);
        setState(() {
          globals.user_id = (parsed['data']['id']).toString();
          globals.user_name = parsed['data']['name'];
          globals.user_email = parsed['data']['email'];
          globals.user_password = _password;
          globals.user_password_encrypted = parsed['data']['password'];
          globals.isLoggedIn = true;
        });
        Alert(
          context: context,
          type: AlertType.info,
          desc: "Login Success!",
          buttons: [
            DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Phoenix.rebirth(context);
                })
          ],
        ).show();
      } else {
        Map<String, dynamic> parsed = jsonDecode(response.body);
        Alert(
          context: context,
          type: AlertType.info,
          title: "Login Failed!",
          desc: parsed["pesan"],
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
    }
  }
}