import 'package:cloud_firestore/cloud_firestore.dart';

class CallRecordDetails {
  final DocumentReference reference;

  String _callerId;
  String _callerName;
  String _receiverId;
  int _callTimestamp;
  String _callStatus;
  String _callDuration;
  String _channelName;
  String _callType; // Audio/Video

  CallRecordDetails(
      this._callerId,
      this._callerName,
      this._receiverId,
      this._callTimestamp,
      this._callStatus,
      this._callDuration,
      this._channelName,
      this._callType,
      [this.reference]);

  String get callerId => _callerId;

  String get callerName => _callerName;

  String get receiverId => _receiverId;

  int get callTimestamp => _callTimestamp;

  String get callStatus => _callStatus;

  String get callDuration => _callDuration;

  String get channelName => _channelName;

  String get callType => _callType;

  set callerId(String callerId) {
    this._callerId = callerId;
  }

  set callerName(String callerName) {
    this._callerName = callerName;
  }

  set receiverId(String receiverId) {
    this._receiverId = receiverId;
  }

  set callTimestamp(int callTimestamp) {
    this._callTimestamp = callTimestamp;
  }

  set callStatus(String callStatus) {
    this._callStatus = callStatus;
  }

  set callDuration(String callDuration) {
    this._callDuration = callDuration;
  }

  set channelName(String channelName) {
    this._channelName = channelName;
  }

  set callType(String callType) {
    this._callType = callType;
  }

  // Convert CallRecordDetails object into a MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['callerId'] = _callerId;
    map['callerName'] = _callerName;
    map['receiverId'] = _receiverId;
    map['callTimestamp'] = _callTimestamp;
    map['callStatus'] = _callStatus;
    map['callDuration'] = _callDuration;
    map['channelName'] = _channelName;
    map['callType'] = _callType;
    return map;
  }

  // Extract CallRecordDetails object from MAP object
  CallRecordDetails.fromMapObject(Map<String, dynamic> map, {this.reference}) {
    _callerId = map['callerId'];
    _callerName = map['callerName'];
    _receiverId = map['receiverId'];
    _callTimestamp = map['callTimestamp'];
    _callStatus = map['callStatus'];
    _callDuration = map['callDuration'];
    _channelName = map['channelName'];
    _callType = map['callType'];
  }

  CallRecordDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMapObject(snapshot.data, reference: snapshot.reference);
}
