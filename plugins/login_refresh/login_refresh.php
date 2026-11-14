<?php
/**
 * login_refresh: avoid "Invalid request! No data was saved." on the first login attempt.
 * Roundcube only accepts a login POST while the pre-login session that rendered the form still exists
 * (index.php: $_SESSION['temp'] + request token). A login page left open longer than session_lifetime
 * has lost that session, so the first submit fails and only the second (from the freshly rendered
 * error page) works. This reloads a stale login page before it's used. Skin-independent.
 */
class login_refresh extends rcube_plugin
{
    public $task = 'login|logout';

    public function init()
    {
        $rc = rcmail::get_instance();
        if ($rc->output && $rc->output->type == 'html') {
            // reload a little before the server-side pre-login session can expire (lifetime is in minutes)
            $life = (int) $rc->config->get('session_lifetime', 10) * 60;
            $rc->output->set_env('login_refresh_max_age', max(60, $life - min(600, intdiv($life, 6))));
            $this->include_script('login_refresh.js');
        }
    }
}
