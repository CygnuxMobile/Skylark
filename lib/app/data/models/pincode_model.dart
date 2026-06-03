class PincodeModel {
  final String? pincode;

  PincodeModel({this.pincode});

  factory PincodeModel.fromJson(Map<String, dynamic> json) {
    return PincodeModel(
      pincode: json['pincode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pincode': pincode,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PincodeModel &&
          runtimeType == other.runtimeType &&
          pincode == other.pincode;

  @override
  int get hashCode => pincode.hashCode;
}
