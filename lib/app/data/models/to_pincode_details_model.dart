class ToPincodeDetailsModel {
  final String? toCity;
  final String? destcd;
  final String? desTstnm;
  final String? destArea;
  final String? pkpDly;
  final String? transType;
  final String? serviceType;
  final String? pkgsty;
  final String? businesstype;

  ToPincodeDetailsModel({
    this.toCity,
    this.destcd,
    this.desTstnm,
    this.destArea,
    this.pkpDly,
    this.transType,
    this.serviceType,
    this.pkgsty,
    this.businesstype,
  });

  factory ToPincodeDetailsModel.fromJson(Map<String, dynamic> json) {
    return ToPincodeDetailsModel(
      toCity: json['toCity']?.toString(),
      destcd: json['destcd']?.toString(),
      desTstnm: json['desTstnm']?.toString(),
      destArea: json['destArea']?.toString(),
      pkpDly: json['pkp_dly']?.toString(),
      transType: json['trans_type']?.toString(),
      serviceType: json['service_type']?.toString(),
      pkgsty: json['pkgsty']?.toString(),
      businesstype: json['businesstype']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toCity': toCity,
      'destcd': destcd,
      'desTstnm': desTstnm,
      'destArea': destArea,
      'pkp_dly': pkpDly,
      'trans_type': transType,
      'service_type': serviceType,
      'pkgsty': pkgsty,
      'businesstype': businesstype,
    };
  }
}
