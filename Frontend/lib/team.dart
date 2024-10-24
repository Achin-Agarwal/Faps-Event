import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/firecursor.dart';
import 'package:http/http.dart' as http;
import 't.dart';
import 'group.dart';

class TeamListPage extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final String token;
  final String userRole;

  const TeamListPage({
    super.key,
    required this.teams,
    required this.token,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return FireCursor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teams'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Group(token: token, userRole: userRole),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreenAccent, Colors.lightGreenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: teams.map((team) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: buildTeamButton(
                        context,
                        team['name'] ?? 'Unknown',
                        team['id'] ?? '',
                        team['startColor'] ?? Colors.teal,
                        team['endColor'] ?? Colors.blueAccent,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTeamButton(
    BuildContext context,
    String name,
    String teamId,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final response = await http.post(
              Uri.parse('https://achin.parthkatiyar.co/team/$teamId'),
              headers: {
                'Authorization': token,
              },
            );
            if (response.statusCode == 200) {
              final Map<String, dynamic> responseData =
                  jsonDecode(response.body);

              final List<String> tasks = List<String>.from(
                  responseData['data']['team']['tasks'] ?? []);

              final String teamName =
                  responseData['data']['team']['name'] ?? 'Unknown Team';
              print("This is : ${response.body}");
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TaskPage(
                    teamName: teamName,
                    tasks: tasks,
                    token: token,
                    userRole: userRole,
                    teamId: teamId,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            } else {
              print("This is : ${response.body}");
              print(
                  'Failed to get response from server. Status code: ${response.statusCode}');
            }
          } catch (e) {
            print('Error: $e');
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        label: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
