import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/pages/groupchats/singlemsgtile.dart';
import 'package:locationtracker/pages/groupchats/wallpaperpage.dart';
import 'package:random_color/random_color.dart';

class GroupChat extends StatefulWidget {
  const GroupChat(
      {Key? key,
      required this.username,
      required this.users,
      required this.groupname,
      required this.grpid,
      required this.isDark})
      : super(key: key);
  final String username, groupname, grpid;
  final List users;
  final bool isDark;

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  bool iseditchange = false;
  bool isEdit = false;
  final TextEditingController _chatController = new TextEditingController();
  final chatFocusNode = FocusNode();
  Map<String, dynamic> chatMessageMap = {};
  RandomColor _randomColor = RandomColor();
  late List chatcolors;

  @override
  void initState() {
    chatcolors = List.generate(
        widget.users.length,
        (i) => i == widget.users.indexOf(widget.username)
            ? _randomColor.randomColor(
                colorHue: ColorHue.blue,
                colorBrightness: widget.isDark
                    ? ColorBrightness.veryDark
                    : ColorBrightness.dark)
            : _randomColor.randomColor(
                colorHue: ColorHue.blue,
                colorBrightness: widget.isDark
                    ? ColorBrightness.dark
                    : ColorBrightness.veryLight));
  }

  Future<void> setChatData(String text, int time) async {
    if (chatMessageMap != {}) {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.grpid)
          .collection('chats')
          .add(chatMessageMap);
      chatMessageMap = {};
    }
  }

  void _handleSubmitted(String text) {
    if (text != '') {
      setState(() {
        isEdit = false;
      });
      _chatController.clear();
      chatMessageMap = {
        "sendBy": widget.username,
        "message": text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      setChatData(text, DateTime.now().millisecondsSinceEpoch);
    }
  }

  void handleClick(String value) {
    switch (value) {
      case 'Wallpaper':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Wallpapers(),
          ),
        );
        break;
      case 'Settings':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupname),
        centerTitle: true,
        bottom: PreferredSize(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              widget.users.join(', ').substring(0, 30) + '..',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            ),
          ),
          preferredSize: Size.fromHeight(10.0),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Wallpaper'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.isDark
                          ? AssetImage("assets/images/darkbackgroundchat.jpg")
                          : AssetImage("assets/images/backgroundchat.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.grpid)
                        .collection('chats')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      return snapshot.hasData
                          ? Scrollbar(
                              child: ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onLongPress: () {
                                        // msgoperationpopup(
                                        // context,
                                        // index,
                                        // snapshot.data!.docs[index]
                                        // ["message"],
                                        // snapshot);
                                        // setEditchange(false);
                                      },
                                      onTap: () {},
                                      child: MessageTile(
                                        isDark: widget.isDark,
                                        backcolor: chatcolors[widget.users
                                            .indexOf(snapshot.data!.docs[index]
                                                ["sendBy"])],
                                        username: snapshot.data!.docs[index]
                                            ["sendBy"],
                                        message: snapshot.data!.docs[index]
                                            ["message"],
                                        sendByMe: widget.username ==
                                            snapshot.data!.docs[index]
                                                ["sendBy"],
                                        milisec: snapshot.data!.docs[index]
                                            ["time"],
                                      ),
                                    );
                                  }),
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          new Divider(
            height: 1.0,
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _textComposerWidget(),
          ),
        ],
      ),
    );
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: !widget.isDark
          ? IconThemeData(color: Colors.blue)
          : IconThemeData(color: Colors.greenAccent),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: new TextField(
                  enableSuggestions: true,
                  focusNode: chatFocusNode,
                  onChanged: (text) {
                    if (text != '') {
                      setState(() {
                        isEdit = true;
                      });

                      // setEditchange(true);
                    } else {
                      setState(() {
                        isEdit = false;
                      });

                      // setEditchange(false);
                    }
                  },
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                  controller: _chatController,
                ),
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Container(
                    child: isEdit
                        ? null
                        : IconButton(
                            icon: new Icon(Icons.add_a_photo_outlined),
                            onPressed: () => {},
                          ),
                  ),
                  Container(
                    child: IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () =>
                          _handleSubmitted(_chatController.text.trim()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
