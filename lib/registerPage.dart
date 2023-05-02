import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:imswater/global_var.dart' as globals;

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  @override
  RegisterPageState createState() {
    return new RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  List<TextEditingController> _data = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];
  List<bool> _error = [false, false, false, false];
  String _passwordMsg = "Value Can\'t Be Empty";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.width / 2.5),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              width: double.infinity,
              // height: MediaQuery.of(context).size.width / 10,
              child: Text("IMSWATER", textAlign: TextAlign.center, style: TextStyle(color: Color.fromARGB(255, 255, 120, 120), fontSize: 35, fontWeight: FontWeight.bold))
            ),     
            SizedBox(height: MediaQuery.of(context).size.width / 35),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nama',
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
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 20),
                      errorText: _error[2] ? 'Value Can\'t Be Empty' : null,
                    ),
                    controller: _data[2],
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(fontSize: 20),
                      errorText: _error[3] ? _passwordMsg : null,
                    ),
                    controller: _data[3],
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
                  _doRegister(context);
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 20),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
              width: double.infinity,
              height: MediaQuery.of(context).size.width / 10,
              child: Row(
                children: [                
                  Text('Do you have an account ? '),
                  InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Login Now", style: TextStyle(color: Colors.blue))
                )
              ],)
            ),            
          ],
        ),
      ),
    );
  }

  Future _doRegister(context) async {
    bool status = true;
    setState(() {
      _passwordMsg = "Value Can\'t Be Empty";
      for (int a = 0; a < 4; a++) {
        if (_data[a].text.isEmpty) {
          _error[a] = true;
          status = false;
        } else
          _error[a] = false;
      }
    });
    if (status && (_data[2].text != _data[3].text)) {
      setState(() {
        status = false;
        _error[3] = true;
        _passwordMsg = "Password not same!";
      });
    }
    if (status) {
      String _name = _data[0].text;
      String _email = _data[1].text;
      String _password = _data[2].text;
      // context.loaderOverlay.show();
      var url = Uri.parse(globals.api + '/register.php');
      // var response = await http.post(url, body: {});
      final response = await http.post(url, body: {'name': _name, 'email': _email, 'password': _password});
      // context.loaderOverlay.hide();
      print(response);
      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', (parsed['data']['id']).toString());
        await prefs.setString('user_name', parsed['data']['name']);
        await prefs.setString('user_email', parsed['data']['email']);
        await prefs.setString('user_password', _password);
        setState(() {
          globals.user_id = (parsed['data']['id']).toString();
          globals.user_name = parsed['data']['name'];
          globals.user_email = parsed['data']['email'];
          globals.user_password = _password;
          globals.isLoggedIn = true;
        });
        Alert(
          context: context,
          type: AlertType.info,
          desc: "Register Success",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Phoenix.rebirth(context),
            )
          ],
        ).show();

      } else if (response.statusCode == 403) {
        Map<String, dynamic> parsed = jsonDecode(response.body);
        Alert(
          context: context,
          type: AlertType.info,
          title: "Register Failed!",
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

      } else {
        Alert(
          context: context,
          type: AlertType.info,
          title: "Register Failed!",
          desc: "Internal Server Error\n" + globals.api + '/register.php\n' + response.statusCode.toString(),
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