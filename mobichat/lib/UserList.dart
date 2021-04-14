import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "AppDrawer.dart";


class UserList extends StatelessWidget {



  Widget build(final BuildContext inContext) {



    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Scaffold(
          appBar : AppBar(title : Text("Пользователь")),
          drawer : AppDrawer(),
          body :  GridView.builder(
            itemCount: model.userList.length,
            gridDelegate : SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount : 3),
            itemBuilder : (BuildContext inContext, int inIndex) {
              Map user = model.userList[inIndex];
              return Padding(padding : EdgeInsets.fromLTRB(10, 10, 10, 10), child : Card(
                child : Padding(padding : EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child : GridTile(
                    child : Center(child : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child : Image.asset("assets/user2.png")
                    )),
                    footer : Text(user["userName"], textAlign : TextAlign.center)
                  )
                )
              ));
            }
          )
        );
      }
    ));

  } 


} 