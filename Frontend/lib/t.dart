import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/firecursor.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class TaskPage extends StatefulWidget {
  final String teamName;
  final List<String> tasks;
  final String token;
  final String userRole;
  final String teamId;

  const TaskPage({
    super.key,
    required this.teamName,
    required this.tasks,
    required this.token,
    required this.userRole,
    required this.teamId,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late List<String> taskStatuses;

  @override
  void initState() {
    super.initState();
    taskStatuses = List.from(widget.tasks);
  }

  void showPopupMenu(BuildContext context, Offset offset, int index) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx,
        offset.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'low',
          child: Text('Not Assigned'),
        ),
        const PopupMenuItem<String>(
          value: 'current',
          child: Text('Cue Card Given'),
        ),
        const PopupMenuItem<String>(
          value: 'mid',
          child: Text('QR Scanned'),
        ),
        const PopupMenuItem<String>(
          value: 'high',
          child: Text('TaskCompleted'),
        ),
      ],
    );
    if (result != null) {
      updateTaskStatus(index, result);
    }
  }

  Future<void> scanQRCode() async {
    if (widget.userRole != 'scanner') {
      print("You do not have permission to scan QR codes.");
      return;
    }

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SimpleBarcodeScannerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result != null) {
      if (result.toString().startsWith('Desafio of task')) {
        int taskIndex = int.tryParse(result.split(' ')[3]) ?? -1;
        if (taskIndex > 0 && taskIndex <= taskStatuses.length) {
          if (widget.userRole == 'scanner') {
            print("...................................... : $result");
            try {
              final response = await http.put(
                Uri.parse('https://achin.parthkatiyar.co/team/${widget.teamId}'),
                headers: {
                  'Authorization': widget.token,
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'taskCode': result,
                }),
              );
              final Map<String, dynamic> responseData =
                  jsonDecode(response.body);
              if (response.statusCode == 200) {
                if (responseData['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Task updated successfully!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      elevation: 10,
                    ),
                  );
                  setState(() {
                    if (taskStatuses[taskIndex - 1] == 'current') {
                      taskStatuses[taskIndex - 1] = 'mid';
                    }
                  });
                } else {
                  String errorMessage =
                      responseData['message'] ?? 'An error occurred';
                  showErrorSnackbar(errorMessage);
                }
              } else {
                String errorMessage =
                    responseData['message'] ?? 'An error occurred';
                showErrorSnackbar(errorMessage);
              }
            } catch (e) {
              showErrorSnackbar('An unexpected error occurred.');
            }
          }
        } else {
          showErrorSnackbar('Invalid task index.');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Invalid QR code format',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            elevation: 10,
          ),
        );
      }
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        elevation: 10,
      ),
    );
  }

  void updateTaskStatus(int index, String newStatus) async {
    print("$index , $newStatus");
    try {
      final response = await http.put(
        Uri.parse('https://achin.parthkatiyar.co/team/${widget.teamId}'),
        headers: {
          'Authorization': widget.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'taskCode': index,
          'taskStatus': newStatus,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('$responseData');
        if (responseData['status'] == 'success') {
          setState(() {
            taskStatuses[index] = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Task updated successfully!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              elevation: 10,
            ),
          );
        } else {
          showErrorSnackbar('Failed to update task status');
        }
      } else {
        showErrorSnackbar('Failed to update task status');
      }
    } catch (e) {
      showErrorSnackbar('An unexpected error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FireCursor(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.teamName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: taskStatuses.asMap().entries.map((entry) {
                      int index = entry.key;
                      String taskStatus = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onLongPressStart: (LongPressStartDetails details) {
                            if (widget.userRole == 'admin') {
                              showPopupMenu(
                                  context, details.globalPosition, index);
                            }
                          },
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getButtonColor(taskStatus),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              textStyle: const TextStyle(fontSize: 16),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Task ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  getButtonIcon(taskStatus),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (widget.userRole == 'scanner')
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: scanQRCode,
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      size: 30,
                      color: Colors.grey,
                    ),
                    label: const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color getButtonColor(String status) {
    switch (status) {
      case 'low':
        return Colors.red;
      case 'mid':
        return Colors.yellow;
      case 'high':
        return Colors.green;
      case 'current':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  IconData getButtonIcon(String status) {
    switch (status) {
      case 'low':
        return Icons.close;
      case 'mid':
        return Icons.radio_button_unchecked;
      case 'high':
        return Icons.check_circle;
      case 'current':
        return Icons.remove;
      default:
        return Icons.help_outline;
    }
  }
}
