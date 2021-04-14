import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "AppDrawer.dart";
import "Connector.dart" as connector;


class Room extends StatefulWidget {
 Room({Key key}) : super(key : key);
 @override
 _Room createState() => _Room();
}


class _Room extends State {



  bool _expanded = false;



  String _postMessage;



  final ScrollController _controller = ScrollController();


  final TextEditingController _postEditingController = TextEditingController();




  Widget build(final BuildContext inContext) {


    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Scaffold(resizeToAvoidBottomInset : false,
          appBar : AppBar(title : Text(model.currentRoomName),
            actions : [
              // Function menu.
              PopupMenuButton(
                onSelected : (inValue) {
                  if (inValue == "invite") {
                    _inviteOrKick(inContext, "invite");
                  } else if (inValue == "leave") {
                    connector.leave(model.userName, model.currentRoomName, () {
                      
                      model.removeRoomInvite(model.currentRoomName);
                      model.setCurrentRoomUserList({});
                      model.setCurrentRoomName(MobiChatModel.DEFAULT_ROOM_NAME);
                      model.setCurrentRoomEnabled(false);
                      
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "close") {
                    connector.close(model.currentRoomName, () {
                      
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "kick") {
                    _inviteOrKick(inContext, "kick");
                  }
                },
                itemBuilder : (BuildContext inPMBContext) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem(value : "leave", child : Text("Покинуть комнату")),
                    PopupMenuItem(value : "invite", child : Text("Пригласить пользователя")),
                    PopupMenuDivider(),
                    PopupMenuItem(value : "close", child : Text("Закрыть комнату"), enabled : model.creatorFunctionsEnabled),
                    PopupMenuItem(value : "kick", child : Text("Удалить пользователя"), enabled : model.creatorFunctionsEnabled)
                  ];
                }
              )
            ]
          ), 
          drawer : AppDrawer(),
          body : Padding(padding : EdgeInsets.fromLTRB(6, 14, 6, 6),
            child : Column(
              children : [
                
                ExpansionPanelList(
                  expansionCallback : (inIndex, inExpanded) => setState(() { _expanded = !_expanded; }),
                  children : [
                    ExpansionPanel(isExpanded : _expanded,
                      headerBuilder : (BuildContext context, bool isExpanded) => Text(" Пользователь в комнате "),
                      body : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child : Builder(builder : (inBuilderContext) {
                          List<Widget> userList = [ ];
                          for (var user in model.currentRoomUserList) {
                            userList.add(Text(user["userName"]));
                          }
                          return Column(children : userList);
                        })
                      )
                    )
                  ]
                ),
                Container(height : 10),
                
                Expanded(child : ListView.builder(controller : _controller,
                  itemCount : model.currentRoomMessages.length,
                  itemBuilder : (inContext, inIndex) {
                    Map message = model.currentRoomMessages[inIndex];
                    return ListTile(
                      subtitle : Text(message["userName"]),
                      title : Text(message["message"])
                    );
                  }
                )), 
                Divider(),
                Row(children : [
                  Flexible(child : TextField(controller : _postEditingController,
                    onChanged : (String inText) => setState(() { _postMessage = inText; }),
                    decoration : new InputDecoration.collapsed(hintText : "Отправить сообщение"),
                  )),
                  Container(margin : new EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child : IconButton(icon : Icon(Icons.send), color : Colors.blue,
                      onPressed : () {
                        connector.post(model.userName, model.currentRoomName, _postMessage, (inStatus) {
                          if (inStatus == "ok") {
                            model.addMessage(model.userName, _postMessage);
                            _controller.jumpTo(_controller.position.maxScrollExtent);
                          }
                        });
                      }
                    )
                  )
                ]) 
              ] 
            ) 
          ) 
        ); 
      } 
    )); 

  }




  _inviteOrKick(final BuildContext inContext, final String inInviteOrKick) {

  
    connector.listUsers((inUserList) {



      model.setUserList(inUserList);


      showDialog(context : inContext,
        builder : (BuildContext inDialogContext) {
          return ScopedModel<MobiChatModel>(model : model,
            child : ScopedModelDescendant<MobiChatModel>(
              builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
                return AlertDialog(title : Text("Пользователь $inInviteOrKick"),
                  content : Container(width : double.maxFinite, height : double.maxFinite / 2,
                    child : ListView.builder(
                      itemCount : inInviteOrKick == "invite" ? model.userList.length : model.currentRoomUserList,
                      itemBuilder : (BuildContext inBuildContext, int inIndex) {
                        Map user;
                        if (inInviteOrKick == "invite") {
                          user = model.userList[inIndex];

                        } else {
                          user = model.currentRoomUserList[inIndex];
                        }
                        if (user["userName"] == model.userName) { return Container(); }
                        
                        return Container(
                          decoration : BoxDecoration(
                            borderRadius : BorderRadius.all(Radius.circular(15.0)),
                            border : Border(
                              bottom : BorderSide(), top : BorderSide(),
                              left : BorderSide(), right : BorderSide()
                            ),
                            gradient : LinearGradient(begin : Alignment.topLeft, end : Alignment.bottomRight,
                              stops : [ .1, .2, .3, .4, .5, .6, .7, .8, .9],
                              colors : [
                                Color.fromRGBO(250, 250, 0, .75), Color.fromRGBO(250, 220, 0, .75),
                                Color.fromRGBO(250, 190, 0, .75), Color.fromRGBO(250, 160, 0, .75),
                                Color.fromRGBO(250, 130, 0, .75), Color.fromRGBO(250, 110, 0, .75),
                                Color.fromRGBO(250, 80, 0, .75), Color.fromRGBO(250, 50, 0, .75),
                                Color.fromRGBO(250, 0, 0, .75)
                              ]
                            )
                          ),
                          margin : EdgeInsets.only(top : 10.0),
                          child : ListTile(title : Text(user["userName"]),
                            onTap : () {
                              if (inInviteOrKick == "invite") {
                                connector.invite(user["userName"], model.currentRoomName, model.userName, () {
                                  Navigator.of(inContext).pop();
                                });
                              } else {
                                connector.kick(user["userName"], model.currentRoomName, () {
                                  
                                  Navigator.of(inContext).pop();
                                });
                              }
                            }
                          )
                        );
                      } 
                    ) 
                  ) 
                ); 
              } 
            ) 
          ); 
        } 
      ); 

    }); 

  } 


} 