import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_app/components/loader_component.dart';
import 'package:vehicle_app/helpers/constans.dart';
import 'package:vehicle_app/models/token.dart';
import 'package:vehicle_app/screens/home_screen.dart';
import 'package:vehicle_app/screens/recover_password_screen.dart';
import 'package:vehicle_app/screens/register_user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordshow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF242B2E),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                _showLogo(),
                SizedBox(
                  height: 20,
                ),
                _showEmail(),
                _showPassrod(),
                _showRememberme(),
                _showForgotPassword(),
                _showButtons(),
              ],
            ),
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
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
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
          fillColor: Colors.white,
          filled: true,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showLoginButton(),
              SizedBox(
                width: 20,
              ),
              _showRegisterButton(),
            ],
          ),
          _showGoogleLoginButton(),
          _showFacebookLoginButton(),
        ],
      ),
    );
  }

  Widget _showFacebookLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginFacebook(),
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                ),
                label: Text('Iniciar sesión con Facebook'),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xFF3B5998), onPrimary: Colors.white)))
      ],
    );
  }

  void _loginFacebook() async {
    await FacebookAuth.i.login();
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );

    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields:
            "email, name, picture.width(800).heigth(800), first_name, last_name",
      );

      var picture = requestData['picture'];
      var data = picture['data'];

      Map<String, dynamic> request = {
        'email': requestData['email'],
        'id': requestData['id'],
        'loginType': 2,
        'fullName': requestData['name'],
        'photoURL': data['url'],
        'firtsName': requestData['first_name'],
        'lastName': requestData['last_name'],
      };
      await _socialLogin(request);
    }
  }

  Future _socialLogin(Map<String, dynamic> request) async {
    var url = Uri.parse('${Constans.apiUrl}/api/Account/SocialLogin');
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
      await showAlertDialog(
          context: context,
          title: 'Error',
          message:
              'El usuario ya inció sesión previamente por email o por otra red social.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    var body = response.body;

    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }

  Widget _showGoogleLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginGoogle(),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                label: Text('Iniciar sesión con Google'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white, onPrimary: Colors.black)))
      ],
    );
  }

  Widget _showRegisterButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Nuevo Usuario'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF000000);
          }),
        ),
        onPressed: () => _register(),
      ),
    );
  }

  Widget _showLoginButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Iniciar Sesión'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFFFF3600);
          }),
        ),
        onPressed: () => _login(),
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
          ]);
      return;
    }
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
    if (_rememberme) {
      _storeUser(body);
    }
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

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }

  void _register() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterUserScreen()));
  }

  Widget _showForgotPassword() {
    return InkWell(
      onTap: () => _goForgotPassword(),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Text(
          '¿Has olvidado tu contraseña?',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  void _goForgotPassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecoverPasswordScreen()));
  }

  void _loginGoogle() async {
    var googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    var user = await googleSignIn.signIn();

    print(user);
  }
}
