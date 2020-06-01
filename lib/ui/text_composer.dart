import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, PickedFile file}) sendMsg;
  TextComposer(this.sendMsg);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  TextEditingController controller = TextEditingController();

  void resetField(){
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: ()async{
              final PickedFile file = await ImagePicker.platform.pickImage(source: ImageSource.camera);
              if(file == null) return;
              widget.sendMsg(file: file);
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(hintText:"Enviar uma mensagem"),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendMsg(text: text);
                resetField();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing? (){
              widget.sendMsg(text: controller.text);
              resetField();
            }:null,
          )
        ],
      ),
    );
  }
}
