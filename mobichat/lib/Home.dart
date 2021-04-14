import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show MobiChatModel, model;
import "AppDrawer.dart";


class Home extends StatelessWidget {


  
  
  Widget build(final BuildContext inContext) {


    return ScopedModel<MobiChatModel>(model : model, child : ScopedModelDescendant<MobiChatModel>(
      builder : (BuildContext inContext, Widget inChild, MobiChatModel inModel) {
        return Scaffold(
          appBar : AppBar(title : Text("MobiChat")),
          drawer : AppDrawer(),
          body : Center(child : Text(model.greeting))
        );
      }
    ));

  } 


} 