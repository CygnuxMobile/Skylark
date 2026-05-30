class CustomerModel {
  final String? custCode;
  final String? custName;

  CustomerModel({this.custCode, this.custName});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      custCode: json['custcd']?.toString() ?? 
                json['custcode']?.toString() ?? 
                json['custCode']?.toString(),
      custName: json['custnm']?.toString() ?? 
                json['custName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custCode': custCode,
      'custName': custName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel &&
          runtimeType == other.runtimeType &&
          custCode == other.custCode &&
          custName == other.custName;

  @override
  int get hashCode => custCode.hashCode ^ custName.hashCode;
}
