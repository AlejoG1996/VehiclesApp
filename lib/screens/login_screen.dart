import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:vehicle_app/components/loader_component.dart';
import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/token.dart';
import 'package:vehicle_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = 'luis@yopmail.com';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '123456';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordshow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _showLogo(),
              SizedBox(
                height: 20,
              ),
              _showEmail(),
              _showPassrod(),
              _showRememberme(),
              _showButtons(),
            ],
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Porfavor espere...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/fuego.png'),
      width: 300,
      height: 150,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa tu Email....',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassrod() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordshow,
        decoration: InputDecoration(
          hintText: 'Ingresa tu Contraseña....',
          labelText: 'Contraseña',
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordshow
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordshow = !_passwordshow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme'),
      value: _rememberme,
      onChanged: (value) {
        setState(() {
          _rememberme = value!;
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text('Iniciar Sesion'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0XFFFF3600);
                }),
              ),
              onPressed: () => _login(),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              child: Text('Nuevo Usuario'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0XFF000000);
                }),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _passwordshow = false;
    });

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });
    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Account/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Email o contraseña incorrectos";
      });
      return;
    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }

  bool _validateFields() {
    bool isvalid = true;
    if (_email.isEmpty) {
      isvalid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email';
    } else if (!EmailValidator.validate(_email)) {
      isvalid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email válido';
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      isvalid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contraseña';
    } else if (_password.length < 6) {
      isvalid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar una contraseña de almenos 6 carácteres';
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return isvalid;
  }
}
