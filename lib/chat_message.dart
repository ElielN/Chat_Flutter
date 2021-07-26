import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;

  final bool mine;

  ChatMessage(this.data, this.mine);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          //Se não for mensagem minha, a foto deverá aparecer do lado esquerdo
          !mine ?
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            )
          ) : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                data["imageUrl"] != null ?
                    Image.network(data["imageUrl"], width: 250.0,)
                :
                    Text(
                      data["text"],
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                Text(
                  data["senderName"],
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            )
          ),
          //Se for mensagem minha, a foto deverá aparecer do lado direito
          mine ?
          Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data["senderPhotoUrl"]),
              )
          ) : Container(),
        ],
      ),
    );
  }
}
