import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "AppDrawer.dart";
import "Connector.dart" as connector;


class CreateRoom extends StatefulWidget {
 CreateRoom({Key key}) : super(key : key);
 @override
 _CreateRoom createState() => _CreateRoom();
}


class _CreateRoom extends State {


 
  String _title;
  String _description;
  bool _private = false;
  double _maxPeople = 25;



  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  Widget build(final BuildContext inContext) {


    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Scaffold(
          resizeToAvoidBottomInset: false, // Avoid problem of keyboard causing form fields to vanish.
          appBar : AppBar(title : Text("Создать комнату")),
          drawer : AppDrawer(),
          bottomNavigationBar : Padding(
            padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
            child : SingleChildScrollView(child : Row(
              children : [
                ElevatedButton(
                  child : Text(" Отмена  "),
                  onPressed : () {
                    FocusScope.of(inContext).requestFocus(FocusNode());
                    Navigator.of(inContext).pop();
                  }
                ),
                Spacer(),
                ElevatedButton(
                  child : Text("Сохранить"),
                  onPressed : () {
                    if (!_formKey.currentState.validate()) { return; }
                    _formKey.currentState.save();
                    int maxPeople = _maxPeople.truncate();
                    connector.create(_title, _description, maxPeople, _private, model.userName, (inStatus, inRoomList) {
                      if (inStatus == "created") {
                        model.setRoomList(inRoomList);
                        FocusScope.of(inContext).requestFocus(FocusNode());
                        Navigator.of(inContext).pop();
                      } else {
                        ScaffoldMessenger.of(inContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Извините, эта комната уже существует")
                          )
                        );
                      }
                    });
                  } 
                )
              ] 
            )) 
          ), 
          body : Form(
            key : _formKey,
            child : ListView(
              children : [
                // Name.
                ListTile(
                  leading : Icon(Icons.subject),
                  title : TextFormField(decoration : InputDecoration(hintText : "Название"),
                    validator : (String inValue) {
                      if (inValue.length == 0 || inValue.length > 14) {
                        return "Пожалуйста введите название меньше 14 символов";
                      }
                      return null;
                    },
                    onSaved : (String inValue) { setState(() { _title = inValue; }); }
                  )
                ),
                ListTile(
                  leading : Icon(Icons.description),
                  title : TextFormField(decoration : InputDecoration(hintText : "Описание"),
                    onSaved : (String inValue) { setState(() { _description = inValue; }); }
                  )
                ),
                ListTile(
                  title : Row(children : [
                    Text("Max\nЛюди"),
                    Slider(min : 0, max : 99, value : _maxPeople,
                      onChanged : (double inValue) { setState(() { _maxPeople = inValue; }); }
                    )
                  ]),
                  trailing : Text(_maxPeople.toStringAsFixed(0))
                ),
                ListTile(
                  title : Row(children : [
                    Text("Закрытая комната"),
                    Switch(value : _private,
                      onChanged : (inValue) { setState(() { _private = inValue; }); }
                    )
                  ])
                )
              ] 
            ) 
          ) 
        ); 
      } 
    ));

  } 


} 