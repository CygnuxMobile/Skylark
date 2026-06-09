class AppConstants {
  // static const String baseUrl = 'http://43.248.56.36:44399/V1/';
    static const String baseUrl = 'http://43.248.56.36:44399/V1/';

  // ==========================================
  // AUTH MODULE
  // ==========================================
  static const String loginUrl = 'Authenticate/Login';

  // ==========================================
  // MASTER MODULE (COMMON DATA)
  // ==========================================
  static const String getLocationMasterDataUrl = 'Master/GetLocationMasterData';
  static const String getAllLocationListUrl = 'Master/GetAllLocationList';
  static const String getCustomerListUrl = 'Master/GetCustomerList';
  static const String getTransportModeUrl = 'Master/GetTransportMode';

  // ==========================================
  // BOOKING MODULE
  // ==========================================
  static const String getEwayBillDetailsUrl = 'Operation/GetEwaybillDetailsFromAPI';
  static const String getPincodeUrl = 'Operation/GetPincode';
  static const String getFromPincodeDetailsUrl = 'Operation/GetFromPincodeDetails';
  static const String getToPincodeDetailsUrl = 'Operation/GetToPincodeDetails';
  static const String getContractFreightUrl = 'Operation/GetContractFreight';
  static const String getConsigneeUrl = 'Operation/GetConsignee';
  static const String validateDocketSeriesUrl = 'Operation/ValidateDocketSeries';
  static const String docketSubmitUrl = 'Operation/DocketSubmit';

  // ==========================================
  // POD UPLOAD MODULE
  // ==========================================
  static const String getPODListUrl = 'Operation/GetPODlist';
  static const String uploadPODImageUrl = 'Operation/UploadPODImage';

  // ==========================================
  // STOCK UPDATE MODULE
  // ==========================================
  static const String stockUpdateListUrl = 'Operation/StockUpdateList';

  // ==========================================
  // PRS / DRS (COMMON OPERATION)
  // ==========================================
  static const String prsListUrl = 'Operation/PRSList';
  static const String drsListUrl = 'Operation/DRSUpdateList';
  static const String getVendorsUrl = 'Operation/GetVendorsFromVendorType';
  static const String getVehicleNoUrl = 'Operation/GetVehicleNo';
  static const String getTripsheetNoUrl = 'Operation/GetTripsheetNo';
  static const String getAvailableDocketUrl = 'Operation/AvalabledocketinPRSDRS';
  static const String preparePrsUrl = 'Operation/PreparePRS';
  static const String prepareDrsUrl = 'Operation/PrepareDRS';
  static const String prsArrivalUrl = 'Operation/PRSArrival';
  static const String thcArrivalsListUrl = 'Operation/THCArrivalsList';
  static const String thcArrivalSubmitUrl = 'Operation/THCArrivalSubmit';
  static const String updateDrsDetailsUrl = 'Operation/UpdateDRSDetails';
  static const String updateDrsUrl = 'Operation/UpdateDRS';
  static const String specialCostVoucherSubmitUrl = 'Operation/SpecialCostVoucherSubmit';
  static const String getAccountCodeListUrl = 'Operation/GetAccountCodeList';
  static const String validateDocumentUrl = 'Operation/ValidateDocument';
  static const String arrivalStockUpdateListUrl = 'Operation/ArrivalStockUpdateList';
  static const String arrivalStockUpdateDetailUrl = 'Operation/ArrivalStockUpdateDetail';
  static const String arrivalStockUpdateSubmitUrl = 'Operation/ArrivalStockUpdateSubmite';

  // ==========================================
  // STORAGE KEYS (LOCAL PREFERENCES)
  // ==========================================
  static const String tokenKey = 'token';
  static const String userDataKey = 'user_data';
  static const String isLoggedKey = 'is_logged_in';
  static const String selectedLocationKey = 'selected_location';
}
