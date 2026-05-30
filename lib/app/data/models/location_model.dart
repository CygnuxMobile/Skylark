class LocationModel {
  final String? locCode;
  final String? locName;

  LocationModel({this.locCode, this.locName});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locCode: json['locCode']?.toString(),
      locName: json['locName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locCode': locCode,
      'locName': locName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          locCode == other.locCode &&
          locName == other.locName;

  @override
  int get hashCode => locCode.hashCode ^ locName.hashCode;
}
