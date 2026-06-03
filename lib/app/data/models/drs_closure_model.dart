import 'dart:convert';

DrsClosureRequestModel drsClosureRequestModelFromJson(String str) => DrsClosureRequestModel.fromJson(json.decode(str));

String drsClosureRequestModelToJson(DrsClosureRequestModel data) => json.encode(data.toJson());

class DrsClosureRequestModel {
  DrsSummary drsSummary;
  List<UpdateDrsList> updateDRSLits;
  double loadingCharge;
  String baseUserName;

  DrsClosureRequestModel({
    required this.drsSummary,
    required this.updateDRSLits,
    required this.loadingCharge,
    required this.baseUserName,
  });

  factory DrsClosureRequestModel.fromJson(Map<String, dynamic> json) => DrsClosureRequestModel(
    drsSummary: DrsSummary.fromJson(json["drsSummary"]),
    updateDRSLits: List<UpdateDrsList>.from(json["updateDRSLits"].map((x) => UpdateDrsList.fromJson(x))),
    loadingCharge: (json["loadingCharge"] ?? 0).toDouble(),
    baseUserName: json["baseUserName"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "DRSSummary": drsSummary.toJson(),
    "UpdateDRSLits": List<dynamic>.from(updateDRSLits.map((x) => x.toJson())),
    "LoadingCharge": loadingCharge,
    "BaseUserName": baseUserName,
  };
}

class DrsSummary {
  String pdcno;
  String pdCDt;
  String deliveryBy;
  String bAVendorCode;
  String staff;
  String driverName;
  String vehno;
  double startKm;
  int totalDocketsInDrs;
  double closeKm;
  String pdCUpdated;
  String fromDate;
  String toDate;
  String drsNoList;
  String dockno;
  String dockdt;
  String drs;
  String drSDt;
  int autoNo;
  String loadingBy;
  String rateType;
  double loadingCharge;
  double rate;
  double maxLimit;
  String vendorCode;
  String vendorName;
  bool isMonthly;
  double hdnRate;
  bool isMathadi;
  String mathadiSlipNo;
  String mathadiDate;
  double mathadiAmt;
  int pkgsno;
  double actuwt;
  String drsDate;
  double frtAmt;
  double othAmt;
  double finAmt;

  DrsSummary({
    required this.pdcno,
    required this.pdCDt,
    required this.deliveryBy,
    required this.bAVendorCode,
    required this.staff,
    required this.driverName,
    required this.vehno,
    required this.startKm,
    required this.totalDocketsInDrs,
    required this.closeKm,
    required this.pdCUpdated,
    required this.fromDate,
    required this.toDate,
    required this.drsNoList,
    required this.dockno,
    required this.dockdt,
    required this.drs,
    required this.drSDt,
    required this.autoNo,
    required this.loadingBy,
    required this.rateType,
    required this.loadingCharge,
    required this.rate,
    required this.maxLimit,
    required this.vendorCode,
    required this.vendorName,
    required this.isMonthly,
    required this.hdnRate,
    required this.isMathadi,
    required this.mathadiSlipNo,
    required this.mathadiDate,
    required this.mathadiAmt,
    required this.pkgsno,
    required this.actuwt,
    required this.drsDate,
    required this.frtAmt,
    required this.othAmt,
    required this.finAmt,
  });

  factory DrsSummary.fromJson(Map<String, dynamic> json) => DrsSummary(
    pdcno: json["pdcno"] ?? "",
    pdCDt: json["pdC_Dt"] ?? "",
    deliveryBy: json["deliveryBy"] ?? "",
    bAVendorCode: json["bA_Vendor_Code"] ?? "",
    staff: json["staff"] ?? "",
    driverName: json["driverName"] ?? ".",
    vehno: json["vehno"] ?? "",
    startKm: (json["start_KM"] ?? 0).toDouble(),
    totalDocketsInDrs: (json["total_Dockets_In_DRS"] ?? 0).toInt(),
    closeKm: (json["closeKM"] ?? 0).toDouble(),
    pdCUpdated: json["pdC_Updated"] ?? "No",
    fromDate: json["fromDate"] ?? "",
    toDate: json["toDate"] ?? "",
    drsNoList: json["drsNoList"] ?? "",
    dockno: json["dockno"] ?? "",
    dockdt: json["dockdt"] ?? "",
    drs: json["drs"] ?? "",
    drSDt: json["drS_DT"] ?? "",
    autoNo: (json["autoNo"] ?? 0).toInt(),
    loadingBy: json["loadingBy"] ?? "",
    rateType: json["rateType"] ?? "0",
    loadingCharge: (json["loadingCharge"] ?? 0).toDouble(),
    rate: (json["rate"] ?? 0).toDouble(),
    maxLimit: (json["maxLimit"] ?? 0).toDouble(),
    vendorCode: json["vendorCode"] ?? "",
    vendorName: json["vendorName"] ?? "",
    isMonthly: json["isMonthly"] ?? false,
    hdnRate: (json["hdnRate"] ?? 0).toDouble(),
    isMathadi: json["isMathadi"] ?? false,
    mathadiSlipNo: json["mathadiSlipNo"] ?? "",
    mathadiDate: json["mathadiDate"] ?? "",
    mathadiAmt: (json["mathadiAmt"] ?? 0).toDouble(),
    pkgsno: (json["pkgsno"] ?? 0).toInt(),
    actuwt: (json["actuwt"] ?? 0).toDouble(),
    drsDate: json["drsDate"] ?? "",
    frtAmt: (json["frT_AMT"] ?? 0).toDouble(),
    othAmt: (json["otH_AMT"] ?? 0).toDouble(),
    finAmt: (json["fiN_AMT"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "pdcno": pdcno,
    "pdC_Dt": pdCDt,
    "deliveryBy": deliveryBy,
    "bA_Vendor_Code": bAVendorCode,
    "staff": staff,
    "driverName": driverName,
    "vehno": vehno,
    "start_KM": startKm,
    "total_Dockets_In_DRS": totalDocketsInDrs,
    "closeKM": closeKm,
    "pdC_Updated": pdCUpdated,
    "fromDate": fromDate,
    "toDate": toDate,
    "drsNoList": drsNoList,
    "dockno": dockno,
    "dockdt": dockdt,
    "drs": drs,
    "drS_DT": drSDt,
    "autoNo": autoNo,
    "loadingBy": loadingBy,
    "rateType": rateType,
    "loadingCharge": loadingCharge,
    "rate": rate,
    "maxLimit": maxLimit,
    "vendorCode": vendorCode,
    "vendorName": vendorName,
    "isMonthly": isMonthly,
    "hdnRate": hdnRate,
    "isMathadi": isMathadi,
    "mathadiSlipNo": mathadiSlipNo,
    "mathadiDate": mathadiDate,
    "mathadiAmt": mathadiAmt,
    "pkgsno": pkgsno,
    "actuwt": actuwt,
    "drsDate": drsDate,
    "frT_AMT": frtAmt,
    "otH_AMT": othAmt,
    "fiN_AMT": finAmt,
  };
}

class UpdateDrsList {
  int autoNo;
  String dockno;
  String docksf;
  String bookingDate;
  String orgncd;
  String destcd;
  String payBasis;
  String csgncd;
  String csgnnm;
  String csgecd;
  String csgenm;
  int pkgsArrived;
  int pkgsBooked;
  int pkgsPending;
  double bookedWt;
  double wtArrived;
  String commDelyDt;
  double freight;
  double docketTotal;
  double serviceTax;
  String delyLocation;
  String currLoc;
  String payBasCode;
  String dockDt;
  String coDDod;
  double coddodAmount;
  String cdeldTDdmmyyyy;
  String dockDtDdmmyyyy;
  String dlypdcno;
  bool coddod;
  int pkgsdelivered;
  String remark;
  String otp;
  String delydate;
  String delytime;
  String delyperson;
  String cboReason;
  int coddodcollected;
  int coddodno;
  String cboLateReason;
  String hDcboReason;
  bool isChecked;
  int pkgQty;
  int actQty;
  double rate;
  double maxLimit;
  double newRate;
  String ratetype;
  bool isEnabled;
  bool isEnabledBadPodoption;
  String backPod;
  String frontPod;

  UpdateDrsList({
    required this.autoNo,
    required this.dockno,
    required this.docksf,
    required this.bookingDate,
    required this.orgncd,
    required this.destcd,
    required this.payBasis,
    required this.csgncd,
    required this.csgnnm,
    required this.csgecd,
    required this.csgenm,
    required this.pkgsArrived,
    required this.pkgsBooked,
    required this.pkgsPending,
    required this.bookedWt,
    required this.wtArrived,
    required this.commDelyDt,
    required this.freight,
    required this.docketTotal,
    required this.serviceTax,
    required this.delyLocation,
    required this.currLoc,
    required this.payBasCode,
    required this.dockDt,
    required this.coDDod,
    required this.coddodAmount,
    required this.cdeldTDdmmyyyy,
    required this.dockDtDdmmyyyy,
    required this.dlypdcno,
    required this.coddod,
    required this.pkgsdelivered,
    required this.remark,
    required this.otp,
    required this.delydate,
    required this.delytime,
    required this.delyperson,
    required this.cboReason,
    required this.coddodcollected,
    required this.coddodno,
    required this.cboLateReason,
    required this.hDcboReason,
    required this.isChecked,
    required this.pkgQty,
    required this.actQty,
    required this.rate,
    required this.maxLimit,
    required this.newRate,
    required this.ratetype,
    required this.isEnabled,
    required this.isEnabledBadPodoption,
    required this.backPod,
    required this.frontPod,
  });

  factory UpdateDrsList.fromJson(Map<String, dynamic> json) => UpdateDrsList(
    autoNo: (json["autoNo"] ?? 0).toInt(),
    dockno: json["dockno"] ?? "",
    docksf: json["docksf"] ?? ".",
    bookingDate: json["booking_Date"] ?? "",
    orgncd: json["orgncd"] ?? "",
    destcd: json["destcd"] ?? "",
    payBasis: json["payBasis"] ?? "",
    csgncd: json["csgncd"] ?? "",
    csgnnm: json["csgnnm"] ?? "",
    csgecd: json["csgecd"] ?? "",
    csgenm: json["csgenm"] ?? "",
    pkgsArrived: (json["pkgs_Arrived"] ?? 0).toInt(),
    pkgsBooked: (json["pkgs_Booked"] ?? 0).toInt(),
    pkgsPending: (json["pkgs_Pending"] ?? 0).toInt(),
    bookedWt: (json["booked_Wt"] ?? 0).toDouble(),
    wtArrived: (json["wt_Arrived"] ?? 0).toDouble(),
    commDelyDt: json["comm_Dely_Dt"] ?? "",
    freight: (json["freight"] ?? 0).toDouble(),
    docketTotal: (json["docket_Total"] ?? 0).toDouble(),
    serviceTax: (json["service_Tax"] ?? 0).toDouble(),
    delyLocation: json["delyLocation"] ?? "",
    currLoc: json["curr_loc"] ?? "",
    payBasCode: json["payBasCode"] ?? "",
    dockDt: json["dockDt"] ?? "",
    coDDod: json["coD_DOD"] ?? "N",
    coddodAmount: (json["coddodAmount"] ?? 0).toDouble(),
    cdeldTDdmmyyyy: json["cdeldT_ddmmyyyy"] ?? "",
    dockDtDdmmyyyy: json["dockDt_ddmmyyyy"] ?? "",
    dlypdcno: json["dlypdcno"] ?? "",
    coddod: json["coddod"] ?? false,
    pkgsdelivered: (json["pkgsdelivered"] ?? 0).toInt(),
    remark: json["remark"] ?? "",
    otp: json["otp"] ?? "",
    delydate: json["delydate"] ?? "",
    delytime: json["delytime"] ?? "",
    delyperson: json["delyperson"] ?? "",
    cboReason: json["cboReason"] ?? "",
    coddodcollected: (json["coddodcollected"] ?? 0).toInt(),
    coddodno: (json["coddodno"] ?? 0).toInt(),
    cboLateReason: json["cboLateReason"] ?? "",
    hDcboReason: json["hDcboReason"] ?? "",
    isChecked: json["isChecked"] ?? false,
    pkgQty: (json["pkgQty"] ?? 0).toInt(),
    actQty: (json["actQty"] ?? 0).toInt(),
    rate: (json["rate"] ?? 0).toDouble(),
    maxLimit: (json["maxLimit"] ?? 0).toDouble(),
    newRate: (json["newRate"] ?? 0).toDouble(),
    ratetype: json["ratetype"] ?? "",
    isEnabled: json["isEnabled"] ?? false,
    isEnabledBadPodoption: json["isEnabledBadPodoption"] ?? false,
    backPod: json["backPOD"] ?? "",
    frontPod: json["frontPOD"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "autoNo": autoNo,
    "dockno": dockno,
    "docksf": docksf,
    "booking_Date": bookingDate,
    "orgncd": orgncd,
    "destcd": destcd,
    "payBasis": payBasis,
    "csgncd": csgncd,
    "csgnnm": csgnnm,
    "csgecd": csgecd,
    "csgenm": csgenm,
    "pkgs_Arrived": pkgsArrived,
    "pkgs_Booked": pkgsBooked,
    "pkgs_Pending": pkgsPending,
    "booked_Wt": bookedWt,
    "wt_Arrived": wtArrived,
    "comm_Dely_Dt": commDelyDt,
    "freight": freight,
    "docket_Total": docketTotal,
    "service_Tax": serviceTax,
    "delyLocation": delyLocation,
    "curr_loc": currLoc,
    "payBasCode": payBasCode,
    "dockDt": dockDt,
    "coD_DOD": coDDod,
    "coddodAmount": coddodAmount,
    "cdeldT_ddmmyyyy": cdeldTDdmmyyyy,
    "dockDt_ddmmyyyy": dockDtDdmmyyyy,
    "dlypdcno": dlypdcno,
    "coddod": coddod,
    "pkgsdelivered": pkgsdelivered,
    "remark": remark,
    "otp": otp,
    "delydate": delydate,
    "delytime": delytime,
    "delyperson": delyperson,
    "cboReason": cboReason,
    "coddodcollected": coddodcollected,
    "coddodno": coddodno,
    "cboLateReason": cboLateReason,
    "hDcboReason": hDcboReason,
    "isChecked": isChecked,
    "pkgQty": pkgQty,
    "actQty": actQty,
    "rate": rate,
    "maxLimit": maxLimit,
    "newRate": newRate,
    "ratetype": ratetype,
    "isEnabled": isEnabled,
    "isEnabledBadPodoption": isEnabledBadPodoption,
    "backPOD": backPod,
    "frontPOD": frontPod,
  };
}
