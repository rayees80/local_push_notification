import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// List<MotMsg> mmsl2 = new List<MotMsg>();
final storage = new FlutterSecureStorage();

void main() => runApp(new MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(
        color: Colors.red,
      )),
      home: new MyApp(),
    ));

class MotMsg {
  final String text;
  MotMsg({this.text});
  factory MotMsg.fromJson(Map<String, dynamic> json) {
    return MotMsg(text: json['msg_text']);
  }
}

void callbackdis() async {
  Workmanager.executeTask((task, inputData) async {
    // fetchMotMsg().then((result) {
    //   mmsl2 = result;
    // });

    // //_MyAppState().showNotification();
    // _MyAppState _myAppState = context.findAncestorStateOfType<_MyAppState>();
    // _myAppState.showNotification();
    String motmsg = await storage.read(key: "motmsg");

    final response = await http.get('http://seespa.somee.com/mapi/getmmsl');

    List<MotMsg> l = (json.decode(response.body) as List)
        .map((x) => MotMsg.fromJson(x))
        .toList();
    var rnd = new Random();
    print("------------------ motmsg list length " + l.length.toString());
    print("------------------ random under list length " +
        rnd.nextInt(l.length - 1).toString());
    motmsg = l[rnd.nextInt(l.length - 1)].text;
    storage.write(key: "motmsg", value: motmsg);
    print("------------------ new motmsg is " + motmsg);
    // fetchMotMsg().then((result) async {
    //   var rnd = new Random();
    //   String motmsg1 = result[rnd.nextInt(result.length - 1)].text;
    //
    //   storage.write(key: "motmsg", value: motmsg1);
    // });

    if (motmsg != null) {
      print("------------------ motmsg is " + motmsg);
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      var android = new AndroidNotificationDetails(
          'id', 'channel ', 'description',
          priority: Priority.High, importance: Importance.Max);
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android, iOS);
      await flutterLocalNotificationsPlugin.show(0, 'SEESPA Motivation',
          'Every 15 mins notification. ' + motmsg, platform,
          payload: 'Welcome to the Local Notification demo. ' + motmsg);
    } else {
      print("------------------ motmsg is null");
    }

    return Future.value(true);
  });
}

Future<List<MotMsg>> fetchMotMsg() async {
  final response = await http.get('http://seespa.somee.com/mapi/getmmsl');

  List<MotMsg> l = (json.decode(response.body) as List)
      .map((x) => MotMsg.fromJson(x))
      .toList();

  return l;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<MotMsg> mmsl;
  var rnd = new Random();

  @override
  void initState() {
    super.initState();

    fetchMotMsg().then((result) {
      setState(() {
        mmsl = result;
        storage.write(
            key: "motmsg", value: mmsl[rnd.nextInt(mmsl.length - 1)].text);
      });
    });

    Workmanager.initialize(callbackdis, isInDebugMode: true);
    Workmanager.registerPeriodicTask("1", "test",
        frequency: Duration(minutes: 15));

    var initializationSettingsAndroid =
        AndroidInitializationSettings('squ_logo');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('SEESPA Notification Demo'),
      ),
      body: new Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: showNotification,
              child: new Text(
                'showNotification',
              ),
            ),
            RaisedButton(
              onPressed: cancelNotification,
              child: new Text(
                'cancelNotification',
              ),
            ),
            RaisedButton(
              onPressed: scheduleNotification,
              child: new Text(
                'scheduleNotification',
              ),
            ),
            RaisedButton(
              onPressed: showBigPictureNotification,
              child: new Text(
                'showBigPictureNotification',
              ),
            ),
            RaisedButton(
              onPressed: showNotificationMediaStyle,
              child: new Text(
                'showNotificationMediaStyle',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showNotificationMediaStyle() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      'media channel description',
      color: Colors.red,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap("squ_logo"),
      styleInformation: MediaStyleInformation(),
    );
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(0, 'SEESPA Motivation',
        '' + mmsl[rnd.nextInt(mmsl.length - 1)].text, platformChannelSpecifics);
  }

  Future<void> showBigPictureNotification() async {
    var bigPictureStyleInformation = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("squ_logo"),
        largeIcon: DrawableResourceAndroidBitmap("squ_logo"),
        contentTitle: 'SEESPA Motivation',
        htmlFormatContentTitle: true,
        summaryText: '' + mmsl[rnd.nextInt(mmsl.length - 1)].text,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(0, 'SEESPA Motivation',
        '' + mmsl[rnd.nextInt(mmsl.length - 1)].text, platformChannelSpecifics,
        payload: "big image notifications");
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      icon: 'squ_logo',
      largeIcon: DrawableResourceAndroidBitmap('squ_logo'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'SEESPA Motivation',
        'This is SSESPA notification',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  showNotification() async {
    fetchMotMsg().then((result) {
      setState(() {
        mmsl = result;
      });
    });
    var android = new AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, 'SEESPA Motivation',
        '' + mmsl[rnd.nextInt(mmsl.length - 1)].text, platform,
        payload:
            'Welcome to the Local Notification demo ' + mmsl.length.toString());
  }
}

class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}
