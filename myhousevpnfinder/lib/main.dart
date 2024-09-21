import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// List of IP addresses with 252
const List<String> routerGatewaysWith252 = [
  "192.168.0.252",
  "192.168.1.252",
  "192.168.10.252",
  "192.168.100.252",
  "192.168.2.252",
  "192.168.15.252",
  "192.168.254.252",
  "192.168.8.252",
  "192.168.16.252",
  "192.168.11.252",
  "10.0.0.252",
  "10.0.1.252",
  "10.1.1.252",
  "172.16.0.252",
  "172.16.1.252",
  "172.31.254.252"
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyHouseVPN Device Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.white,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String _resultMessage = '';
  String? _deviceUrl;
  bool _deviceFound = false;

  Future<void> findDevice() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _deviceFound = false;
    });

    for (String ip in routerGatewaysWith252) {
      final isReachable = await _checkIfIpIsReachable(ip);
      if (isReachable) {
        setState(() {
          _deviceFound = true;
          _deviceUrl = 'http://$ip';
          _resultMessage = 'MyHouseVPN Device Found!';
        });
        break; // Stop the loop when the first valid IP is found
      }
    }

    if (!_deviceFound) {
      setState(() {
        _resultMessage = 'MyHouseVPN Device Not Found. Please Try Again Later.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Check if the response is valid by inspecting the status code only
  Future<bool> _checkIfIpIsReachable(String ip) async {
    try {
      final response = await http.get(Uri.parse('http://$ip'), headers: {
        'Connection': 'keep-alive',
      }).timeout(Duration(seconds: 1));
      if (response.statusCode == 200) {
        return true; // Device is reachable and returned 200 OK
      }
    } catch (e) {
      // Handle errors like timeout or no connection
      print('Error for $ip: $e');
    }
    return false; // Device is not reachable or didn't return 200
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png', // Path for your logo image
                  width: 80,
                  height: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'MyHouseVPN Device Finder',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF003366),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : findDevice,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Icon(Icons.search, color: Colors.white),
                  label: Text('Find'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003366),
                    foregroundColor: Colors.white, // This sets the text/icon color to white
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(),
                      SizedBox(width: 10),
                      _buildDot(),
                      SizedBox(width: 10),
                      _buildDot(),
                    ],
                  ),
                if (!_isLoading && _resultMessage.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text(
                    _resultMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: _deviceFound ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_deviceFound)
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_deviceUrl != null) {
                          _launchURL(_deviceUrl!);
                        }
                      },
                      icon: Icon(Icons.open_in_new, color: Colors.white),
                      label: Text('Go to MyHouseVPN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF003366),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
                SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Color(0xFF003366),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchURL('https://www.myhousevpn.com'),
          child: Image.asset(
            'assets/logo.png', // Path for your logo image
            width: 60,
            height: 60,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '“Securing Your Digital Future Today”',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF003366),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Force opening in the external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
