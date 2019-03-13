;
(function() {
  if (typeof TS == 'undefined' || typeof TS.vars == 'undefined') {
    return
  }
  if (typeof TS.vars.ymetrika != 'undefined' && TS.vars.ymetrika.length > 0) {
    (function(d, w, c) {
      (w[c] = w[c] || []).push(function() {
        try {
          w["yaCounter" + TS.vars.ymetrika] = new Ya.Metrika2({
            id: TS.vars.ymetrika * 1,
            clickmap: true,
            trackLinks: true,
            accurateTrackBounce: true,
            webvisor: true,
            ecommerce:"dataLayer"
          });
        } catch (e) {}
      });

      var n = d.getElementsByTagName("script")[0],
        s = d.createElement("script"),
        f = function() {
          n.parentNode.insertBefore(s, n);
        };
      s.type = "text/javascript";
      s.async = true;
      s.src = "https://mc.yandex.ru/metrika/tag.js";

      if (w.opera == "[object Opera]") {
        d.addEventListener("DOMContentLoaded", f, false);
      } else {
        f();
      }
    })(document, window, "yandex_metrika_callbacks2");
  }

  if (typeof TS.vars.ganalytics != 'undefined' && TS.vars.ganalytics.length > 0) {
    (function(i, s, o, g, r, a, m) {
      i['GoogleAnalyticsObject'] = r;
      i[r] = i[r] || function() {
        (i[r].q = i[r].q || []).push(arguments)
      }, i[r].l = 1 * new Date();
      a = s.createElement(o),
        m = s.getElementsByTagName(o)[0];
      a.async = 1;
      a.src = g;
      m.parentNode.insertBefore(a, m)
    })(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');

    ga('create', TS.vars.ganalytics, 'auto');
    ga('send', 'pageview');
  }
})();
