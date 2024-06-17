// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:process/process.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/solarized-dark.dart';
import 'package:flutter_highlight/themes/vs.dart';

const List<String> methods = <String>['GET', 'POST', 'PUT'];

void main() {
  runApp(MyApp());
  doWhenWindowReady(() {
    final initialSize = Size(1080, 620);
    appWindow.size = initialSize;
    appWindow.minSize = Size(800, 600);
    appWindow.alignment = Alignment.center;
    appWindow.title = "Postman Lite";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _selectedMethod = 'GET';
  String _response = '';

  Future<void> _sendRequest() async {
    final url = _urlController.text;
    final body = _bodyController.text;
    http.Response response;

    try {
      switch (_selectedMethod) {
        case 'GET':
          response = await http.get(Uri.parse(url));
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          );
          break;
        default:
          response = await http.get(Uri.parse(url));
      }
      setState(() {
        _response = _formatJson(response.body);
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }
  }

  String _formatJson(String json) {
    try {
      var jsonObject = jsonDecode(json);
      var encoder = JsonEncoder.withIndent("  ");
      return encoder.convert(jsonObject);
    } catch (e) {
      return json;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Postman Lite'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      width: 150.0,
                      child: DropdownButton<String>(
                          value: _selectedMethod,
                          itemHeight: 60.0,
                          isExpanded: true,
                          dropdownColor: Colors.blue[20],
                          items: methods
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMethod = newValue!;
                            });
                          }),
                    ),
                  ],
                ),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'API URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Request Body(JSON) - if any',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _sendRequest, child: Text('Send Request')),
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                //height: 150.0,
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8.0)),
                child: HighlightView(
                  _response,
                  language: 'json',
                  theme: monokaiSublimeTheme,
                  padding: EdgeInsets.all(12),
                  textStyle: TextStyle(
                      fontFamily: 'Consolas',
                      fontSize: 14,
                      color: Colors.white),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
