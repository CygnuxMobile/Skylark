import 'dart:convert';

SpecialCostVoucherRequest specialCostVoucherRequestFromJson(String str) => SpecialCostVoucherRequest.fromJson(json.decode(str));

String specialCostVoucherRequestToJson(SpecialCostVoucherRequest data) => json.encode(data.toJson());

class SpecialCostVoucherRequest {
    VoucherData voucherData;
    List<ScVoucher> scVoucher;
    List<PaymentMode> paymentMode;
    List<GstCharge> gstCharges;
    TdsInfo tdsInfo;

    SpecialCostVoucherRequest({
        required this.voucherData,
        required this.scVoucher,
        required this.paymentMode,
        required this.gstCharges,
        required this.tdsInfo,
    });

    factory SpecialCostVoucherRequest.fromJson(Map<String, dynamic> json) => SpecialCostVoucherRequest(
        voucherData: VoucherData.fromJson(json["voucherData"]),
        scVoucher: List<ScVoucher>.from(json["scVoucher"].map((x) => ScVoucher.fromJson(x))),
        paymentMode: List<PaymentMode>.from(json["paymentMode"].map((x) => PaymentMode.fromJson(x))),
        gstCharges: List<GstCharge>.from(json["gstCharges"].map((x) => GstCharge.fromJson(x))),
        tdsInfo: TdsInfo.fromJson(json["tdsInfo"]),
    );

    Map<String, dynamic> toJson() => {
        "voucherData": voucherData.toJson(),
        "scVoucher": List<dynamic>.from(scVoucher.map((x) => x.toJson())),
        "paymentMode": List<dynamic>.from(paymentMode.map((x) => x.toJson())),
        "gstCharges": List<dynamic>.from(gstCharges.map((x) => x.toJson())),
        "tdsInfo": tdsInfo.toJson(),
    };
}

class GstCharge {
    String chargeCode;
    int percentage;
    int chargeAmount;
    String accountReceivable;
    String accountPayable;

    GstCharge({
        required this.chargeCode,
        required this.percentage,
        required this.chargeAmount,
        required this.accountReceivable,
        required this.accountPayable,
    });

    factory GstCharge.fromJson(Map<String, dynamic> json) => GstCharge(
        chargeCode: json["chargeCode"] ?? "",
        percentage: json["percentage"] ?? 0,
        chargeAmount: json["chargeAmount"] ?? 0,
        accountReceivable: json["accountReceivable"] ?? "",
        accountPayable: json["accountPayable"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "chargeCode": chargeCode,
        "percentage": percentage,
        "chargeAmount": chargeAmount,
        "accountReceivable": accountReceivable,
        "accountPayable": accountPayable,
    };
}

class PaymentMode {
    String paymentMode;
    String transactionMode;
    double netamount;
    double cashAmount;
    double chequeAmount;
    String chequeNo;
    DateTime chequedate;
    String cashAccount;
    String depositedInBank;
    String receivedFromBank;
    String businessDivision;
    String custTyp;

    PaymentMode({
        required this.paymentMode,
        required this.transactionMode,
        required this.netamount,
        required this.cashAmount,
        required this.chequeAmount,
        required this.chequeNo,
        required this.chequedate,
        required this.cashAccount,
        required this.depositedInBank,
        required this.receivedFromBank,
        required this.businessDivision,
        required this.custTyp,
    });

    factory PaymentMode.fromJson(Map<String, dynamic> json) => PaymentMode(
        paymentMode: json["paymentMode"] ?? "",
        transactionMode: json["transactionMode"] ?? "",
        netamount: (json["netamount"] ?? 0).toDouble(),
        cashAmount: (json["cashAmount"] ?? 0).toDouble(),
        chequeAmount: (json["chequeAmount"] ?? 0).toDouble(),
        chequeNo: json["chequeNo"] ?? "",
        chequedate: DateTime.parse(json["chequedate"] ?? DateTime.now().toIso8601String()),
        cashAccount: json["cashAccount"] ?? "",
        depositedInBank: json["depositedInBank"] ?? "",
        receivedFromBank: json["receivedFromBank"] ?? "",
        businessDivision: json["businessDivision"] ?? "",
        custTyp: json["custTyp"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "paymentMode": paymentMode,
        "transactionMode": transactionMode,
        "netamount": netamount,
        "cashAmount": cashAmount,
        "chequeAmount": chequeAmount,
        "chequeNo": chequeNo,
        "chequedate": chequedate.toUtc().toIso8601String(),
        "cashAccount": cashAccount,
        "depositedInBank": depositedInBank,
        "receivedFromBank": receivedFromBank,
        "businessDivision": businessDivision,
        "custTyp": custTyp,
    };
}

class ScVoucher {
    String accountCode;
    String amount;
    String narrationAccountinfo;
    String docNo;
    String docType;

    ScVoucher({
        required this.accountCode,
        required this.amount,
        required this.narrationAccountinfo,
        required this.docNo,
        required this.docType,
    });

    factory ScVoucher.fromJson(Map<String, dynamic> json) => ScVoucher(
        accountCode: json["accountCode"] ?? "",
        amount: json["amount"] ?? "0",
        narrationAccountinfo: json["narrationAccountinfo"] ?? "",
        docNo: json["docNo"] ?? "",
        docType: json["docType"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "accountCode": accountCode,
        "amount": amount,
        "narrationAccountinfo": narrationAccountinfo,
        "docNo": docNo,
        "docType": docType,
    };
}

class TdsInfo {
    bool isTdsEnabled;
    double tdsRate;
    double tdsAmount;
    String tdsAcccode;

    TdsInfo({
        required this.isTdsEnabled,
        required this.tdsRate,
        required this.tdsAmount,
        required this.tdsAcccode,
    });

    factory TdsInfo.fromJson(Map<String, dynamic> json) => TdsInfo(
        isTdsEnabled: json["isTDSEnabled"] ?? false,
        tdsRate: (json["tdsRate"] ?? 0).toDouble(),
        tdsAmount: (json["tdsAmount"] ?? 0).toDouble(),
        tdsAcccode: json["tdsAcccode"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "isTDSEnabled": isTdsEnabled,
        "tdsRate": tdsRate,
        "tdsAmount": tdsAmount,
        "tdsAcccode": tdsAcccode,
    };
}

class VoucherData {
    String financialYear;
    DateTime voucherDate;
    String entryBy;
    String baseLocationCode;
    String companyCode;
    String accountingLocation;
    String preparedatlocation;
    String custTyp;
    String custCode;
    String customerName;
    String narration;
    String manualNo;
    String referenceNo;
    String preparedFor;
    String gstType;
    String panNumber;
    String hEducationCess;
    String educationCess;
    bool isServicetaxapply;
    String serviceTaxRegNo;
    int hdnServiceTaxRate;
    int serviceTax;
    bool isTdStaxapply;
    String tdsSection;
    double tdsRate;
    double tdsAmount;
    int totalKm;
    String floor;
    String frontDocument;
    String backDocument;

    VoucherData({
        required this.financialYear,
        required this.voucherDate,
        required this.entryBy,
        required this.baseLocationCode,
        required this.companyCode,
        required this.accountingLocation,
        required this.preparedatlocation,
        required this.custTyp,
        required this.custCode,
        required this.customerName,
        required this.narration,
        required this.manualNo,
        required this.referenceNo,
        required this.preparedFor,
        required this.gstType,
        required this.panNumber,
        required this.hEducationCess,
        required this.educationCess,
        required this.isServicetaxapply,
        required this.serviceTaxRegNo,
        required this.hdnServiceTaxRate,
        required this.serviceTax,
        required this.isTdStaxapply,
        required this.tdsSection,
        required this.tdsRate,
        required this.tdsAmount,
        required this.totalKm,
        required this.floor,
        required this.frontDocument,
        required this.backDocument,
    });

    factory VoucherData.fromJson(Map<String, dynamic> json) => VoucherData(
        financialYear: json["financialYear"] ?? "",
        voucherDate: DateTime.parse(json["voucherDate"] ?? DateTime.now().toIso8601String()),
        entryBy: json["entryBy"] ?? "",
        baseLocationCode: json["baseLocationCode"] ?? "",
        companyCode: json["companyCode"] ?? "",
        accountingLocation: json["accountingLocation"] ?? "",
        preparedatlocation: json["preparedatlocation"] ?? "",
        custTyp: json["custTyp"] ?? "",
        custCode: json["custCode"] ?? "",
        customerName: json["customerName"] ?? "",
        narration: json["narration"] ?? "",
        manualNo: json["manualNo"] ?? "",
        referenceNo: json["referenceNo"] ?? "",
        preparedFor: json["preparedFor"] ?? "",
        gstType: json["gstType"] ?? "",
        panNumber: json["panNumber"] ?? "",
        hEducationCess: json["hEducationCess"] ?? "",
        educationCess: json["educationCess"]?.toString() ?? "",
        isServicetaxapply: json["isServicetaxapply"] ?? false,
        serviceTaxRegNo: json["serviceTaxRegNo"] ?? "",
        hdnServiceTaxRate: json["hdnServiceTaxRate"] ?? 0,
        serviceTax: json["serviceTax"] ?? 0,
        isTdStaxapply: json["isTDStaxapply"] ?? false,
        tdsSection: json["tdsSection"] ?? "",
        tdsRate: (json["tdsRate"] ?? 0).toDouble(),
        tdsAmount: (json["tdsAmount"] ?? 0).toDouble(),
        totalKm: int.tryParse(json["totalKm"]?.toString() ?? "0") ?? 0,
        floor: json["floor"] ?? "",
        frontDocument: json["frontDocument"] ?? "",
        backDocument: json["backDocument"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "financialYear": financialYear,
        "voucherDate": voucherDate.toUtc().toIso8601String(),
        "entryBy": entryBy,
        "baseLocationCode": baseLocationCode,
        "companyCode": companyCode,
        "accountingLocation": accountingLocation,
        "preparedatlocation": preparedatlocation,
        "custTyp": custTyp,
        "custCode": custCode,
        "customerName": customerName,
        "narration": narration,
        "manualNo": manualNo,
        "referenceNo": referenceNo,
        "preparedFor": preparedFor,
        "gstType": gstType,
        "panNumber": panNumber,
        "hEducationCess": hEducationCess,
        "educationCess": educationCess,
        "isServicetaxapply": isServicetaxapply,
        "serviceTaxRegNo": serviceTaxRegNo,
        "hdnServiceTaxRate": hdnServiceTaxRate,
        "serviceTax": serviceTax,
        "isTDStaxapply": isTdStaxapply,
        "tdsSection": tdsSection,
        "tdsRate": tdsRate,
        "tdsAmount": tdsAmount,
        "totalKm": totalKm,
        "floor": floor,
        "frontDocument": frontDocument,
        "backDocument": backDocument,
    };
}
