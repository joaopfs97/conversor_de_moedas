import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async{

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color:Colors.white)),
        focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color:Colors.amber)
          )
      )
    ),
    ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Criando controladores
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  //Função para calcular euro e dolar a partir da mudança dos reais
  void _realChanged(String text){
    _clearAll(text);
    double real = double.parse(text); //Capturando valor do real e transformando em double
    dolarController.text = (real/dolar).toStringAsFixed(2); //Convertendo reais para dólares
    euroController.text = (real/euro).toStringAsFixed(2); // Convertendo reais para euros
}
  void _dolarChanged(String text){
    _clearAll(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2); // convertendo dolar para reais
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2); // convertendo dolar para reais e depois em euros
  }
  void _euroChanged(String text){
    _clearAll(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(String text){
    if(text.isEmpty){
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                  style: TextStyle(color: Colors.amber,
                                    fontSize: 25.0),
                  textAlign: TextAlign.center,
                )
              );
            default:
              if (snapshot.hasError){
                return Center(
                    child: Text("Erro ao carregar dados :(",
                      style: TextStyle(color: Colors.amber,
                          fontSize: 25.0),
                      textAlign: TextAlign.center,
                    )
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size:150.0, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "Є\$", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        }
      ),
    );
  }
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label,String prefix, TextEditingController controller, Function f){
  return TextField(
    controller: controller,
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color:Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25
    ),
  );
}