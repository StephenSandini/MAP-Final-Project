class PhotoMemo {
  String docId; //Firestore auto generated ID
  String createdBy;
  String memo;
  String title;
  String favorite;
  String photoFilename; //Stored @ Storage
  String photoURL;
  String hascComments;
  DateTime timestamp;
  List<dynamic> sharedWith; //List of email
  List<dynamic> imageLabels;
  //Image identified by ML //Dynamic is better for/easier for firestore

//Key for firestore documents
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';
  static const FAVORITE = 'favorite';
  static const HAS_COMMENTS = 'hasComments';

  PhotoMemo(
      {this.docId,
      this.createdBy,
      this.memo,
      this.hascComments,
      this.photoFilename,
      this.photoURL,
      this.timestamp,
      this.title,
      this.sharedWith,
      this.favorite,
      this.imageLabels}) {
    this.sharedWith ??= []; //If it doesn't exist, it will begin empty.
    this.imageLabels ??= [];
  }
//DEEP COPY BEING MADE OF PHOTOMEMO
  PhotoMemo.clone(PhotoMemo p) {
    //THESE ARE SINGLE VALUES & STRINGS
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.hascComments = p.hascComments;
    this.favorite = p.favorite;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.title = p.title;
    this.timestamp = p.timestamp;
    //THIS COPIES ELEMENTS FROM THE LIST 1 BY 1
    this.sharedWith = [];
    this.sharedWith.addAll(p.sharedWith);
    this.imageLabels = [];
    this.imageLabels.addAll(p.imageLabels);
  }
// A = B ==> a.assign(b) THIS IS SAVING TO ORIGINAL
  void assign(PhotoMemo p) {
    this.docId = p.docId;
    this.favorite = p.favorite;
    this.createdBy = p.createdBy;
    this.hascComments = p.hascComments;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.title = p.title;
    this.timestamp = p.timestamp;
    this.sharedWith.clear();
    this.sharedWith.addAll(p.sharedWith);
    this.imageLabels.clear();
    this.imageLabels.addAll(p.imageLabels);
  }

//SERIALIZE
//From Dart OBJ to Firestore Document Compatible type
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      TIMESTAMP: this.timestamp,
      SHARED_WITH: this.sharedWith,
      IMAGE_LABELS: this.imageLabels,
      FAVORITE: this.favorite,
      HAS_COMMENTS: this.hascComments,
    };
  }

  //DESERIALIZE
  static PhotoMemo deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoMemo(
      docId: docId,
      createdBy: doc[CREATED_BY],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFilename: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      sharedWith: doc[SHARED_WITH],
      imageLabels: doc[IMAGE_LABELS],
      favorite: doc[FAVORITE],
      hascComments: doc[HAS_COMMENTS],
      //Checking for a time stamp and then converting it from integer to milliseconds.
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateTitle(String value) {
    if (value == null || value.length < 3)
      return 'too short';
    else
      return null;
  }

  static String validateMemo(String value) {
    if (value == null || value.length < 5)
      return 'too short';
    else
      return null;
  }

  static String validateSharedWith(String value) {
    if (value == null || value.trim().length == 0) return null;

    List<String> emailList = value
        .split(RegExp('(,| )+'))
        .map((e) => e.trim())
        .toList(); //One or more of these to split each email
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma(,) or space separated email list';
    }
    return null; //no errors from for loop
  }
}
