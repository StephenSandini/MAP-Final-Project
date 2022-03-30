import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/sharedwithdetails_screen.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  List<PhotoMemo> photoMemoListTemp;

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
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    photoMemoListTemp ??= photoMemoList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With Me'),
      ),
      //SHOWS HOW MANY PHOTOS ARE SHARED WITH THIS USER THAT IS LOGGED IN body: Text('Length: ${photoMemoList.length}'),
      body: photoMemoList.length == 0
          ? Text(
              'No PhotoMemos shared with me',
              style: Theme.of(context).textTheme.headline5,
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => InkWell(
                child: Card(
                  elevation: 7.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: MyImage.network(
                            url: photoMemoList[index].photoURL,
                            context: context,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Title: ${photoMemoList[index].title}',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          (photoMemoList[index].favorite == 'true')
                              //&& con.favoriteCheckIndex != null)
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.yellow,
                                    ),
                                    tooltip: 'Add to Your Favorites',
                                    onPressed: () => con.favorite(index),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: IconButton(
                                    icon: Icon(Icons.favorite_border_outlined),
                                    tooltip: 'Add to Your Favorites',
                                    onPressed: () => con.favorite(index),
                                  ),
                                ),
                          photoMemoList[index].hascComments != 'false'
                              ? Container(
                                  child: Icon(
                                  Icons.person_pin_rounded,
                                ))
                              : SizedBox(
                                  height: 1,
                                ),
                        ],
                      ),
                      Text(
                        'Memo: ${photoMemoList[index].memo}',
                      ),
                      Text(
                        'Created By: ${photoMemoList[index].createdBy}',
                      ),
                      Text(
                        'Updated At: ${photoMemoList[index].timestamp}',
                      ),
                      Text(
                        'SharedWith: ${photoMemoList[index].sharedWith}',
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  con.onTap(index);
                },
              ),
            ),
    );
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);

  int favoriteCheckIndex;
  Map<String, dynamic> updateInfo = {};

  favorite(int index) {
    if (state.photoMemoList[index].favorite == 'true') {
      state.photoMemoList[index].favorite = 'false';
      updateInfo[PhotoMemo.FAVORITE] = state.photoMemoList[index].favorite;
      FirebaseController.updateFavorite(state.photoMemoList[index].docId, updateInfo);
      state.render(() => state.photoMemoList[index].favorite = 'false');
      print(index);
      print(state.photoMemoList[index].favorite);

      // print(favoriteCheckIndex);
    } else if (state.photoMemoList[index].favorite == 'false' ||
        state.photoMemoList[index].favorite == null) {
      state.photoMemoList[index].favorite = 'true';
      updateInfo[PhotoMemo.FAVORITE] = state.photoMemoList[index].favorite;
      FirebaseController.updateFavorite(state.photoMemoList[index].docId, updateInfo);
      state.render(() => favoriteCheckIndex = index);
      // print(favoriteCheckIndex);
      print(index);
      print(state.photoMemoList[index].favorite);
    }
  }

  void onTap(int index) async {
    List<Comments> commentList = await FirebaseController.getCommentsList(
        linkId: state.photoMemoList[index].docId);
    print(state.photoMemoList[index]);

    await Navigator.pushNamed(
      state.context,
      SharedWithDetailsScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
        Constant.ARG_COMMENTS_LIST: commentList,
      },
    );
    state.render(() {});
  }
}
