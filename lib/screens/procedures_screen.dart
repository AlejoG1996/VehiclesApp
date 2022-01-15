import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vehicle_app/components/loader_component.dart';
import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/procedure.dart';
import 'package:vehicle_app/models/token.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProceduresScreem extends StatefulWidget {
  final Token token;

  ProceduresScreem({required this.token});

  @override
  _ProceduresScreemState createState() => _ProceduresScreemState();
}

class _ProceduresScreemState extends State<ProceduresScreem> {
  List<Procedure> _procedure = [];

  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procedimientos'),
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  void _getProcedures() async {
    setState(() {
      _showLoader = true;
    });
    var url = Uri.parse('${Constans.apiUrl}/api/Procedures');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${widget.token.token}',
      },
    );

    setState(() {
      _showLoader = false;
    });

    var body = response.body;
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        _procedure.add(Procedure.fromJson(item));
      }
    }
  }

  Widget _getContent() {
    return _procedure.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'No hay procedimientos almacenados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return ListView(
      children: _procedure.map((e) {
        return Card(
          child: InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.description,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(e.price)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
