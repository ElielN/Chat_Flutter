import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


void main() {

  runApp(MyApp());

  //Firestore: acessa o banco de dados
  //.instance: instancia um único objeto no padrão singleton. Em qualquer parte do código ele é único
  //Se tirarmos o parâmetro de document, o firebase irá criar um id único no lugar
  //Para alterar um dado é melhor usar o .updateData porque podemos colocar apenas o campo a ser alterado
  /*
  Firestore.instance.collection("mensagens").document("Hxzoo4pgXQL3kslKXXwG").collection("arquivos").document().setData({
    "arqname": "picyure.png"
  }); //setData sempre recebe um map
  */
  /*
  Existem basicamente 2 formas de se obter os dados do firebase.
  a primeira é ler o dado apenas uma vez (se ele modificar vocŵ só saberá se puxar o dado novamente)
  e a segunda é receber dados de modificação (sempre que o dado mudar no banco de dados, você será notificado)


  //PRIMEIRA FORMA:
  //Puxar vários documentos
  QuerySnapshot snapshot = await Firestore.instance.collection("mensagens").getDocuments() //Primeira formaa
  snapshot.documents.forEach((d){
    print(d.data);
    print(d.documentID);
    d.reference.updateData({"read" : true});
  });

  //Puxar um único documento
  DocumentSnapshot snapshot = await Firestore.instance.collection("mensagens").document("Hxzoo4pgXQL3kslKXXwG").get();
  print(snapshot.data);


  //SEGUNDA FORMA:
  Firestone.instance.collection("mensagens").snapshots().listen((dado){ //Todos os documentos são passados para este parâmetro dado assim que houver uma atualização
    dado.documents.forEach((d){
      print(d.data);
    });
  });
   */
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData( //Defina a cor de todos os ícones do app
          color: Colors.blue
        )
      ),
      home: ChatScreen(),
    );
  }
}