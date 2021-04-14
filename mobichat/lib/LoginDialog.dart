import "dart:io";
import "package:path/path.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "Connector.dart" as connector;




final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();


// ignore: must_be_immutable
class LoginDialog extends StatelessWidget {



  String _userName;


  
  String _password;


  
  Widget build(final BuildContext inContext) {


    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return AlertDialog(
          content : Container(height : 220,
            child : Form(key : _loginFormKey,
              child : Column(
                children : [
                  Text("Пожалуйста введите имя пользователя и пароль для регистраций в сервере", textAlign : TextAlign.center,
                    style : TextStyle(color : Theme.of(model.rootBuildContext).accentColor, fontSize : 18)
                  ),
                  SizedBox(height : 20),
                  TextFormField(
                    validator : (String inValue) {
                      if (inValue.length == 0 || inValue.length > 10) {
                        return "Пожалуйств введите имя пользователя не выше 10 символов";
                      }
                      return null;
                    },
                    onSaved : (String inValue) { _userName = inValue; },
                    decoration : InputDecoration(hintText : "Username", labelText : "Username")
                  ),
                  TextFormField(obscureText : true,
                    validator : (String inValue) {
                      if (inValue.length == 0) { return "Пожалуйста введите пароль для регистраций"; }
                      return null;
                    },
                    onSaved : (String inValue) { _password = inValue; },
                    decoration : InputDecoration(hintText : "Password", labelText : "Password")
                  )
                ] 
              ) 
            ) 
          ), 
          actions : [
            ElevatedButton(
              child : Text(" Вход "),
              onPressed : () {
                if (_loginFormKey.currentState.validate()) {
                  _loginFormKey.currentState.save();
                  connector.connectToServer(() {
                    connector.validate(_userName, _password, (inStatus) async {
                      if (inStatus == "ok") {
                        model.setUserName(_userName);
                        Navigator.of(model.rootBuildContext).pop();
                        model.setGreeting("Добро пожаловать, $_userName!");
                      } else if (inStatus == "fail") {
                        ScaffoldMessenger.of(model.rootBuildContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Извините, пользователь уже существует")
                          )
                        );

                      } else if (inStatus == "created") {
                        var credentialsFile = File(join(model.docsDir.path, "credentials"));
                        await credentialsFile.writeAsString("$_userName============$_password");
                        model.setUserName(_userName);
                        Navigator.of(model.rootBuildContext).pop();
                        model.setGreeting("Welcome to the server, $_userName!");
                      }
                    });
                  });
                }
              } 
            ) 
          ] 
        ); 
      } 
    )); 

  } 



  void validateWithStoredCredentials(final String inUserName, final String inPassword) {



    connector.connectToServer(() {
      connector.validate(inUserName, inPassword, (inStatus) {
        if (inStatus == "ok" || inStatus == "created") {
          model.setUserName(inUserName);
          model.setGreeting("Добро пожаловать, $inUserName!");

        } else if (inStatus == "fail") {
          showDialog(context : model.rootBuildContext, barrierDismissible : false,
            builder : (final BuildContext inDialogContext) => AlertDialog(
              title : Text("Регистрация прервана"),
              content : Text("Пользователь с таким именем уже существует "
                "\n\nПожалуйтста выберите другое имений пользователя."
              ),
              actions : [
                ElevatedButton(child : Text("Да"), onPressed : () {
                  
                  var credentialsFile = File(join(model.docsDir.path, "credentials"));
                  credentialsFile.deleteSync();
                  
                  exit(0);
                })
              ]
            )
          );
        }
      });
    });

  }


} 
