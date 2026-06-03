class CustomerModel {
  final String? custCode;
  final String? custName;
  final String? contractId;
  final String? volYn;
  final String? transType;

  CustomerModel({
    this.custCode,
    this.custName,
    this.contractId,
    this.volYn,
    this.transType,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      custCode: json['custcd']?.toString() ?? 
                json['custcode']?.toString() ?? 
                json['custCode']?.toString(),
      custName: json['custnm']?.toString() ?? 
                json['custName']?.toString(),
      contractId: json['contractId']?.toString(),
      volYn: json['vol_yn']?.toString(),
      transType: json['trans_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custCode': custCode,
      'custName': custName,
      'contractId': contractId,
      'vol_yn': volYn,
      'trans_type': transType,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel &&
          runtimeType == other.runtimeType &&
          custCode == other.custCode &&
          custName == other.custName &&
          contractId == other.contractId &&
          volYn == other.volYn &&
          transType == other.transType;

  @override
  int get hashCode => 
      custCode.hashCode ^ 
      custName.hashCode ^ 
      contractId.hashCode ^ 
      volYn.hashCode ^ 
      transType.hashCode;
}
