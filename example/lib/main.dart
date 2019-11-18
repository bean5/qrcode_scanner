import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _scanned_codes = List<String>();
  Uint8List bytes = Uint8List(0);
  TextEditingController _outputController;

  get _scanned_code_widgets => _scanned_codes
      .map<Widget>((code) => Card(
              child: Row(
            children: <Widget>[
              Text(
                "code",
                style: TextStyle(color: Colors.black),
              ),
              FlatButton(
                child: Icon(Icons.content_copy),
                onPressed: null,
              ),
              FlatButton(
                child: Icon(Icons.save),
                onPressed: null,
              ),
              FlatButton(
                child: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _scanned_codes.remove(code);
                  });
                },
              )
            ],
          )))
      .toList();

  void _reset() {
    setState(() {
      _scanned_codes.clear();
    });
  }

  @override
  initState() {
    super.initState();
    this._outputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 150),
                      Container(
                        height: 390,
                        child: _scanned_codes.isEmpty
                            ? Text(
                                'The codes you scan will be displayed in this area.')
                            : Column(
                                children: _scanned_code_widgets,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: this._buttonGroup(),
        ),
      ),
    );
  }

  Widget _buttonGroup() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 120,
            child: InkWell(
              onTap: _scan,
              child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Image.asset('images/scanner.png'),
                    ),
                    Divider(height: 20),
                    Expanded(flex: 1, child: Text("Scan")),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 120,
            child: InkWell(
              onTap: _scanPhoto,
              child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Image.asset('images/albums.png'),
                    ),
                    Divider(height: 20),
                    Expanded(flex: 1, child: Text("Scan Photo")),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 120,
            child: FlatButton(
              onPressed: _scanned_codes.isEmpty ? null : _saveCodes,
              child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Icon(Icons.save),
                    ),
                    Divider(height: 20),
                    Expanded(
                        flex: 1,
                        child: Text(_scanned_codes.length == 1
                            ? "Save Code"
                            : "Save Codes")),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 120,
            child: FlatButton(
              onPressed: _scanned_codes.isEmpty ? null : _reset,
              child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Icon(Icons.clear),
                    ),
                    Divider(height: 20),
                    Expanded(
                      flex: 1,
                      child: Text("Reset"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _scan() async {
    // final String code = await scanner.scan();
    final String code = "test";
    if (code == null) {
      print('nothing return.');
    } else {
      // this._outputController.text = code;
      setState(() {
        _scanned_codes.add(code);
      });
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final date = DateTime.now();
    return File('$path/animal tags $date.csv');
  }

  Future<File> _saveCodes() async {
    return (await _localFile)
        .writeAsString("tag\n" + _scanned_codes.join("\n"));
  }

  Future _scanPhoto() async {
    String barcode = await scanner.scanPhoto();
    this._outputController.text = barcode;
  }

  Future _scanPath(String path) async {
    String barcode = await scanner.scanPath(path);
    this._outputController.text = barcode;
  }
}
