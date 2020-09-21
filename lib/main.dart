import "dart:async";
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

const request = "https://api.hgbrasil.com/finance?format=json&key=2d663f79";

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = new TextEditingController();
  final dolarController = new TextEditingController();
  final euroController = new TextEditingController();

  double dolar;
  double euro;

  void _removeAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _changeTheme(){

    runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.blue,
          primaryColor: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            hintStyle: TextStyle(color: Colors.blue),
          )),
    ));
  }

  void _realChange(String text) {
    if(text.isEmpty){
      _removeAll();
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void _dolarChange(String text) {
    if(text.isEmpty){
      _removeAll();
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    if(text.isEmpty){
      _removeAll();
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: (Colors.black),
              ),
              onPressed: () {
                _removeAll();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.color_lens,
                color: (Colors.black),
              ),
              onPressed: () {
                _changeTheme();
              },
            )
          ],
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao carregar dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextField(
                              "Real", "R\$", realController, _realChange),
                          Divider(height: 35),
                          buildTextField(
                              "Dólar", "US\$", dolarController, _dolarChange),
                          Divider(height: 35),
                          buildTextField(
                              "Euro", "€", euroController, _euroChange)
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController control, Function func) {
  return TextField(
    controller: control,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: func,
    keyboardType: TextInputType.number,
  );
}
