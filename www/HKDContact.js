module.exports = {

  getContact:function (arg, successCallback, errorCallback) {

    cordova.exec(successCallback, errorCallback, "HKDContact", "getContact", [arg]);
  }
};
