import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formatter = DateFormat('yyyy-MM-dd');

  // By default today is selected
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final date = _formatter.format(_selectedDate);

    return Scaffold(
      backgroundColor: Color(0x9BCBEEFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Виберіть дату:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022, 2, 24),
                      lastDate: DateTime.now(),
                    );

                    if (date == null) {
                      return;
                    }

                    setState(() => _selectedDate = date);
                  },
                  child: Text(date),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Display war stats with border
            FutureBuilder(
              future: getStats(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildStatText("Здохло: ${data[0]} 🐷"),
                        _buildStatText("Згоріло танків: ${data[1]}"),
                        _buildStatText("Згоріло літаків 🛩: ${data[2]}"),
                        _buildStatText("гелікоптери: ${data[3]}"),
                        _buildStatText("артилерійська система: ${data[4]}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatText(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Future<List<int>> getStats(String date) async {
    const url = "https://russianwarship.rip/api/v2";
    final uri = Uri.parse("$url/statistics/$date");
    final response = await get(uri);
    final json = jsonDecode(response.body);
    print(json);
    final personnel = json['data']['stats']['personnel_units'] as int;
    final tanks = json['data']['stats']['tanks'] as int;
    final planes = json['data']['stats']['planes'] as int;
    final helicopters = json['data']['stats']['helicopters'] as int;
    final artillery_systems =
    json['data']['stats']['artillery_systems'] as int;

    return [personnel, tanks, planes, helicopters, artillery_systems];
  }
}
