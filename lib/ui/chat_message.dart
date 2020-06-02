import 'package:flutter/material.dart';
class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool mine;
  ChatMessage(this.data,this.mine);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          mine?Padding(
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhoto']),
            ),
            padding: mine? EdgeInsets.only(right: 16):EdgeInsets.only(left: 16),
          ):Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine? CrossAxisAlignment.start: CrossAxisAlignment.end,
              children: <Widget>[
                (data['imageURL']!=null?
                    Image.network(data['imageURL'],width: 250,):
                    Text(data['text'],
                      style: TextStyle(
                        fontSize: 16
                      ),
                      textAlign: mine? TextAlign.start:TextAlign.end,
                    )),

                Text(
                  data['senderName'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          ),
          (!mine)?Padding(
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhoto']),
            ),
            padding: mine? EdgeInsets.only(right: 16):EdgeInsets.only(left: 16),
          ):Container(),
        ],
      ),
    );
  }
}
