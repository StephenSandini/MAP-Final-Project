import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/addphotomemo_screen.dart';
import 'package:lesson3/screen/favorites_screen.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/detailedview_screen.dart';
import 'package:lesson3/screen/sharedwith_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST]; //If PhotoMemo is Null
    return WillPopScope(
      onWillPop: () => Future.value(false), //Android System Back button disabled
      child: Scaffold(
        appBar: AppBar(
          // title: Text('User Home'),
          actions: [
            con.delIndex != null
                ? IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: con.cancelDelete,
                  )
                : Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKeyString,
                        ),
                      ),
                    ),
                  ),
            con.delIndex != null
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: con.delete,
                  )
                : IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    onPressed: con.search,
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                //Set up our own user display settings COULD BE UTILIZED IN FINAL PROJECT
                currentAccountPicture: Icon(
                  Icons.person,
                  size: 100.0,
                ),
                accountName: Text(user.displayName ?? 'N/A'),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Shared With Me'),
                onTap: con.sharedWithMe,
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorites'),
                onTap: con.favorites,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: photoMemoList.length == 0
            ? Text(
                'No PhotoMemos Found!',
                style: Theme.of(context).textTheme.headline5,
              )
            //PHOTOMEMOS ARE RENDERED USED LIST TILE
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  color: con.delIndex != null && con.delIndex == index
                      ? Theme.of(context).highlightColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    leading: MyImage.network(
                      url: photoMemoList[index].photoURL,
                      context: context,
                    ),
                    //USING A TRAILING TO ADD SOME NOTIFICATION WITH LIKE NEW COMMENTS
                    //trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Displaying Photo Memos that are of 20 characters or only 20 characters from longer memos
                        Text(photoMemoList[index].memo.length >= 15
                            ? photoMemoList[index].memo.substring(0, 15) + '...'
                            : photoMemoList[index].memo),
                        Text('Created By: ${photoMemoList[index].createdBy}'),
                        Text('Shared With By: ${photoMemoList[index].sharedWith}'),
                        Text('Updated At: ${photoMemoList[index].timestamp}'),

                        // photoMemoList[index].hascComments != 'false'
                        //     ? Container(
                        //         alignment: AlignmentDirectional.centerEnd,
                        //         child: Icon(
                        //           Icons.person_pin_rounded,
                        //         ))
                        //     : SizedBox(
                        //         height: 1,
                        //       ),
                      ],
                    ),
                    dense: true,
                    trailing: Column(
                      children: [
                        photoMemoList[index].hascComments != 'false'
                            ? Container(
                                child: Icon(
                                Icons.person_pin_rounded,
                              ))
                            : SizedBox(
                                height: 1,
                              ),
                        photoMemoList[index].favorite == 'true'
                            ? Container(child: Icon(Icons.favorite, color: Colors.yellow))
                            : SizedBox(
                                height: 1,
                              ),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state); //Constructor
  int delIndex;
  String keyString;
  var toSet;

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList,
      },
    );
    List<PhotoMemo> p = state.photoMemoList;
    p = await FirebaseController.getPhotoMemoList(email: state.user.email);
    state.render(() {
      state.photoMemoList = p;
    });
    // state.render(() {}); //Rerender the screen
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      //do nothing
    }
    Navigator.of(state.context).pop(); //Close drawer
    Navigator.of(state.context).pop(); //SignIn Screen
  }

  void onTap(int index) async {
    if (delIndex != null) return;
    List<Comments> commentsList = await FirebaseController.getCommentsList(
        linkId: state.photoMemoList[index].docId);

    await Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
        Constant.ARG_COMMENTS_LIST: commentsList,
      },
    );
    state.render(() {});
  }

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList = await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
      });
      Navigator.pop(state.context); //Closes the Drawer
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'get Shared PhotoMemo Error',
        content: '$e',
      );
    }
  }

  void onLongPress(int index) {
    if (delIndex != null) return;
    state.render(() => delIndex = index);
  }

  void cancelDelete() {
    state.render(() => delIndex = null);
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[delIndex];
      await FirebaseController.deletePhotoMemo(p);
      state.render(() {
        state.photoMemoList.removeAt(delIndex);
        delIndex = null;
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete PhotoMemo Error',
        content: '$e',
      );
    }
  }

  void saveSearchKeyString(String value) {
    keyString = value;
  }

  void search() async {
    state.formKey.currentState.save();
    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];

    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }
    try {
      List<PhotoMemo> results;
      if (searchKeys.isNotEmpty) {
        results = await FirebaseController.searchImage(
          createdBy: state.user.email,
          searchLabels: searchKeys,
        );
      } else {
        results = await FirebaseController.getPhotoMemoList(email: state.user.email);
      }
      state.render(() => state.photoMemoList = results);
    } catch (e) {
      MyDialog.info(context: state.context, title: 'Search Error', content: '$e');
    }
  }

  void favorites() async {
    List<PhotoMemo> favoritesList =
        await FirebaseController.getMyFavoritePhotoMemos(email: state.user.email);
    // print(state.user.email);
    // print(favoritesList);
    try {
      await Navigator.pushNamed(state.context, FavoritesScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: favoritesList,
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Going to Favorites Error',
        content: '$e',
      );
    }
  }

  revisedList(photoMemoList) {
    final emails = photoMemoList.map((e) => e.sharedWith).toSet();
    photoMemoList.retainWhere((e) => emails.remove(e.sharedWith));
    return photoMemoList;
  }

  void refresh() async {
    List<PhotoMemo> p = state.photoMemoList;
    p = await FirebaseController.getPhotoMemoList(email: state.user.email);
    state.render(() {
      state.photoMemoList = p;
    });
  }
}
