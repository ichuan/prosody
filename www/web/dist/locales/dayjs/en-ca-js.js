(self["webpackChunkconverse_js"] = self["webpackChunkconverse_js"] || []).push([[4035],{

/***/ 9451:
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

!function (e, a) {
   true ? module.exports = a(__webpack_require__(8570)) : 0;
}(this, function (e) {
  "use strict";

  function a(e) {
    return e && "object" == typeof e && "default" in e ? e : {
      default: e
    };
  }

  var _ = a(e),
      t = {
    name: "en-ca",
    weekdays: "Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),
    months: "January_February_March_April_May_June_July_August_September_October_November_December".split("_"),
    weekdaysShort: "Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),
    monthsShort: "Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),
    weekdaysMin: "Su_Mo_Tu_We_Th_Fr_Sa".split("_"),
    ordinal: function (e) {
      return e;
    },
    formats: {
      LT: "h:mm A",
      LTS: "h:mm:ss A",
      L: "YYYY-MM-DD",
      LL: "MMMM D, YYYY",
      LLL: "MMMM D, YYYY h:mm A",
      LLLL: "dddd, MMMM D, YYYY h:mm A"
    },
    relativeTime: {
      future: "in %s",
      past: "%s ago",
      s: "a few seconds",
      m: "a minute",
      mm: "%d minutes",
      h: "an hour",
      hh: "%d hours",
      d: "a day",
      dd: "%d days",
      M: "a month",
      MM: "%d months",
      y: "a year",
      yy: "%d years"
    }
  };

  return _.default.locale(t, null, !0), t;
});

/***/ })

}]);
//# sourceMappingURL=en-ca-js.js.map