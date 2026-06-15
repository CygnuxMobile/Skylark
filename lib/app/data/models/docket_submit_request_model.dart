class DocketSubmitRequestModel {
  Docket? docket;
  List<Invoices>? invoices;

  DocketSubmitRequestModel({this.docket, this.invoices});

  DocketSubmitRequestModel.fromJson(Map<String, dynamic> json) {
    docket = json['docket'] != null ? Docket.fromJson(json['docket']) : null;
    if (json['invoices'] != null) {
      invoices = <Invoices>[];
      json['invoices'].forEach((v) {
        invoices!.add(Invoices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (docket != null) {
      data['docket'] = docket!.toJson();
    }
    if (invoices != null) {
      data['invoices'] = invoices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Docket {
  String? dockno;
  String? dockdt;
  String? manualDockno;
  String? ewayBillNo;
  String? partYCODE;
  String? frompincode;
  String? topincode;
  int? pkgsno;
  double? actuwt;
  String? reassigNDESTCD;
  String? csgncd;
  String? csgnnm;
  String? csgecd;
  String? csgenm;
  String? fromCity;
  String? orgncd;
  String? orgNstnm;
  String? orgnArea;
  String? toCity;
  String? destcd;
  String? desTstnm;
  String? destArea;
  String? pkpDly;
  String? transTypeUnderscore;
  String? serviceTypeUnderscore;
  String? pkgsty;
  String? businesstype;
  String? contractID;
  dynamic freightCharge;
  dynamic freightRate;
  String? rateType;
  dynamic trDays;
  String? invoiceRateApplay;
  int? invoiceRate;
  String? billingState;
  String? serviceType;
  String? ftlType;
  String? transMode;
  double? chargedWeight;
  int? noOfPkgs;
  double? acTWT;
  String? orderID;
  double? invAmt;
  String? invNo;
  String? companyCode;

  Docket({
    this.dockno,
    this.dockdt,
    this.manualDockno,
    this.ewayBillNo,
    this.partYCODE,
    this.frompincode,
    this.topincode,
    this.pkgsno,
    this.actuwt,
    this.reassigNDESTCD,
    this.csgncd,
    this.csgnnm,
    this.csgecd,
    this.csgenm,
    this.fromCity,
    this.orgncd,
    this.orgNstnm,
    this.orgnArea,
    this.toCity,
    this.destcd,
    this.desTstnm,
    this.destArea,
    this.pkpDly,
    this.transTypeUnderscore,
    this.serviceTypeUnderscore,
    this.pkgsty,
    this.businesstype,
    this.contractID,
    this.freightCharge,
    this.freightRate,
    this.rateType,
    this.trDays,
    this.invoiceRateApplay,
    this.invoiceRate,
    this.billingState,
    this.serviceType,
    this.ftlType,
    this.transMode,
    this.chargedWeight,
    this.noOfPkgs,
    this.acTWT,
    this.orderID,
    this.invAmt,
    this.invNo,
    this.companyCode,
  });

  Docket.fromJson(Map<String, dynamic> json) {
    dockno = json['dockno'];
    dockdt = json['dockdt'];
    manualDockno = json['manual_dockno'];
    ewayBillNo = json['ewayBillNo'];
    partYCODE = json['partY_CODE'];
    frompincode = json['frompincode'];
    topincode = json['topincode'];
    pkgsno = json['pkgsno'];
    actuwt = json['actuwt'];
    reassigNDESTCD = json['reassigN_DESTCD'];
    csgncd = json['csgncd'];
    csgnnm = json['csgnnm'];
    csgecd = json['csgecd'];
    csgenm = json['csgenm'];
    fromCity = json['fromCity'];
    orgncd = json['orgncd'];
    orgNstnm = json['orgNstnm'];
    orgnArea = json['orgnArea'];
    toCity = json['toCity'];
    destcd = json['destcd'];
    desTstnm = json['desTstnm'];
    destArea = json['destArea'];
    pkpDly = json['pkp_dly'];
    transTypeUnderscore = json['trans_type'];
    serviceTypeUnderscore = json['service_type'];
    pkgsty = json['pkgsty'];
    businesstype = json['businesstype'];
    contractID = json['contractID'];
    freightCharge = json['freightCharge'];
    freightRate = json['freightRate'];
    rateType = json['rateType'];
    trDays = json['trDays'];
    invoiceRateApplay = json['invoiceRateApplay'];
    invoiceRate = json['invoiceRate'];
    billingState = json['billingState'];
    serviceType = json['serviceType'];
    ftlType = json['ftlType'];
    transMode = json['transMode'];
    chargedWeight = json['chargedWeight'];
    noOfPkgs = json['noOfPkgs'];
    acTWT = json['acT_WT'];
    orderID = json['orderID'];
    invAmt = json['invAmt'];
    invNo = json['invNo'];
    companyCode = json['CompanyCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dockno'] = dockno;
    data['dockdt'] = dockdt;
    data['manual_dockno'] = manualDockno;
    data['ewayBillNo'] = ewayBillNo;
    data['partY_CODE'] = partYCODE;
    data['frompincode'] = frompincode;
    data['topincode'] = topincode;
    data['pkgsno'] = pkgsno;
    data['actuwt'] = actuwt;
    data['reassigN_DESTCD'] = reassigNDESTCD;
    data['csgncd'] = csgncd;
    data['csgnnm'] = csgnnm;
    data['csgecd'] = csgecd;
    data['csgenm'] = csgenm;
    data['fromCity'] = fromCity;
    data['orgncd'] = orgncd;
    data['orgNstnm'] = orgNstnm;
    data['orgnArea'] = orgnArea;
    data['toCity'] = toCity;
    data['destcd'] = destcd;
    data['desTstnm'] = desTstnm;
    data['destArea'] = destArea;
    data['pkp_dly'] = pkpDly;
    data['trans_type'] = transTypeUnderscore;
    data['service_type'] = serviceTypeUnderscore;
    data['pkgsty'] = pkgsty;
    data['businesstype'] = businesstype;
    data['contractID'] = contractID;
    data['freightCharge'] = freightCharge;
    data['freightRate'] = freightRate;
    data['rateType'] = rateType;
    data['trDays'] = trDays;
    data['invoiceRateApplay'] = invoiceRateApplay;
    data['invoiceRate'] = invoiceRate;
    data['billingState'] = billingState;
    data['serviceType'] = serviceType;
    data['ftlType'] = ftlType;
    data['transMode'] = transMode;
    data['chargedWeight'] = chargedWeight;
    data['noOfPkgs'] = noOfPkgs;
    data['acT_WT'] = acTWT;
    data['orderID'] = orderID;
    data['invAmt'] = invAmt;
    data['invNo'] = invNo;
    data['CompanyCode'] = companyCode;
    return data;
  }
}

class Invoices {
  String? invno;
  int? pkgsno;
  double? actuwt;
  double? invamt;
  double? voLL;
  double? voLB;
  double? voLH;

  Invoices({
    this.invno,
    this.pkgsno,
    this.actuwt,
    this.invamt,
    this.voLL,
    this.voLB,
    this.voLH,
  });

  Invoices.fromJson(Map<String, dynamic> json) {
    invno = json['invno'];
    pkgsno = json['pkgsno'];
    actuwt = json['actuwt'];
    invamt = json['invamt'];
    voLL = json['voL_L'];
    voLB = json['voL_B'];
    voLH = json['voL_H'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invno'] = invno;
    data['pkgsno'] = pkgsno;
    data['actuwt'] = actuwt;
    data['invamt'] = invamt;
    data['voL_L'] = voLL;
    data['voL_B'] = voLB;
    data['voL_H'] = voLH;
    return data;
  }
}
