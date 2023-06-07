import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_page.dart';

///This is a code written by Hassan Dabary for ABGA Company screening assessment assignment
///contact me at: dabary@proton.me

void main() {
  runApp(MyApp());
}
//This is the main class for the app and the start point of it
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = const Color(0xff4145f6);
    return MaterialApp(
      title: 'Hassan Dabary Analysis',
      theme: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: const Color(0xff4145f6),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

//The app first starts a splash screen and then goes to the home page
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkPermissionAndNavigate();
  }
  //This function handles the check of the permissions before navigating to the home page
  void checkPermissionAndNavigate() async {
    // Check if the SMS permission is already granted
    var smsStatus = await Permission.sms.status;
    // Check if the storage permission is already granted
    var storageStatus = await Permission.storage.status;

    if (smsStatus == PermissionStatus.granted && storageStatus == PermissionStatus.granted) {
      navigateToHomePage();
    } else {
      // Request the permissions
      smsStatus = await Permission.sms.request();
      storageStatus = await Permission.storage.request();

      if (smsStatus == PermissionStatus.granted && storageStatus == PermissionStatus.granted) {
        navigateToHomePage();
      } else {
        // Permissions denied, handle accordingly
      }
    }
  }

  void navigateToHomePage() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/analytics.png', width: 250, height: 200),
            ),
            Text(
              'Analyse your cost!',
              style: TextStyle(
                fontSize: 18,
                color:  Color(0xff4145f6),
                decoration: TextDecoration.none
              ),
            ),
          ],
        ),
      ),
    );
  }
}
