class ContractFreightRequestModel {
  String? frompincode;
  String? topincode;
  String? contractId;
  String? flagProceed;
  String? depth;
  String? payBase;
  String? fromCity;
  String? fromstate;
  String? tostate;
  String? toCity;
  String? orgnLoc;
  String? delLoc;
  String? serviceType;
  String? ftlType;
  String? transMode;
  String? chargedWeight;
  String? noOfPkgs;
  String? orderId;
  String? invAmt;

  ContractFreightRequestModel({
    this.frompincode,
    this.topincode,
    this.contractId,
    this.flagProceed,
    this.depth,
    this.payBase,
    this.fromCity,
    this.fromstate,
    this.tostate,
    this.toCity,
    this.orgnLoc,
    this.delLoc,
    this.serviceType,
    this.ftlType,
    this.transMode,
    this.chargedWeight,
    this.noOfPkgs,
    this.orderId,
    this.invAmt,
  });

  Map<String, dynamic> toJson() {
    return {
      "Frompincode": frompincode,
      "topincode": topincode,
      "ContractID": contractId,
      "FlagProceed": flagProceed,
      "Depth": depth,
      "PayBase": payBase,
      "FromCity": fromCity,
      "Fromstate": fromstate,
      "Tostate": tostate,
      "ToCity": toCity,
      "OrgnLoc": orgnLoc,
      "DelLoc": delLoc,
      "ServiceType": serviceType,
      "FTLType": ftlType,
      "TransMode": transMode,
      "ChargedWeight": chargedWeight,
      "NoOfPkgs": noOfPkgs,
      "OrderID": orderId,
      "InvAmt": invAmt,
    };
  }
}
