import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/addcomment_screen.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/myview/myimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';
  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemoOriginal;
  PhotoMemo onePhotoMemoTemp;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;
  List<Comments> commentsList;

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
    onePhotoMemoOriginal ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoTemp ??= PhotoMemo.clone(onePhotoMemoOriginal);
    commentsList ??= args[Constant.ARG_COMMENTS_LIST];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(icon: Icon(Icons.check), onPressed: con.update)
              : IconButton(icon: Icon(Icons.edit), onPressed: con.edit),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    //This is Image from photofile object, otherwise it will camera or gallery
                    child: con.photoFile == null
                        ? MyImage.network(
                            url: onePhotoMemoTemp.photoURL,
                            context: context,
                          )
                        : Image.file(
                            con.photoFile,
                            fit: BoxFit.fill,
                          ),
                  ),
                  editMode
                      //VIdeo 3-2 Video 11 shows how to add buttons/POPUP Buttons to Images(GOOD REFERENCE FOR PROJECT)
                      ? Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            color: Colors.amber,
                            child: PopupMenuButton<String>(
                              onSelected: con.getPhoto,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: Constant.SRC_CAMERA,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_camera),
                                      Text(Constant.SRC_CAMERA),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: Constant.SRC_GALLERY,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library),
                                      Text(Constant.SRC_GALLERY),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(height: 1.0)
                  : Text(
                      progressMessage,
                      style: Theme.of(context).textTheme.headline6,
                    ),
              //TITLE
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                ),
                initialValue: onePhotoMemoTemp.title,
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              //MEMOS
              TextFormField(
                enabled: editMode,
                decoration: InputDecoration(
                  hintText: 'Enter memo',
                ),
                initialValue: onePhotoMemoTemp.memo,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              //SHARED WITH
              TextFormField(
                enabled: editMode,
                decoration: InputDecoration(
                  hintText: 'Enter Shared With (email list)',
                ),
                initialValue: onePhotoMemoTemp.sharedWith.join(','), //THIS IS AN ARRAY
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              SizedBox(
                height: 5.0,
              ),
              //IMAGE LABELS GENERATED BY ML
              Constant.DEV
                  ? Text(
                      'Image Labels generated by ML',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : SizedBox(
                      height: 1.0,
                    ),
              Constant.DEV
                  ? Text(onePhotoMemoTemp.imageLabels.join(' | '))
                  : SizedBox(
                      height: 1.0,
                    ),
              SizedBox(
                height: 2.0,
              ),
              commentsList.length == 0
                  ? SizedBox(
                      height: 5.0,
                    )
                  //: Text('DOES IT WORK?'),
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: commentsList.length,
                      itemBuilder: (context, index) => Card(
                        child: Column(children: [
                          ListTile(
                            title: Text('${commentsList[index].comment}',
                                textAlign: TextAlign.center),
                            subtitle: Column(
                              children: [
                                SizedBox(height: 5),
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    commentsList[index].createdBy == user.email
                                        ? Container(child: Icon(Icons.coronavirus))
                                        : SizedBox(
                                            height: 2,
                                          ),
                                    Container(
                                      child: Text(
                                          'Created By: ${commentsList[index].createdBy}'),
                                    ),
                                    commentsList[index].createdBy == user.email
                                        ? Expanded(
                                            child: Container(
                                              alignment: Alignment(1.0, 0.0),
                                              child: ElevatedButton.icon(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all<Color>(
                                                            Colors.red[900])),
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    con.delete(commentsList[index].docId),
                                                label: Text(
                                                  'Delete',
                                                  style:
                                                      Theme.of(context).textTheme.button,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 20.0,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.add_comment,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: con.addComment,
                label: Text('Add Comment', style: Theme.of(context).textTheme.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  _Controller(this.state);
  File photoFile; //camera or gallery

  void update() async {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();
    // state.render(() => state.editMode = false);

    try {
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo = {}; // COLLECT CHANGES IN THIS VARIABLE
      if (photoFile != null) {
        Map photoInfo = await FirebaseController.uploadPhotoFile(
          photo: photoFile,
          filename: state.onePhotoMemoTemp.photoFilename,
          uid: state.user.uid,
          listener: (double message) {
            state.render(() {
              if (message == null)
                state.progressMessage = null;
              else {
                message *= 100;
                state.progressMessage = 'Uploading: ' + message.toStringAsFixed(1) + '%';
              }
            });
          },
        );
        state.onePhotoMemoTemp.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
        state.render(() => state.progressMessage = 'ML image labeler started');
        List<dynamic> labels =
            await FirebaseController.getImageLabels(photoFile: photoFile);
        state.onePhotoMemoTemp.imageLabels = labels;
        //THESE TWO ARE UPDATED WITH CHANGING OF LABELS
        updateInfo[PhotoMemo.PHOTO_URL] = photoInfo[Constant.ARG_DOWNLOADURL];
        updateInfo[PhotoMemo.IMAGE_LABELS] = labels;
      }
      //determine updated fields
      //TITLE CHANGED
      if (state.onePhotoMemoOriginal.title != state.onePhotoMemoTemp.title)
        updateInfo[PhotoMemo.TITLE] = state.onePhotoMemoTemp.title;
      //MEMO CHANGED
      if (state.onePhotoMemoOriginal.memo != state.onePhotoMemoTemp.memo)
        updateInfo[PhotoMemo.MEMO] = state.onePhotoMemoTemp.memo;
      //SHARED WITH CHANGED
      if (!listEquals(
          state.onePhotoMemoOriginal.sharedWith, state.onePhotoMemoTemp.sharedWith))
        updateInfo[PhotoMemo.SHARED_WITH] = state.onePhotoMemoTemp.sharedWith;
      //UPDATE TIME STAMP FOR ALL CHANGES
      updateInfo[PhotoMemo.TIMESTAMP] = DateTime.now();
      await FirebaseController.updatePhotoMemo(state.onePhotoMemoTemp.docId, updateInfo);

      state.onePhotoMemoOriginal.assign(state.onePhotoMemoTemp);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context, title: 'Update PhotoMemo Error', content: '$e');
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void getPhoto(String src) async {
    try {
      PickedFile _photoFile;
      if (src == Constant.SRC_CAMERA) {
        _photoFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _photoFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      if (_photoFile == null) return; //SELECTION CANCELLED
      state.render(() => photoFile = File(_photoFile.path));
    } catch (e) {
      MyDialog.info(context: state.context, title: 'getPhoto error', content: '$e');
    }
  }

  void saveTitle(String value) {
    state.onePhotoMemoTemp.title = value;
  }

  void saveMemo(String value) {
    state.onePhotoMemoTemp.memo = value;
  }

  void saveSharedWith(String value) {
    if (value.trim().length != 0) {
      state.onePhotoMemoTemp.sharedWith =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }

  void addComment() async {
    try {
      await Navigator.pushNamed(state.context, AddCommentScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.onePhotoMemoOriginal,
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Going to Add Comment Screen Error',
        content: '$e',
      );
    }
    List<Comments> reloadCommentsList = await FirebaseController.getCommentsList(
        linkId: state.onePhotoMemoOriginal.docId);
    state.render(() {
      state.commentsList = reloadCommentsList;
    });
  }

  void delete(String docId) async {
    try {
      print(docId);
      print('Button clicked');
      await FirebaseController.deleteComment(docId: docId);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete Comment Error',
        content: '$e',
      );
    }

    List<Comments> reloadCommentsList = await FirebaseController.getCommentsList(
        linkId: state.onePhotoMemoOriginal.docId);
    Map<String, dynamic> updateInfo = {};
    if (reloadCommentsList.isEmpty) {
      updateInfo[PhotoMemo.HAS_COMMENTS] = 'false';
      await FirebaseController.updatePhotoMemo(
          state.onePhotoMemoOriginal.docId, updateInfo);
      reloadCommentsList = await FirebaseController.getCommentsList(
          linkId: state.onePhotoMemoOriginal.docId);
    }
    state.render(() {
      state.commentsList = reloadCommentsList;
    });
    print('Button Pressed');
  }
}
