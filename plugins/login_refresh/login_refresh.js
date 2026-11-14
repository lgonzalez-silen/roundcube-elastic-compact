// login_refresh: reload the login form once it's older than the pre-login session (see the .php).
(function () {
    var born = Date.now();
    function maxAge() { return ((window.rcmail && rcmail.env && rcmail.env.login_refresh_max_age) || 3000) * 1000; }
    function untouched() {   // never reload under someone who is typing
        var u = document.getElementById('rcmloginuser'), p = document.getElementById('rcmloginpwd');
        return u && p && !u.value && !p.value;   // (Roundcube autofocuses the user field, so focus alone isn't typing)
    }
    function check(force) {
        if (Date.now() - born < maxAge() || !document.getElementById('rcmloginpwd')) return;
        if (force || untouched()) location.replace(location.pathname + '?_task=login');   // GET: never re-POSTs
    }
    document.addEventListener('visibilitychange', function () { if (!document.hidden) check(true); });
    window.addEventListener('focus', function () { check(true); });
    window.addEventListener('pageshow', function (e) { if (e.persisted) check(true); });   // restored from back/forward cache
    setInterval(function () { check(false); }, 60000);
})();
