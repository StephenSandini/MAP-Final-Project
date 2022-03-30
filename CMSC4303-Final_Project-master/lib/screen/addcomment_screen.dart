import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class AddCommentScreen extends StatefulWidget {
  static const routeName = '/addCommentScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddCommentState();
  }
}

class _AddCommentState extends State<AddCommentScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemoOriginal;
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
    onePhotoMemoOriginal ??= args[Constant.ARG_ONE_PHOTOMEMO];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment to ${onePhotoMemoOriginal.title} '),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Add Comment Here',
              ),
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              validator: Comments.validateComment,
              onSaved: con.saveComment,
            ),
            SizedBox(height: 10.0),
            ElevatedButton.icon(
              icon: Icon(
                Icons.add_box,
                color: Colors.white,
                size: 36,
              ),
              onPressed: con.save,
              label: Text('Add Comment', style: Theme.of(context).textTheme.button),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Controller {
  _AddCommentState state;
  _Controller(this.state);
  Comments commentTemp = Comments();

  void save() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      commentTemp.createdBy = state.user.email;
      commentTemp.timestamp = DateTime.now();
      commentTemp.linkId = state.onePhotoMemoOriginal.docId;

      String docId = await FirebaseController.addComment(commentTemp);
      commentTemp.docId = docId;

      Map<String, dynamic> updateInfo = {};
      updateInfo[PhotoMemo.HAS_COMMENTS] = 'true';
      await FirebaseController.updatePhotoMemo(
          state.onePhotoMemoOriginal.docId, updateInfo);

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(context: state.context, title: 'Save Comment Error', content: '$e');
    }
  }

  void saveComment(String value) {
    commentTemp.comment = value;
  }
}
