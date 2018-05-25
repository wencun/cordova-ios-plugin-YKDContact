module.exports = {

selectContactInfo:function (arg, successCallback, errorCallback) {

    cordova.exec(successCallback, errorCallback, "YHContactPlugin", "selectContactInfo", [arg]);
  },
getAllContactInfo:function (arg, successCallback, errorCallback) {
    
    cordova.exec(successCallback, errorCallback, "YHContactPlugin", "getAllContactInfo", [arg]);
}
};
