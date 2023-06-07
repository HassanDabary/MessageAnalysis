import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hassan_dabary/pie_chart.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';

///This is a code written by Hassan Dabary for ABGA Company screening assessment assignment
///contact me at: dabary@proton.me

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

//This is the mian Home class for home page of the app
class _HomePageState extends State<HomePage> {
  //Here I am defining all my necessary variables that are used across the class
  static const color = const Color(0xff4145f6);
  List<Map<String, dynamic>> _smsList = [];
  String _searchString = "";
  DateTime? previousDate;
  List<String> _months = [];
  Map<String, List<Map<String, dynamic>>> _filteredMessages = {};
  List<bool> _expanded = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    //Calling load function when this page is initialized
    _loadSMSMessages();
  }

  //This function access the SmsRetriever class which access my local kotlin based channels that
  // I have created in the kotlin base directory to handle the process to extract messages from phone
  void _loadSMSMessages() async {
    List<Map<String, dynamic>> smsList = await SmsRetriever.getAllSms();
    setState(() {
      _smsList = smsList;
      // Initialize the _expanded list here
      _expanded = List<bool>.filled(smsList.length, false);
    });
    organizeMessagesByMonth();
  }

  //This function orders the and organizes the extracted messages based on the date and also
  // it's called one more time after the  filter to re-organize the messages
  void organizeMessagesByMonth() {
    _months = [];
    _filteredMessages = {};

    for (final message in _smsList) {
      final body = message['body'].toLowerCase();
      // Skip the message if it does not contain 'AED'
      if (!body.contains(' aed ')) continue;
      if (!_searchString.isEmpty && !body.contains(_searchString.toLowerCase())) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(message['date']);
      final monthYear = DateFormat('MMMM yyyy').format(date);

      if (!_months.contains(monthYear)) {
        _months.add(monthYear);
        _filteredMessages[monthYear] = [];
      }

      _filteredMessages[monthYear]?.add(message);
    }
  }
  // Calculate the total amount from all the extracted messages amount
  double _calculateTotal(Map<String, List<Map<String, dynamic>>> messagesByMonth) {
    double total = 0.0;
    for (var messageList in messagesByMonth.values) {
      for (var message in messageList) {
        String amountString = _extractAmountFromSMS(message['body']).toString();
        double? amount = double.tryParse(amountString);
        if (amount != null) {
          total += amount;
        }
      }
    }
    return total;
  }

  // Parse to double, defaulting to 0.0 if parsing fails
  double _extractAmountFromSMS(String smsBody) {
    final amountRegExp = RegExp(r'AED\s*([\d,]+\.?\d*)');
    final match = amountRegExp.firstMatch(smsBody);
    if (match != null && match.groupCount > 0) {
      final amount = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amount) ?? 0.0;
    }
    return 0.0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: color, size: 30,),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Messages Analysis',
          style: TextStyle(color: color),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('User Name'),
              accountEmail: Text('user@email.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'U',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: color),
              title: Text('Home'),
              onTap: () {
                // Navigate to the home screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: color),
              title: Text('Settings'),
              onTap: () {
                // Navigate to the settings screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: color),
              title: Text('Notifications'),
              onTap: () {
                // Navigate to the notifications screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: color),
              title: Text('Dashboard'),
              onTap: () {
                // Navigate to the dashboard screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.mail, color: color),
              title: Text('Inbox'),
              onTap: () {
                // Navigate to the inbox screen
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 50,),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: color),
              title: Text('About Us'),
              onTap: () {
                // Navigate to the contact us screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.call, color: color),
              title: Text('Contact Us'),
              onTap: () {
                // Navigate to the contact us screen
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(

        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchString = value;
                      // Re-filter the list
                      organizeMessagesByMonth();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),

              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    final month = _months[index];
                    final messages = _filteredMessages[month];
                    final children = <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            month,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ];

                    for (int i = 0; i < messages!.length; i++) {
                      final message = messages[i];
                      final sender = message['sender'];
                      final date = DateTime.fromMillisecondsSinceEpoch(message['date']);
                      final day = date.day;
                      // Format the date as "Month Day"
                      final formattedDate = DateFormat('MMMM, dd').format(date);
                      final body = message['body'];
                      final amount = _extractAmountFromSMS(body);

                      children.add(
                        Card(
                          color: Color(0xffF7F3F2),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(sender,
                                      style: TextStyle(fontSize: 18, color: color),)),
                                      Text(formattedDate, textAlign: TextAlign.center),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('AED '),
                                            Text(amount.toString()),
                                          ],
                                        ),
                                      ),

                                      Text(_expanded[i] ? 'Show Less' : 'Show More'),
                                      IconButton(
                                        icon: Icon(_expanded[i] ? Icons.arrow_drop_up : Icons.arrow_drop_down,color: color,),
                                        onPressed: () {
                                          setState(() {
                                            _expanded[i] = !_expanded[i];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Show the message body if the card is expanded
                                if (_expanded[i])
                                  Padding(
                                    padding: EdgeInsets.only(left: 18, right: 15, top: 0, bottom: 13),
                                    child: Text(body),
                                  ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
                  },
                ),
              ),

            ],
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    _calculateTotal(_filteredMessages).toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ),


        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: color,
              child: Icon(Icons.analytics_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartPage(values: _calculateValuesForChart()),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              backgroundColor: color,
              child: Icon(Icons.download_outlined),
              onPressed: () async {
                // Function to generate the CSV file
                final csvData = _generateCsvData();

                final csvRows = [
                  // Prepare CSV headers
                  ['Sender', 'Body', 'Amount'],
                  //And then prepare CSV data
                  ...csvData,
                ];

                final csvString = const ListToCsvConverter().convert(csvRows);

                // Request the storage permission
                var permissionStatus = await Permission.storage.request();
                if (permissionStatus.isGranted) {
                  final directory = await getExternalStorageDirectory();
                  final filePath = path.join(directory!.path, 'messages.csv');
                  final file = File(filePath);
                  await file.writeAsString(csvString);

                  // Platform-specific download logic
                  if (Platform.isAndroid) {
                    await File(filePath).copy('/storage/emulated/0/Download/messages.csv');
                  } else if (Platform.isIOS) {
                    // iOS specific modifications
                  }

                  // Show a download progress and link in the top navigation bar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Download complete.'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Open',
                        onPressed: () async {
                          // Perform the action to open the downloaded file
                          await OpenFile.open(filePath);
                        },
                      ),
                    ),
                  );
                } else {
                  // Permission denied, show an error message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Permission Denied'),
                      content: Text('The storage permission is required to download the CSV file.'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },



            ),
          ],
        ),
      ),


    );
  }


  //This function handles the CSV generation process
  List<List<dynamic>> _generateCsvData() {
    final List<List<dynamic>> csvData = [];
    csvData.add(['Sender', 'Body', 'Amount']);
    for (final monthMessages in _filteredMessages.values) {
      for (final message in monthMessages) {
        final sender = message['sender'];
        final body = message['body'];
        final amount = _extractAmountFromSMS(body);
        csvData.add([sender, body, amount]);
      }
    }

    return csvData;
  }

  //I have created this function to calculate and group the values based on the senders
  Map<String, double> _calculateValuesForChart() {
    var amountsBySender = <String, double>{};
    for (var monthMessages in _filteredMessages.values) {
      for (var message in monthMessages) {
        var sender = message['sender'];
        var body = message['body'];
        double amount;
        try {
          amount = _extractAmountFromSMS(body);
        } catch (e) {
          print('Error parsing amount from message: $e');
          continue;
        }
        amountsBySender[sender] = (amountsBySender[sender] ?? 0) + amount;
      }
    }
    return amountsBySender;
  }


}

//This is the class that handles the interaction with my Channel to get all local SMS messages
class SmsRetriever {
  static const platform = MethodChannel('com.example.hassan_dabary/smsRetriever');

  static Future<List<Map<String, dynamic>>> getAllSms() async {
    try {
      final String jsonString = await platform.invokeMethod('getAllSms');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return [];
    }
  }


}

//This is the chart page that shows grouped statistics of all messages in Pie Chart
class ChartPage extends StatelessWidget {
  final Map<String, double> values;

  ChartPage({required this.values});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Brake-down'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Center(
                child: MyPieChart(values: values),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: PieChartLegend(values: values),
          ),
        ],
      ),
    );
  }
}



