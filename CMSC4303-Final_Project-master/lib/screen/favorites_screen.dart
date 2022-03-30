////////////////////////////////////////////////////////////////////////////////
///ADDED SPRINT 1
////////////////////////////////////////////////////////////////////////////////
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/sharedwithdetails_screen.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = '/favoritesScreen';
  @override
  State<StatefulWidget> createState() {
    return _FavoritesState();
  }
}

class _FavoritesState extends State<FavoritesScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite PhotoMemos'),
      ),
      body: photoMemoList.length == 0
          ? Text(
              'Currently You Do Not Have ANy Favorited PhotoMemos',
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
                                    tooltip: 'Remove from Your Favorites',
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
  _FavoritesState state;
  _Controller(this.state);

  int favoriteCheckIndex;
  Map<String, dynamic> updateInfo = {};
  List<PhotoMemo> favoritesList;

  favorite(int index) async {
    if (state.photoMemoList[index].favorite == 'true') {
      state.photoMemoList[index].favorite = 'false';
      updateInfo[PhotoMemo.FAVORITE] = state.photoMemoList[index].favorite;
      FirebaseController.updateFavorite(state.photoMemoList[index].docId, updateInfo);
      state.render(() => state.photoMemoList[index].favorite = 'false');
      favoritesList =
          await FirebaseController.getMyFavoritePhotoMemos(email: state.user.email);
    } else if (state.photoMemoList[index].favorite == 'false' ||
        state.photoMemoList[index].favorite == null) {
      state.photoMemoList[index].favorite = 'true';
      updateInfo[PhotoMemo.FAVORITE] = state.photoMemoList[index].favorite;
      FirebaseController.updateFavorite(state.photoMemoList[index].docId, updateInfo);
      state.render(() => favoriteCheckIndex = index);
      favoritesList =
          await FirebaseController.getMyFavoritePhotoMemos(email: state.user.email);
    }

    state.render(() {
      state.photoMemoList = favoritesList;
    });
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
