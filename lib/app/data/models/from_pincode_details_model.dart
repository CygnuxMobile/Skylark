class FromPincodeDetailsModel {
  final String? fromCity;
  final String? orgncd;
  final String? orgNstnm;
  final String? orgnArea;

  FromPincodeDetailsModel({
    this.fromCity,
    this.orgncd,
    this.orgNstnm,
    this.orgnArea,
  });

  factory FromPincodeDetailsModel.fromJson(Map<String, dynamic> json) {
    return FromPincodeDetailsModel(
      fromCity: json['fromCity']?.toString(),
      orgncd: json['orgncd']?.toString(),
      orgNstnm: json['orgNstnm']?.toString(),
      orgnArea: json['orgnArea']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromCity': fromCity,
      'orgncd': orgncd,
      'orgNstnm': orgNstnm,
      'orgnArea': orgnArea,
    };
  }
}
