import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "LoginDialog.dart";
import "Model.dart" show MobiChatModel, model;
import "Home.dart";
import "Lobby.dart";
import "Room.dart";
import "UserList.dart";
import "CreateRoom.dart";


var credentials;
var exists;


void main() {

  WidgetsFlutterBinding.ensureInitialized();


  startMeUp() async {

    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    var credentialsFile = File(join(model.docsDir.path, "credentials"));
    exists = await credentialsFile.exists();


    if (exists) {
      credentials = await credentialsFile.readAsString();
    }

    runApp(MobiChat());

  } 


  startMeUp();

} 



class MobiChat extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : Scaffold(body : MobiChatMain()));
  }
}



class MobiChatMain extends StatelessWidget {



  @override
  Widget build(final BuildContext inContext) {


    model.rootBuildContext = inContext;


    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());

    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return MaterialApp(initialRoute : "/",
          routes : {
            "/Lobby" : (screenContext) => Lobby(),
            "/Room" : (screenContext) => Room(),
            "/UserList" : (screenContext) => UserList(),
            "/CreateRoom" : (screenContext) => CreateRoom()
          },
          home : Home()
        );
      }
    ));

  } 





  Future<void> executeAfterBuild() async {

    if (exists) {

      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);

    } else {

      await showDialog(context : model.rootBuildContext, barrierDismissible : false,
        builder : (BuildContext inDialogContext) {
          return LoginDialog();
        }
      );

    }

  }


} 
