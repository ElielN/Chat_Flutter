import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSingIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser? _currentUser;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) { //Sempre que a autenticação mudar, ele chamará a função anônima com o usuário atual
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser?> _getUser() async {

    if(_currentUser != null) return _currentUser; //Verifica se o usuário já está logado

    //Se for nulo então será feito o login:
    try{
      final GoogleSignInAccount googleSingInAccount = await googleSingIn.signIn(); //Logando na conta Google
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSingInAccount.authentication; //Pegando dados de autenticação do Google
      //O googleSingInAuthentication possui 2 tokens que iremos usar para fazer a conexão com o Firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
      );
      //Agora podemos fazer login no Firebase
      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      //O mesmo seria feito para o Facebook, LinkedIn, GitHub etc. A únicacoisa que mudaria seria o provider
      final FirebaseUser user = authResult.user;
      return user;
    } catch(error) {
      return null;
    }
  }

  void _sendMessage({String? text, File? imgFile}) async {

    //final FirebaseUser user = await FirebaseAuth.instance.currentUser(); //Obtém o usuário atual mas seria lento pelo await
    final FirebaseUser? user = await _getUser();
    if(user == null){
      //ScaffoldMessenger.showSnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Não foi possível fazer o login... Tente novamente :("),
          backgroundColor: Colors.red,
        )
      );
    }

    Map<String,dynamic> data = {
      "uid" : user!.uid,
      "senderName" : user.displayName,
      "senderPhotoUrl" : user.photoUrl,
      "time" : Timestamp.now()
    };

    if(imgFile != null){
      //Para que o nome do arquivo seja único, vamos utilizar ms (Não é a melhor forma de se fazer)
      StorageUploadTask task = FirebaseStorage.instance.ref().child(user.uid + DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
      setState(() {
        _isLoading = true;
      });
      StorageTaskSnapshot taskSnapshot = await task.onComplete; //Pois precisamos esperar até que essa operação seja concluída
      //O task.onCOmplete irá nos retornar muitas informações, dentre elas temos um URL de download da imagem que usaremos para exibir a imagem na tela
      String url = await taskSnapshot.ref.getDownloadURL(); //URL de download da imagem
      print(url);
      data["imageUrl"] = url;
      setState(() {
        _isLoading = false;
      });
    }

    if(text != null) data["text"] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, //Para fazer a snackbar
      appBar: AppBar(
        title: Text(
          _currentUser != null ? "Olá, ${_currentUser!.displayName}" : "Chat App"
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          _currentUser != null ? IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSingIn.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Você saiu com sucesso!"),
                  )
              );
            },
            icon: Icon(Icons.exit_to_app),
          ) : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>( //Vamos usar esse widget porque precisamos receber dados novos sempre que houver uma modificação
              stream: Firestore.instance.collection("messages").orderBy("time").snapshots(), //stream permite que a gente receba dados ao longo do tempo, diferente com Future que nos retorna apenas uma vez
              builder: (context, snapshot){ //Quando stream receber um novo dado, o builder será refeito
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data!.documents.reversed.toList(); //Lista de mensagens. A medida que vamos digitando as informações são salvas aqui
                    
                    return ListView.builder( //Possibilita carregar as mensagens a medida que rolamos a tela
                      itemCount: documents.length,
                      reverse: true, //Assim as mensagens aparecerão de baixo para cima
                      itemBuilder: (context, index){
                        return ChatMessage(documents[index].data, documents[index].data["uid"] == _currentUser?.uid);
                      }
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      )
    );
  }
}
