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
                          lastDate: DateTime.now());

                      if (date == null) {
                        return;
                      }

                      setState(() => _selectedDate = date);
                    },
                    child: Text(date)),
              ],
            ),
            const SizedBox(height: 32),
            // TODO: Display war stats
            FutureBuilder(
                future: getStats(date),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  // Згоріло: кількість танків
                  // Згоріло: кількість літаків

                  return Center(
                    child: Column(
                      children: [
                        Text(
                          "Здохло: ${data[0]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        Text(
                          "Згоріло: ${data[1]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        Text(
                          "Згоріло: ${data[2]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  Future<List<int>> getStats(String date) async {
    const url = "https://russianwarship.rip/api/v2";
    final date = _formatter.format(_selectedDate);
    final uri = Uri.parse("$url/statistics/$date");
    final response = await get(uri);
    final json = jsonDecode(response.body);
    print(json);
    final personnel = json['data']['stats']['personnel_units'] as int;
    final tanks = json['data']['stats']['tanks'] as int;
    final planes = json['data']['stats']['planes'] as int;
    return [personnel, tanks, planes];
  }
}