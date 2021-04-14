import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "AppDrawer.dart";
import "Connector.dart" as connector;


class Lobby extends StatelessWidget {


 
 
  Widget build(final BuildContext inContext) {


    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Scaffold(
          appBar : AppBar(title : Text("Комнаты")),
          drawer : AppDrawer(),
          
          floatingActionButton : FloatingActionButton(
            child : Icon(Icons.add, color : Colors.white),
            onPressed : () { Navigator.pushNamed(inContext, "/CreateRoom"); }
          ),
          body : model.roomList.length == 0 ? Center(child : Text("Комнаты не существует")) :
            ListView.builder(
            itemCount : model.roomList.length,
            itemBuilder : (BuildContext inBuildContext, int inIndex) {
              Map room = model.roomList[inIndex];
              String roomName = room["roomName"];
              return Column(
                children : [
                  ListTile(
                    leading : room["private"] ? Image.asset("assets/private.png") : Image.asset("assets/public.png"),
                    title : Text(roomName),
                    subtitle : Text(room["description"]),
                    
                    onTap : () {
                      
                      if (room["private"] && !model.roomInvites.containsKey(roomName) &&
                        room["creator"] != model.userName
                      ) {
                        ScaffoldMessenger.of(inBuildContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Извините, вы не можете вступить в закрытую комнату")
                          )
                        );
                      } else {
                        connector.join(model.userName, roomName, (inStatus, inRoomDescriptor) {
                          if (inStatus == "joined") {
                            model.setCurrentRoomName(inRoomDescriptor["roomName"]);
                            model.setCurrentRoomUserList(inRoomDescriptor["users"]);
                            model.setCurrentRoomEnabled(true);
                            model.clearCurrentRoomMessages();
                            if (inRoomDescriptor["creator"] == model.userName) {
                              model.setCreatorFunctionsEnabled(true);
                            } else {
                              model.setCreatorFunctionsEnabled(false);
                            }
                            Navigator.pushNamed(inContext, "/Room");
                          } else if (inStatus == "full") {
                            ScaffoldMessenger.of(inBuildContext).showSnackBar(
                              SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                                content : Text("Извините, комната полон пользователями")
                              )
                            );
                          }
                        });
                      }
                    } 
                  ),
                  Divider()
                ] 
              );
            } 
          ) 
        ); 
      } 
    ));

  } 


} 