import 'dart:convert';

PrsRequestModel prsRequestModelFromJson(String str) => PrsRequestModel.fromJson(json.decode(str));

String prsRequestModelToJson(PrsRequestModel data) => json.encode(data.toJson());

class PrsRequestModel {
    String prsNo;
    DateTime prscDate;
    String entryBy;
    String vendorcode;
    String vendorname;
    String vehicleNo;
    String vendorType;
    String tripsheetno;
    String fromCity;
    String toCity;
    String baseUserName;
    String baseLocationCode;
    String baseCompanyCode;
    String baseFinYear;
    String docType;
    String startKm;
    String? cdNo;
    List<PrsGenerateList> prsGenerateList;

    PrsRequestModel({
        required this.prsNo,
        required this.prscDate,
        required this.entryBy,
        required this.vendorcode,
        required this.vendorname,
        required this.vehicleNo,
        required this.vendorType,
        required this.tripsheetno,
        required this.fromCity,
        required this.toCity,
        required this.baseUserName,
        required this.baseLocationCode,
        required this.baseCompanyCode,
        required this.baseFinYear,
        required this.docType,
        required this.startKm,
        this.cdNo,
        required this.prsGenerateList,
    });

    factory PrsRequestModel.fromJson(Map<String, dynamic> json) => PrsRequestModel(
        prsNo: json["prsNo"] ?? "",
        prscDate: json["prscDate"] != null ? DateTime.parse(json["prscDate"]) : DateTime.now(),
        entryBy: json["entryBy"] ?? "",
        vendorcode: json["vendorcode"] ?? "",
        vendorname: json["vendorname"] ?? "",
        vehicleNo: json["vehicleNo"] ?? "",
        vendorType: json["vendor_type"] ?? "",
        tripsheetno: json["tripsheetno"] ?? "",
        fromCity: json["from_City"] ?? "",
        toCity: json["to_City"] ?? "",
        baseUserName: json["baseUserName"] ?? "",
        baseLocationCode: json["baseLocationCode"] ?? "",
        baseCompanyCode: json["baseCompanyCode"] ?? "",
        baseFinYear: json["baseFinYear"] ?? "",
        docType: json["doc_Type"] ?? "",
        startKm: json["start_KM"] ?? "0",
        cdNo: json["cdNo"],
        prsGenerateList: json["prsGenerateList"] != null 
            ? List<PrsGenerateList>.from(json["prsGenerateList"].map((x) => PrsGenerateList.fromJson(x)))
            : [],
    );

    Map<String, dynamic> toJson() => {
        "prsNo": prsNo,
        "prscDate": prscDate.toUtc().toIso8601String(),
        "entryBy": entryBy,
        "vendorcode": vendorcode,
        "vendorname": vendorname,
        "vehicleNo": vehicleNo,
        "vendor_type": vendorType,
        "tripsheetno": tripsheetno,
        "from_City": fromCity,
        "to_City": toCity,
        "baseUserName": baseUserName,
        "baseLocationCode": baseLocationCode,
        "baseCompanyCode": baseCompanyCode,
        "baseFinYear": baseFinYear,
        "doc_Type": docType,
        "start_KM": startKm,
        "cdNo": cdNo,
        "prsGenerateList": List<dynamic>.from(prsGenerateList.map((x) => x.toJson())),
    };
}

class PrsGenerateList {
    String dockno;
    String docksf;
    String orgncd;
    int pkgsno;
    int arrPkgQty;
    int pendPkgQty;
    String payBas;
    double actuwt;
    double arrWeightQty;
    double chrgwt;
    String trNMod;
    int dkttot;
    String desTCd;
    DateTime pdcdt;
    DateTime bkgDate;
    int rate;
    int ratetype;

    PrsGenerateList({
        required this.dockno,
        required this.docksf,
        required this.orgncd,
        required this.pkgsno,
        required this.arrPkgQty,
        required this.pendPkgQty,
        required this.payBas,
        required this.actuwt,
        required this.arrWeightQty,
        required this.chrgwt,
        required this.trNMod,
        required this.dkttot,
        required this.desTCd,
        required this.pdcdt,
        required this.bkgDate,
        required this.rate,
        required this.ratetype,
    });

    factory PrsGenerateList.fromJson(Map<String, dynamic> json) => PrsGenerateList(
        dockno: json["dockno"] ?? "",
        docksf: json["docksf"] ?? "",
        orgncd: json["orgncd"] ?? "",
        pkgsno: (json["pkgsno"] ?? 0).toInt(),
        arrPkgQty: (json["arrPkgQty"] ?? 0).toInt(),
        pendPkgQty: (json["pendPkgQty"] ?? 0).toInt(),
        payBas: json["payBas"] ?? "",
        actuwt: (json["actuwt"] ?? 0.0).toDouble(),
        arrWeightQty: (json["arrWeightQty"] ?? 0.0).toDouble(),
        chrgwt: (json["chrgwt"] ?? 0.0).toDouble(),
        trNMod: json["trN_MOD"] ?? "",
        dkttot: (json["dkttot"] ?? 0).toInt(),
        desTCd: json["desT_CD"] ?? "",
        pdcdt: json["pdcdt"] != null ? DateTime.parse(json["pdcdt"]) : DateTime.now(),
        bkgDate: json["bkg_Date"] != null ? DateTime.parse(json["bkg_Date"]) : DateTime.now(),
        rate: (json["rate"] ?? 0).toInt(),
        ratetype: (json["ratetype"] ?? 0).toInt(),
    );

    Map<String, dynamic> toJson() => {
        "dockno": dockno,
        "docksf": docksf,
        "orgncd": orgncd,
        "pkgsno": pkgsno,
        "arrPkgQty": arrPkgQty,
        "pendPkgQty": pendPkgQty,
        "payBas": payBas,
        "actuwt": actuwt,
        "arrWeightQty": arrWeightQty,
        "chrgwt": chrgwt,
        "trN_MOD": trNMod,
        "dkttot": dkttot,
        "desT_CD": desTCd,
        "pdcdt": pdcdt.toUtc().toIso8601String(),
        "bkg_Date": bkgDate.toUtc().toIso8601String(),
        "rate": rate,
        "ratetype": ratetype,
    };
}
