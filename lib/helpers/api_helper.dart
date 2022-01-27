import 'dart:convert';

import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/Vehicle_type.dart';
import 'package:vehicle_app/models/brand.dart';
import 'package:vehicle_app/models/document_type.dart';
import 'package:vehicle_app/models/history.dart';
import 'package:vehicle_app/models/procedure.dart';
import 'package:vehicle_app/models/response.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_app/models/token.dart';
import 'package:vehicle_app/models/user.dart';
import 'package:vehicle_app/models/vehicle.dart';

class ApiHelper {


  static Future<Response> getVehicle(Token token, String id) async {
    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Vehicles/$id');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    var decodedJson = jsonDecode(body);
    return Response(isSucces: true, result: Vehicle.fromJson(decodedJson));
  }

  static Future<Response> getProcedures(Token token) async {
    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Procedures');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    List<Procedure> list = [];

    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(Procedure.fromJson(item));
      }
    }

    return Response(isSucces: true, result: list);
  }

  static Future<Response> getBrands(Token token) async {

    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Brands');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    List<Brand> list = [];

    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(Brand.fromJson(item));
      }
    }

    return Response(isSucces: true, result: list);
  }

  static Future<Response> getDocumentType() async {
    

    var url = Uri.parse('${Constans.apiUrl}/api/DocumentTypes');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    List<DocumentType> list = [];

    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(DocumentType.fromJson(item));
      }
    }

    return Response(isSucces: true, result: list);
  }

  static Future<Response> getVehicleType(Token token) async {

    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    var url = Uri.parse('${Constans.apiUrl}/api/VehicleTypes');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    List<VehicleType> list = [];

    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(VehicleType.fromJson(item));
      }
    }

    return Response(isSucces: true, result: list);
  }

  static Future<Response> getUsers(Token token) async {

    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Users');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    List<User> list = [];

    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(User.fromJson(item));
      }
    }

    return Response(isSucces: true, result: list);
  }

 static Future<Response> getHistory(Token token, String id) async {
    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Histories/$id');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

    var decodedJson = jsonDecode(body);
    return Response(isSucces: true, result: History.fromJson(decodedJson));
  }

  static Future<Response> getUser(Token token, String id) async {

    if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Users/$id');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: body);
    }

   

    var decodedJson = jsonDecode(body);
  
    return Response(isSucces: true, result: User.fromJson(decodedJson));
  }

  static Future<Response> put(String controller, String id, Map<String, dynamic> request, Token token) async {

        if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    var url = Uri.parse('${Constans.apiUrl}$controller$id');
    var response = await http.put(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: response.body);
    }

    return Response(isSucces: true);
  }

  static Future<Response> post(String controller, Map<String, dynamic> request, Token token) async {
        if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    var url = Uri.parse('${Constans.apiUrl}$controller');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: response.body);
    }

    return Response(isSucces: true);
  }

  static Future<Response> delete( String controller, String id, Token token) async {
        if (!_validToken(token)) {
      return Response(isSucces: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    var url = Uri.parse('${Constans.apiUrl}$controller$id');
    var response = await http.delete(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: response.body);
    }

    return Response(isSucces: true);
  }

  static bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }

    return false;
  }

static Future<Response> postNoToken(String controller, Map<String, dynamic> request) async {
    
    var url = Uri.parse('${Constans.apiUrl}$controller');
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      return Response(isSucces: false, message: response.body);
    }

    return Response(isSucces: true);
  }

}
