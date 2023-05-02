// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;
import 'dart:convert' show jsonEncode;
import 'package:monitor_gas/global_var.dart' as globals;
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class Dashboard extends StatefulWidget
{
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
{
  Timer? timer;
  String suhu1 = "";
  String suhu2 = "";
  String suhu3 = "";
  String gas1 = "";
  String gas2 = "";
  String gas3 = "";
  String ph1 = "";
  
  void initState() {
    super.initState();
    notif.initialize(flutterLocalNotificationsPlugin);
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) => updateValue());
  }
  void updateValue() async{
    var url = Uri.parse(globals.api + "/readData.php");
    var response = await http.get(url);
    if (response.statusCode == 200) {
        // final data = jsonDecode(response.body)[0];
        Map<String, dynamic> data = jsonDecode(response.body);
        if (this.mounted) {
          setState(() {
            suhu1 = data['data_latest']['suhu1'];
            suhu2 = data['data_latest']['suhu2'];
            suhu3 = data['data_latest']['suhu3'];
            gas1 = data['data_latest']['gas1'];
            gas2 = data['data_latest']['gas2'];
            gas3 = data['data_latest']['gas3'];
            ph1 = data['data_latest']['ph1'];
          });
        }
    }
    
    url = Uri.parse(globals.api + "/readNotif.php");
    response = await http.get(url);
    if (response.statusCode == 200) {
        // final data = jsonDecode(response.body)[0];
        Map<String, dynamic> data = jsonDecode(response.body);
        if (this.mounted) {
          if(data['data_oldest'] != null){
            response = await http.post(
              Uri.parse(globals.api + "/postNotif.php"),
              headers: <String, String>{
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              },
              body: "id="+data['data_oldest']['id'],
            );
            if(response.statusCode == 200){
              notif.showNotif(id: int.parse(data['data_oldest']['id']), body: data['data_oldest']['message'], fln: flutterLocalNotificationsPlugin);
            }
          }
        }
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        timer?.cancel();
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 44, 138),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Phoenix.rebirth(context),
        // ),
        title: Text("IMSWATER"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Alert(
                  context: context,
                  type: AlertType.info,
                  desc: "Do you want to Logout ?",
                  buttons: [
                    DialogButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () async {
                          // Navigator.pop(context);
                          final prefs = await SharedPreferences.getInstance();
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
                          // Navigator.pop(context);
                          Phoenix.rebirth(context);
                        }),
                    DialogButton(
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Phoenix.rebirth(context);
                        })
                  ],
                ).show();

              })
        ],
      ),
        body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          myCard("Suhu 1", suhu1 + ' °C', Icon(Icons.thermostat, color: Colors.white, size: 30.0)),
          myCard("Suhu 2", suhu2 + ' °C', Icon(Icons.thermostat, color: Colors.white, size: 30.0)),
          myCard("Suhu 3", suhu3 + ' °C', Icon(Icons.thermostat, color: Colors.white, size: 30.0)),
          myCard("Gas 1", gas1 + ' ppm', Icon(Icons.gas_meter, color: Colors.white, size: 30.0)),
          myCard("Gas 2", gas2 + ' ppm', Icon(Icons.gas_meter, color: Colors.white, size: 30.0)),
          myCard("Gas 3", gas3 + ' ppm', Icon(Icons.gas_meter, color: Colors.white, size: 30.0)),
          myCard("PH 1", ph1 + ' pH', Icon(Icons.fire_hydrant, color: Colors.white, size: 30.0)),

        ],
        staggeredTiles: [
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 110.0),
        ],
      )
    ),
    );
  }

  Widget _buildTile(Widget child, {Function() ?onTap}) {
    return Material(
      elevation: 14.0,
      borderRadius: BorderRadius.circular(12.0),
      shadowColor: Color(0x802196F3),
      child: InkWell
      (
        // Do onTap() if it isn't null, otherwise do print()
        onTap: onTap != null ? () => onTap() : () { print('Not set yet'); },
        child: child
      )
    );
  }

  Widget myCard(String title, String value, Widget icon){
    return _buildTile(
            Padding
            (
              padding: const EdgeInsets.all(24.0),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>
                [
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Text(title, style: TextStyle(color: Colors.blueAccent)),
                      Text(value, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 28.0))
                    ],
                  ),
                  Material
                  (
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Center
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.all(16.0),
                        child: icon,
                      )
                    )
                  )
                ]
              ),
            ),
          );
  }
}