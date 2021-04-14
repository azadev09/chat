import "dart:convert";
import "package:flutter_socket_io/flutter_socket_io.dart";
import "package:flutter_socket_io/socket_io_manager.dart";
import "Model.dart" show MobiChatModel, model;
import "package:flutter/material.dart";



String serverURL = "http://192.168.0.35";



SocketIO _io;



void showPleaseWait() {


  showDialog(context : model.rootBuildContext, barrierDismissible : false,
    builder : (BuildContext inDialogContext) {
      return Dialog(
        child : Container(width : 150, height : 150, alignment : AlignmentDirectional.center,
          decoration : BoxDecoration(color : Colors.blue[200]),
          child : Column(crossAxisAlignment : CrossAxisAlignment.center, mainAxisAlignment : MainAxisAlignment.center,
            children : [
              Center(child : SizedBox(height : 50, width : 50,
                child : CircularProgressIndicator(value : null, strokeWidth : 10)
              )),
              Container(margin : EdgeInsets.only(top : 20),
                child : Center(child : Text("Подождите, подключение к серверу...",
                  style : new TextStyle(color : Colors.white)
                ))
              )
            ]
          )
        )
      );
    }
  );

} 



void hidePleaseWait() {

  Navigator.of(model.rootBuildContext).pop();

} 



void connectToServer(final Function inCallback) {


 
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "", socketStatusCallback :
    (inData) {
      if (inData == "connect") {
        _io.subscribe("newUser", newUser);
        _io.subscribe("created", created);
        _io.subscribe("closed", closed);
        _io.subscribe("joined", joined);
        _io.subscribe("left", left);
        _io.subscribe("kicked", kicked);
        _io.subscribe("invited", invited);
        _io.subscribe("posted", posted);
        inCallback();
      }
    }
  );


_io.destroy();
_io = SocketIOManager().createSocketIO(serverURL, "/", query: "", socketStatusCallback :
  (inData) {
    if (inData == "connect") {
      inCallback();
    }
  }
);

  _io.init();
  _io.connect();

} 




void validate(final String inUserName, final String inPassword, final Function inCallback) {


  showPleaseWait();


  _io.sendMessage("validate",
    "{ \"userName\" : \"$inUserName\", \"password\" : \"$inPassword\" }",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      inCallback(response["status"]);
    }
  );

}



void listRooms(final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("listRooms", "{}",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      inCallback(response);
    }
  );

} 





void create(final String inRoomName, final String inDescription, final int inMaxPeople, final bool inPrivate,
  final String inCreator, final Function inCallback
) {

  showPleaseWait();


  _io.sendMessage("create",
    "{ \"roomName\" : \"$inRoomName\", \"description\" : \"$inDescription\", "
    "\"maxPeople\" : $inMaxPeople, \"private\" : $inPrivate, \"creator\" : \"$inCreator\" }",
    (inData) {

      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();

      inCallback(response["status"], response["rooms"]);
    }
  );

} 




void join(final String inUserName, final String inRoomName, final Function inCallback) {


  showPleaseWait();


  _io.sendMessage("join", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      
      inCallback(response["status"], response["room"]);
    }
  );

} 




void leave(final String inUserName, final String inRoomName, final Function inCallback) {


  showPleaseWait();


  _io.sendMessage("leave", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      inCallback();
    }
  );

}



void listUsers(final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("listUsers", "{}",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      inCallback(response);
    }
  );

} 





void invite(final String inUserName, final String inRoomName, final String inInviterName, final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("invite", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
    "\"inviterName\" : \"$inInviterName\" }",
    (inData) {
      hidePleaseWait();
      inCallback();
    }
  );

}





void post(final String inUserName, final String inRoomName, final String inMessage, final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("post", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
    "\"message\" : \"$inMessage\" }",
    (inData) {
      Map<String, dynamic> response = jsonDecode(inData);
      hidePleaseWait();
      inCallback(response["status"]);
    }
  );

} 




void close(final String inRoomName, final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("close", "{ \"roomName\" : \"$inRoomName\" }",
    (inData) {
      hidePleaseWait();
      inCallback();
    }
  );

} 





void kick(final String inUserName, final String inRoomName, final Function inCallback) {


  showPleaseWait();

  _io.sendMessage("kick", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\" }",
    (inData) {
      hidePleaseWait();
      inCallback();
    }
  );

} 





void newUser(inData) {


  Map<String, dynamic> payload = jsonDecode(inData);

  model.setUserList(payload);

} 




void created(inData) {


  Map<String, dynamic> payload = jsonDecode(inData);

  model.setRoomList(payload);

}





void closed(inData) {


  Map<String, dynamic> payload = jsonDecode(inData);

  model.setRoomList(payload);

  if (payload["roomName"] == model.currentRoomName) {
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(MobiChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    model.setGreeting("Комната, в которой вы находились, была закрыта ее создателем.");
    Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }

}





void joined(inData) {

  Map<String, dynamic> payload = jsonDecode(inData);

  if (model.currentRoomName == payload["roomName"]) {
    model.setCurrentRoomUserList(payload["users"]);
  }

} 





void left(inData) {

  Map<String, dynamic> payload = jsonDecode(inData);

  if (model.currentRoomName == payload["room"]["roomName"]) {
    model.setCurrentRoomUserList(payload["room"]["users"]);
  }

} 





void kicked(inData) {


  Map<String, dynamic> payload = jsonDecode(inData);

  model.removeRoomInvite(payload["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(MobiChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentRoomEnabled(false);
  model.setGreeting("Вас удалили из комнаты!");

  Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));

} 






void invited(inData) async {


  Map<String, dynamic> payload = jsonDecode(inData);

  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];

  model.addRoomInvite(roomName);

  ScaffoldMessenger.of(model.rootBuildContext).showSnackBar(
    SnackBar(backgroundColor : Colors.amber, duration : Duration(seconds : 60),
      content : Text("Вас пригласили в комнату '$roomName' пользователь '$inviterName'.\n\n"
        "Вы можете войти в комнату из Приглашения."
      ),
      action : SnackBarAction(
        label : "Ok",
        onPressed: () { }
      )
    )
  );

} 




void posted(inData) {


  Map<String, dynamic> payload = jsonDecode(inData);

  if (model.currentRoomName == payload["roomName"]) {
    model.addMessage(payload["userName"], payload["message"]);
  }

} 
