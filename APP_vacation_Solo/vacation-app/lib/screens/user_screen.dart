import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flash_chat/componenets/RoundedButton.dart';
import 'package:flash_chat/componenets/User.dart';
import 'package:flash_chat/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/componenets/multiselect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';

//String userName;
List<dynamic> list = [];
final usrRef = FirebaseDatabase.instance.reference().child('userinfo');
final groupsRef = FirebaseDatabase.instance.reference().child('groups');

class UserScreen extends StatefulWidget {
  static const String id = 'UserScreen';
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<Widget> groupMember = [];
  final _auth = FirebaseAuth.instance;

  final _firestore = Firestore.instance;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    callOnce = true;
    list = [];
    super.initState();
    getCurrentUser();
  }

  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

    _firestore
        .collection('location')
        .document(loggedInUser.email)
        .setData({'lng': position.longitude, 'lat': position.latitude});
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Vacation'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('userinfo')
              .document(loggedInUser.email)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return LinearProgressIndicator();
              default:
                return (snapshot.data.data['type'] == 1)
                    ? Form(
                        // User UI
                        key: _formKey,
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('userinfo')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final userID = snapshot.data.documents;
                                    List<String> idString = [];
                                    int i = 0;
                                    if (callOnce) {
                                      for (var id in userID) {
                                        idString.add(id.data['name']);
                                        ++i;
                                      }
                                      for (int index = 0; index < i; ++index)
                                        list.add(
                                          {
                                            "display":
                                                idString.elementAt(index),
                                            "value": index
                                          },
                                        );
                                      print(list);
                                    }
                                    callOnce = false;
                                    return StreamBuilder<DocumentSnapshot>(
                                        stream: _firestore
                                            .collection('group')
                                            .document(loggedInUser.email)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          groupMember.clear();
                                          if (snapshot.hasData) {
                                            final groupID =
                                                snapshot.data['member'];
                                            for (var id in groupID) {
                                              groupMember
                                                  .add(CustomListTile(txt: id));
                                            }
                                            return Column(
                                              children: <Widget>[
                                                MultiSelect(
                                                  autovalidate: false,
                                                  titleText: loggedInUser.email,
                                                  errorText:
                                                      'Please select one or more option(s)',
                                                  dataSource: list,
                                                  textField: 'display',
                                                  valueField: 'value',
                                                  filterable: true,
                                                  required: true,
                                                  value: list,
                                                ),
                                                Column(children: groupMember),
                                                FloatingActionButton.extended(
                                                  onPressed: () {
                                                    Toast.show(
                                                        "위치 전송 완료", context);
                                                    getLocation();
                                                  },
                                                  label: Text("위치 보내기"),
                                                  icon: Icon(Icons.location_on),
                                                ),
                                              ],
                                            );
                                          }
                                          return LinearProgressIndicator();
                                        });
                                  }
                                  return LinearProgressIndicator();
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : buildStreamBuilder();
            }
          }),
    );
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilder() {
    Set<Marker> _Marker;
    GoogleMapController mapController;

    final LatLng _center = const LatLng(45.521563, -122.677433);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    return StreamBuilder(
        stream: _firestore.collection('group').snapshots(),
        builder: (context, snapshot) {
          groupMember.clear();
          if (snapshot.hasData) {
            final groupID = snapshot.data.documents;
            for (var id in groupID) {
              if (id.data['member'] != {})
                groupMember.add(RoundedButton(
                  text: "리더 :" +
                      id.data['leader'] +
                      "  " +
                      id.data['member'].toString(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StreamBuilder<DocumentSnapshot>(
                            stream: _firestore
                                .collection('location')
                                .document(id.data['leader'].toString())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData)
                                return MaterialApp(
                                  debugShowCheckedModeBanner: false,
                                  home: Scaffold(
                                    appBar: AppBar(
                                      title: Text('Location'),
                                      backgroundColor: Colors.green[700],
                                    ),
                                    body: GoogleMap(
                                      onMapCreated: _onMapCreated,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(snapshot.data['lat'],
                                            snapshot.data['lng']),
                                        zoom: 11.0,
                                      ),
                                    ),
                                  ),
                                );
                            }),
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                ));
            }
            return Center(child: Column(children: groupMember));
          }
          return LinearProgressIndicator();
        });
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({@required this.txt});
  final String txt;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      child: ListTile(
        leading: Icon(Icons.account_circle),
        title: Text(txt),
      ),
    );
  }
}
