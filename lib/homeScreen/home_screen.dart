import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capstone2/homeScreen/Drawer/headerDawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Drawer/Drawerlist.dart';
import 'package:capstone2/loginSignup/widget/button.dart'; // Update with the correct path
import 'package:capstone2/Services/fitbit_oauth_service.dart'; // Correct import for FitbitOAuthService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  Map<String, dynamic>? fitbitData;
  final fitbitService = FitbitOAuthService(); // Create an instance of the Fitbit service

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
        });
      }
    }
  }

  // Function to connect to Fitbit and fetch real-time data
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
          fitbitData = data; // Update the state with the fetched data
        });
      } else {
        print('Failed to fetch Fitbit data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyHeaderDrawer(),
              MyDrawerList(),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/background/homeScreen.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //
                            const SizedBox(height: 20),
                            Regbutton(
                              text: 'Connect to Fitbit',
                              onTab: _connectToFitbit, // Directly use the method
                            ),
                            const SizedBox(height: 20),
                            _buildFitbitDataDisplay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer(); // Open the end drawer
                  },
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    "Hey,\n${userName ?? 'Guest'}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFitbitDataDisplay() {
    if (fitbitData != null) {
      return Column(
        children: [
          Text(
            'Steps: ${fitbitData!['activities-summary']?['steps'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Calories: ${fitbitData!['activities-summary']?['caloriesOut'] ?? 'N/A'} kcal',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Sleep: ${fitbitData!['sleep']?.isNotEmpty == true ? (fitbitData!['sleep'][0]['duration'] / 60000).toStringAsFixed(2) : 'N/A'} minutes asleep',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Resting Heart Rate: ${fitbitData!['activities-heart']?.isNotEmpty == true ? fitbitData!['activities-heart'][0]['value']['restingHeartRate'] : 'N/A'} bpm',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      );
    } else {
      return const Text(
        'No Fitbit data available',
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }
  }
}