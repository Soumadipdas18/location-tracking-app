import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class Search extends StatefulWidget {
  const Search({Key? key, required this.username, required this.isDark})
      : super(key: key);
  final String username;
  final bool isDark;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();
  late final String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final User user;
  TextEditingController _searchQuery = new TextEditingController();
  TextEditingController _groupnamecontroller = new TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  List<String> _usernames = <String>[];
  List<String> _selectedusernames = <String>[];
  Map<String, bool> _selectedusernamesbool = <String, bool>{};
  RandomColor _randomColor = RandomColor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser!;
    uid = user.uid;
  }

  @override
  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _usernames.clear();
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery.clear();
    });
  }

  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment = CrossAxisAlignment.start;

    return new InkWell(
      onTap: () => scaffoldKey.currentState!.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Search username'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return new TextField(
        controller: _searchQuery,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search by username',
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.white30),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
        onChanged: (text) {
          int i = 0;
          _usernames.clear();
          FirebaseFirestore.instance
              .collection('users')
              .where('searchname', arrayContains: text)
              .get()
              .then((snapshot) {
            setState(() {
              snapshot.docs.forEach((element) {
                if (element['name'] != widget.username) {
                  if (!_usernames.contains(element['name'])) {
                    _usernames.insert(i, element['name']);
                    if (_selectedusernames.contains(element['name'])) {
                      _selectedusernamesbool.update(
                          element['name'], (value) => true,
                          ifAbsent: () => true);
                    } else {
                      _selectedusernamesbool.update(
                          element['name'], (value) => false,
                          ifAbsent: () => false);
                    }
                  }
                  i++;
                }
              });
            });
          });
        });
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 4.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: _selectedusernames
                              .map((item) => _buildChip(
                                  item,
                                  _randomColor.randomColor(
                                      colorHue: ColorHue.blue),),)
                              .toList()
                              .cast<Widget>()),
                    ),
                  ),
                  Container(
                      child: _selectedusernames.isEmpty
                          ? null
                          : Divider(thickness: 1.0)),
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _usernames.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: Card(
                              color: _selectedusernamesbool[_usernames[index]]!
                                  ? Color(0xff9EA6BA).withOpacity(0.3)
                                  : widget.isDark
                                      ? Colors.black12
                                      : Colors.white,
                              child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedusernamesbool[
                                          _usernames[index]]!) {
                                        _selectedusernames.insert(
                                            _selectedusernames.length,
                                            _usernames[index]);
                                        _selectedusernamesbool.update(
                                            _usernames[index], (value) => true,
                                            ifAbsent: () => true);
                                      } else {
                                        _deleteselected(_usernames[index]);
                                      }
                                    });
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Text(
                                        _usernames[index][0].toUpperCase()),
                                  ),
                                  title: Text(_usernames[index]),
                                  trailing:
                                      _selectedusernamesbool[_usernames[index]]!
                                          ? Icon(Icons.check)
                                          : null)));
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: creategroup,
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
      ),
      onDeleted: () => _deleteselected(label),
      backgroundColor: color,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }

  void _deleteselected(String label) {
    setState(
      () {
        _selectedusernamesbool.update(label, (value) => false,
            ifAbsent: () => false);
        _selectedusernames.removeAt(_selectedusernames.indexOf(label));
      },
    );
  }

  void creategroup() async {
    if (_selectedusernames.isEmpty) {
      coolalertfailure('No users selected');
    } else {
      setState(() {
        _isLoading = true;
      });
      await GroupnameWidget(context);
    }
  }

  Future<void> createcollectiongroup() async {
    _selectedusernames.insert(_selectedusernames.length, widget.username);
    Map<String, dynamic> mapgroups = {
      'groupname': _groupnamecontroller.text,
      'owner': widget.username,
      'users': _selectedusernames
    };
    try {
      await FirebaseFirestore.instance.collection('groups').add(mapgroups);

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      setState(() {
        _selectedusernames.clear();
        _selectedusernamesbool.clear();
      });
      coolalertsuccess('Group created');
    } catch (e) {
      coolalertfailure('Failed to create group ${e}');
    }
  }

  Future<dynamic> GroupnameWidget(BuildContext context) async {
    // alter the app state to show a dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: AlertDialog(
            title: Text('Enter group name'),
            content: TextField(
              controller: _groupnamecontroller,
              decoration: InputDecoration(
                hintText: 'Group name',
              ),
            ),
            actions: <Widget>[
              // add button
              ElevatedButton(
                child: Text('CREATE'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (_groupnamecontroller.text.length != 0) {
                    await createcollectiongroup();
                  }
                  setState(
                    () {
                      _isLoading = false;
                    },
                  );
                },
              ),
              // Cancel button
              ElevatedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(
                    () {
                      _isLoading = false;
                    },
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _groupnamecontroller.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    setState(() {
      setState(
        () {
          _isLoading = false;
        },
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _groupnamecontroller.clear();
    });
    return true;
  }

  coolalertsuccess(String text) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      title: 'Congratulations',
      text: text,
      loopAnimation: false,
    );
  }

  coolalertfailure(String text) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: 'Oops...',
      text: text,
      loopAnimation: false,
    );
  }
}
