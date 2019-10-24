/*
int userType;
final items = <MultiSelectDialogItem<int>>[];

final formKey = new GlobalKey<FormState>();
@override
void initState() {
  getCurrentUser();
  super.initState();
}

void UserStream() async {
  await for (var snapshot
  in authService.firestore.collection('userinfo').snapshots()) {
    int i = 1;
    for (var userId in snapshot.documents) {
      print('aaa : ' + userId.data['id']);
      print(i);
      if (userId.data['id'] != null)
        items.add(MultiSelectDialogItem(i, userId.data['id']));
      ++i;
    }
  }
}

void _showMultiSelect(BuildContext context) async {
  final selectedValues = await showDialog<Set<int>>(
    context: context,
    builder: (BuildContext context) {
      return MultiSelectDialog(
        items: items,
        initialSelectedValues: [1, 2].toList(),
      );
    },
  );
  print(selectedValues);
}

void getCurrentUser() async {
  try {
    final user = await authService.auth.currentUser();
    if (user != null) {
      authService.user = user;
    }
  } catch (e) {
    print(e.message);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true,
    floatingActionButton: Visibility(
      visible: isUser,
      child: FloatingActionButton.extended(
        onPressed: () {
          UserStream();
          _showMultiSelect(context);
        },
        icon: Icon(Icons.add),
        label: Text("Add Group"),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    appBar: AppBar(
      leading: null,
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              authService.auth.signOut();
              Navigator.pop(context);
            }),
      ],
      title: Text('VACATION'),
      backgroundColor: Colors.lightBlueAccent,
    ),
    body: SafeArea(
      child: buildStreamBuilder(),
    ),
  );
}

StreamBuilder<DocumentSnapshot> buildStreamBuilder() {
  return StreamBuilder<DocumentSnapshot>(
    stream: Firestore.instance
        .collection('userinfo')
        .document(authService.user.email)
        .snapshots(),
    builder:
        (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      return checkRole(snapshot.data);
    },
  );
}

Widget checkRole(DocumentSnapshot snapshot) {
  if (snapshot.data['type'] == user.soldier.index)
    return soldierPage(snapshot);
  else
    return adminPage(snapshot);
}

Widget soldierPage(DocumentSnapshot snapshot) {
  return Container(
    margin: EdgeInsets.only(bottom: 60),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: ReusableBox(),
        )
      ],
    ),
  );
}

SafeArea adminPage(DocumentSnapshot snapshot) {
  isUser = false;
  return SafeArea(
    // Stream Soldier Group
    child: Text("admin"),
  );
}

/*
 bottomNavigationBar: BottomAppBar(
          //clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.blue,
          shape: CircularNotchedRectangle(),
          child: Material(
            child: SizedBox(
              width: double.infinity,
              height: 60.0,
            ),
            color: Theme.of(context).primaryColor,
          ),
        ),
 */

/*
  void getUserType() {
    Firestore.instance
        .collection('userinfo')
        .document(authService.user.email)
        .get()
        .then((DocumentSnapshot snapshot) {
      userType = snapshot.data['type'];
    });
  }
*/
*/
