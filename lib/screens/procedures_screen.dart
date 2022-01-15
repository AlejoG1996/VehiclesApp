import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vehicle_app/components/loader_component.dart';
import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/procedure.dart';
import 'package:vehicle_app/models/token.dart';

import 'package:http/http.dart' as http;

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
            : Text('Procedimientos'),
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
}
