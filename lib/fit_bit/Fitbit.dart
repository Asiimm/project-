import 'package:flutter/material.dart';
import 'package:capstone2/Services/fitbit_oauth_service.dart';
import '../homeScreen/home_screen.dart';
import '../loginSignup/widget/button.dart';

class FitbitPage extends StatefulWidget {
  @override
  _FitbitPageState createState() => _FitbitPageState();
}

class _FitbitPageState extends State<FitbitPage> {
  final fitbitService = FitbitOAuthService();
  String fitbitData = 'No data fetched yet';

  Future<void> _connectToFitbit() async {
    // Launch the OAuth process
    await fitbitService.launchFitbitOAuth(); // Launch the OAuth flow
  }

  // This method will be triggered from the main app when the code is received
  Future<void> handleAuthorizationCode(String code) async {
    final accessToken = await fitbitService.exchangeCodeForToken(code); // Get the access token
    if (accessToken != null) {
      final data = await fitbitService.fetchFitbitData(accessToken); // Fetch the data using the token
      if (data != null) {
        setState(() {
          fitbitData = data as String; // Update the state with the fetched data
        });
      } else {
        print('Failed to fetch Fitbit data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF492A87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Fitbit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Connect your Fitbit account to share your steps, sleep, weight, body composition, food, and heart rate data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Regbutton(
                text: 'Connect to Fitbit',
                onTab: () => _connectToFitbit(), // Call _connectToFitbit directly
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'By connecting your Fitbit account, you consent to the collection, use, and disclosure of your Fitbit data in accordance with the Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fitbit Data: $fitbitData',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
