class Comments {
  String docId; //Fire Store Generated
  String linkId; //Link to PhotoMemo
  String comment; //Comments on PhotoMemo
  String createdBy; //Who Created
  DateTime timestamp; //Time Created

  //Key for Firestore documents
  static const LINK_ID = 'linkId';
  static const COMMENT = 'comment';
  static const CREATED_BY = 'createdBY';
  static const TIMESTAMP = 'timestamp';

  Comments({
    this.docId,
    this.linkId,
    this.comment,
    this.createdBy,
    this.timestamp,
  });

  //Deep Copy
  Comments.clone(Comments c) {
    this.docId = c.docId;
    this.linkId = c.linkId;
    this.comment = c.comment;
    this.createdBy = c.createdBy;
    this.timestamp = c.timestamp;
  }
  //Saving to Original
  void assign(Comments c) {
    this.docId = c.docId;
    this.linkId = c.linkId;
    this.comment = c.comment;
    this.createdBy = c.createdBy;
    this.timestamp = c.timestamp;
  }

  //Serialize
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      LINK_ID: this.linkId,
      COMMENT: this.comment,
      CREATED_BY: this.createdBy,
      TIMESTAMP: this.timestamp,
    };
  }

  //DeSerialize
  static Comments deserialize(Map<String, dynamic> doc, String docId) {
    return Comments(
      docId: docId,
      linkId: doc[LINK_ID],
      comment: doc[COMMENT],
      createdBy: doc[CREATED_BY],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateComment(String value) {
    if (value == null || value.length < 3)
      return 'Too short! Min of 3 characters.';
    else
      return null;
  }
}
