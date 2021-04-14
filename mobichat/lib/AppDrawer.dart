import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "Connector.dart" as connector;


class AppDrawer extends StatelessWidget {



  Widget build(final BuildContext inContext) {

    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Drawer(
          child : Column(children : [
            Container(
              decoration : BoxDecoration(image : DecorationImage(
                image : AssetImage("assets/drawback01.jpg"), fit : BoxFit.cover
              )),
              child : Padding(padding : EdgeInsets.fromLTRB(0, 30, 0, 15),
                child : ListTile(
                  title : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child : Center(child : Text(model.userName,
                      style : TextStyle(color : Colors.white, fontSize : 24)
                    ))
                  ),
                  subtitle : Center(child : Text(model.currentRoomName,
                    style : TextStyle(color : Colors.white, fontSize : 16)
                  ))
                )
              )
            ),
            Padding(padding : EdgeInsets.fromLTRB(0, 20, 0, 0),
              child : ListTile(
                leading : Icon(Icons.list),
                title : Text("Комнаты"),
                onTap: () {
                  Navigator.of(inContext).pushNamedAndRemoveUntil("/Lobby", ModalRoute.withName("/"));
                connector.listRooms((inRoomList) {
                  model.setRoomList(inRoomList);
                });
                }
              )
            ),
            ListTile(
              enabled : model.currentRoomEnabled,
              leading : Icon(Icons.forum),
              title : Text("Мессенджер"),
              onTap: () {
                Navigator.of(inContext).pushNamedAndRemoveUntil("/Room", ModalRoute.withName("/"));
              }
            ),
            ListTile(
              leading : Icon(Icons.face),
              title : Text("Список пользователей"),
              onTap: () {
                Navigator.of(inContext).pushNamedAndRemoveUntil("/UserList", ModalRoute.withName("/"));
                connector.listUsers((inUserList) {
                  model.setUserList(inUserList);
                });
              }
            )
          ]) 
        );
      }
    )); 

  }


} 