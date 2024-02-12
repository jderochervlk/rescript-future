// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Caml_option = require("rescript/lib/js/caml_option.js");
var Caml_js_exceptions = require("rescript/lib/js/caml_js_exceptions.js");

function make(lazyPromise) {
  return function () {
    var tmp;
    try {
      tmp = lazyPromise();
    }
    catch (raw_e){
      var e = Caml_js_exceptions.internalToOCamlException(raw_e);
      tmp = new Promise((function (param, rej) {
              rej(e);
            }));
    }
    return tmp.then(function (t) {
                  return {
                          TAG: "Ok",
                          _0: t
                        };
                }).catch(function (e) {
                return {
                        TAG: "Error",
                        _0: e
                      };
              });
  };
}

function map(future, fn) {
  return function () {
    return future().then(function (t) {
                if (t.TAG === "Ok") {
                  return {
                          TAG: "Ok",
                          _0: fn(t._0)
                        };
                } else {
                  return {
                          TAG: "Error",
                          _0: t._0
                        };
                }
              });
  };
}

function mapError(future, fn) {
  return function () {
    return future().then(function (t) {
                if (t.TAG === "Ok") {
                  return {
                          TAG: "Ok",
                          _0: t._0
                        };
                } else {
                  return {
                          TAG: "Error",
                          _0: fn(t._0)
                        };
                }
              });
  };
}

function mapPromise(future, fn) {
  return function () {
    return future().then(function (t) {
                if (t.TAG === "Ok") {
                  return fn(t._0).then(function (t) {
                                return {
                                        TAG: "Ok",
                                        _0: t
                                      };
                              }).catch(function (e) {
                              return {
                                      TAG: "Error",
                                      _0: e
                                    };
                            });
                } else {
                  return {
                          TAG: "Error",
                          _0: t._0
                        };
                }
              });
  };
}

function flatMap(future, fn) {
  return function () {
    return future().then(function (t) {
                if (t.TAG === "Ok") {
                  return fn(t._0);
                } else {
                  return {
                          TAG: "Error",
                          _0: t._0
                        };
                }
              });
  };
}

function fold(future, errorFn, successFn) {
  return future().then(function (t) {
              if (t.TAG === "Ok") {
                return successFn(t._0);
              } else {
                return errorFn(t._0);
              }
            });
}

function run(future) {
  return future();
}

function all2(param) {
  var two = param[1];
  var one = param[0];
  return function () {
    return Promise.all([
                  one(),
                  two()
                ]).then(function (t) {
                var a = t[0];
                if (a.TAG === "Ok") {
                  var b = t[1];
                  if (b.TAG === "Ok") {
                    return {
                            TAG: "Ok",
                            _0: [
                              a._0,
                              b._0
                            ]
                          };
                  } else {
                    return {
                            TAG: "Error",
                            _0: [
                              undefined,
                              Caml_option.some(t[1]._0)
                            ]
                          };
                  }
                }
                var b$1 = t[1];
                var a$1 = a._0;
                if (b$1.TAG === "Ok") {
                  return {
                          TAG: "Error",
                          _0: [
                            Caml_option.some(a$1),
                            undefined
                          ]
                        };
                } else {
                  return {
                          TAG: "Error",
                          _0: [
                            Caml_option.some(a$1),
                            Caml_option.some(b$1._0)
                          ]
                        };
                }
              });
  };
}

function all3(param) {
  var three = param[2];
  var two = param[1];
  var one = param[0];
  return function () {
    return Promise.all([
                  one(),
                  two(),
                  three()
                ]).then(function (t) {
                var a = t[0];
                if (a.TAG === "Ok") {
                  var b = t[1];
                  if (b.TAG === "Ok") {
                    var c = t[2];
                    if (c.TAG === "Ok") {
                      return {
                              TAG: "Ok",
                              _0: [
                                a._0,
                                b._0,
                                c._0
                              ]
                            };
                    }
                    
                  }
                  
                } else {
                  var b$1 = t[1];
                  var a$1 = a._0;
                  if (b$1.TAG === "Ok") {
                    return {
                            TAG: "Error",
                            _0: [
                              Caml_option.some(a$1),
                              undefined,
                              undefined
                            ]
                          };
                  }
                  var c$1 = t[2];
                  if (c$1.TAG === "Ok") {
                    return {
                            TAG: "Error",
                            _0: [
                              Caml_option.some(a$1),
                              undefined,
                              undefined
                            ]
                          };
                  } else {
                    return {
                            TAG: "Error",
                            _0: [
                              Caml_option.some(a$1),
                              Caml_option.some(b$1._0),
                              Caml_option.some(c$1._0)
                            ]
                          };
                  }
                }
                var b$2 = t[1];
                if (b$2.TAG === "Ok") {
                  return {
                          TAG: "Error",
                          _0: [
                            undefined,
                            undefined,
                            Caml_option.some(t[2]._0)
                          ]
                        };
                } else {
                  return {
                          TAG: "Error",
                          _0: [
                            undefined,
                            Caml_option.some(b$2._0),
                            undefined
                          ]
                        };
                }
              });
  };
}

exports.make = make;
exports.map = map;
exports.mapError = mapError;
exports.mapPromise = mapPromise;
exports.flatMap = flatMap;
exports.fold = fold;
exports.run = run;
exports.all2 = all2;
exports.all3 = all3;
/* No side effect */
