import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/*
  Mensagem para mim no futuro ao vir consultar este código:
  Não esqueça de colocar as permissões do App
  Além disso, tem um bug em que, mesmo com as permissões, ele não estava abrindo a câmera ou galeria
  Para solucionar este problema, você deve ir em android/build.gradle e colocar isto aqui classpath 'com.android.tools.build:gradle:3.5.0'
  Se já tiver algo do tipo, então substitua
  Não quebre a cabeça pedindo permissão ao usuário, isso está sendo feito automaticamente
  Na hora de gerar o apk, o AS indicou muitos warnings por causa da versão do cloudfirestone mas não prejudicou em nada
 */


class TextComposer extends StatefulWidget {

  final Function({String text, File imgFile}) sendMessage; //sendMessage é do tipo Function

  TextComposer(this.sendMessage); //Construtor que recebe como parâmetro uma função

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
      child: Row(
        children: [
          IconButton(
            //color: Colors.blue,
            onPressed: () async {
              _showOption(context);
            },
            icon: Icon(Icons.photo_camera)
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration( //O .collapsed faz com que ele fique comprimido na parte de baixo
                hintText:"Enviar uma Mensagem",
                filled: true,
                fillColor: Color(0xffEFEDED),
                isCollapsed: false,
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: OutlineInputBorder( //Define a cor da borda do campo input antes de ser clicada
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.white, width: 0.0)
                ),
              ),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                if(text == "") return;
                widget.sendMessage(text: text); //Na definição da função (no arquivo chat_screen), foi definido que a função recebe um text
                _reset();
              },
            )
          ),
          IconButton(
            onPressed: _isComposing ? (){ //Se há algum text no textFiel, então ativamos a função. Caso contrário ela ficará desativada
              widget.sendMessage(text: _controller.text); //Essa função na verdade foi criada no arquivo chat_screen
              _reset();
            } : null,
            icon: Icon(Icons.send)
          )
        ],
      ),
    );
  }
  void _showOption(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){

          },
          builder: (context){
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 100.0),
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    iconSize: 45.0,
                    icon: Icon(Icons.photo),
                    onPressed: () async {
                      //var status = await Permission.photos.status;
                      final picker = ImagePicker();
                      final imgFile = await picker.getImage(source: ImageSource.gallery);
                      File storedImage = File(imgFile.path);
                      if(storedImage == null) return;
                      widget.sendMessage(imgFile: storedImage);
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    iconSize: 45.0,
                    icon: Icon(Icons.camera),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final imgFile = await picker.getImage(source: ImageSource.camera);
                      File storedImage = File(imgFile.path);
                      if(storedImage == null) return;
                      widget.sendMessage(imgFile: storedImage);
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            );
          }
        );
      }
    );
  }
}
/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  final Function({String text, File imgFile}) sendMessage; //sendMessage é do tipo Function

  TextComposer(this.sendMessage); //Construtor que recebe como parâmetro uma função

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: [
          IconButton(
            //color: Colors.blue,
            onPressed: () async {
              final picker = ImagePicker();
              final imgFile = await picker.getImage(source: ImageSource.camera);
              File storedImage = File(imgFile.path);
              if(storedImage == null) return;
              widget.sendMessage(imgFile: storedImage);
            },
            icon: Icon(Icons.photo_camera)
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed( //O .collapsed faz com que ele fique comprimido na parte de baixo
                hintText:"Enviar uma Mensagem"
              ),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendMessage(text: text); //Na definição da função (no arquivo chat_screen), foi definido que a função recebe um text
                _reset();
              },
            )
          ),
          IconButton(
            onPressed: _isComposing ? (){ //Se há algum text no textFiel, então ativamos a função. Caso contrário ela ficará desativada
              widget.sendMessage(text: _controller.text); //Essa função na verdade foi criada no arquivo chat_screen
              _reset();
            } : null,
            icon: Icon(Icons.send)
          )
        ],
      ),
    );
  }
}

 */