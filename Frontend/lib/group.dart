import 'package:flutter/material.dart';
import 'package:flutter_app/components/buildteambutton.dart';
import 'package:flutter_app/firecursor.dart';
import 'package:flutter_app/main.dart';

class Group extends StatelessWidget {
  final String token;
  final String userRole;

  const Group({super.key, required this.token, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return FireCursor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Your Team'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MyHomePage(),
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
              colors: [Colors.yellow, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTeamButton(
                  context,
                  'Team Iron Man',
                  Colors.red,
                  Colors.redAccent,
                  'assets/ironman.png',
                  'ironman',
                  token,
                  userRole,
                ),
                const SizedBox(height: 20),
                buildTeamButton(
                  context,
                  'Team Spider Man',
                  Colors.blue,
                  Colors.lightBlueAccent,
                  'assets/spiderman.png',
                  'spiderman',
                  token,
                  userRole,
                ),
                const SizedBox(height: 20),
                buildTeamButton(
                  context,
                  'Team Deadpool',
                  Colors.black,
                  Colors.black87,
                  'assets/deadpool1.png',
                  'deadpool',
                  token,
                  userRole,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
