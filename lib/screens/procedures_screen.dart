import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_app/components/loader_component.dart';
import 'package:vehicle_app/helpers/api_helper.dart';
import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/procedure.dart';
import 'package:vehicle_app/models/response.dart';
import 'package:vehicle_app/models/token.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vehicle_app/screens/procedure_screen.dart';

class ProceduresScreem extends StatefulWidget {
  final Token token;

  ProceduresScreem({required this.token});

  @override
  _ProceduresScreemState createState() => _ProceduresScreemState();
}

class _ProceduresScreemState extends State<ProceduresScreem> {
  List<Procedure> _procedure = [];

  bool _showLoader = false;

  bool _isFiltered = false;
  String _search = '';

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
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getProcedures() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Response response = await ApiHelper.getProcedures(widget.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSucces) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    setState(() {
      _procedure = response.result;
    });
  }

  Widget _getContent() {
    return _procedure.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay procedimientos con ese criterio de busqueda'
              : 'No hay procedimientos registrados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getProcedures,
      child: ListView(
        children: _procedure.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
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
                            fontSize: 20,
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
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar Procedimientos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Escriba las primeras letras del procedimiento'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: 'Criterio de b??squeda...',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    _search = value;
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar')),
            ],
          );
        });
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Procedure> filteredList = [];
    for (var procedure in _procedure) {
      if (procedure.description.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(procedure);
      }
    }

    setState(() {
      _procedure = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getProcedures();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProcedureScreen(
                  token: widget.token,
                  procedure: Procedure(description: '', id: 0, price: 0),
                )));
    if (result == 'yes') {
      _getProcedures();
    }
  }

  void _goEdit(Procedure procedure) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProcedureScreen(
                  token: widget.token,
                  procedure: procedure,
                )));
    if (result == 'yes') {
      _getProcedures();
    }
  }
}
