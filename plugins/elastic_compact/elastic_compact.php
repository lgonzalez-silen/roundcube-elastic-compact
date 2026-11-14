<?php
/**
 * elastic_compact: helpers for the "Elastic Compact" skin (skins/elastic_compact).
 * - Draggable bar between the message list and the preview (height remembered per browser).
 * - Extra message-list columns: "To" = the address the message was originally delivered to
 *   (bottom-most Delivered-To, i.e. the first mailbox that accepted it, e.g. a Gmail
 *   address before forwarding; falls back to X-Original-To, then the To header). Skipped where
 *   the From/To column already shows To (Sent, Drafts). Size is always shown (CSS).
 * Active only for users on the Elastic Compact skin.
 */
class elastic_compact extends rcube_plugin
{
    public $task = 'mail';

    public function init()
    {
        $rc = rcmail::get_instance();
        if ($rc->config->get('skin') != 'elastic_compact') {
            return;
        }
        if ($rc->output && $rc->output->type == 'html') {
            $this->include_script('elastic_compact.js');
        }
        $this->add_hook('storage_init', [$this, 'storage_init']);
        $this->add_hook('render_page', [$this, 'render_page']);
        $this->add_hook('messages_list', [$this, 'messages_list']);
    }

    // client-side column list for the (only) widescreen layout: add 'to' after 'fromto'
    public function render_page($args)
    {
        $rc = rcmail::get_instance();
        $cols = $rc->output->get_env('listcols_widescreen');
        if (is_array($cols) && !in_array('to', $cols)) {
            $i = array_search('fromto', $cols);
            array_splice($cols, $i === false ? count($cols) : $i + 1, 0, ['to']);
            $rc->output->set_env('listcols_widescreen', $cols);
        }
        return $args;
    }

    public function storage_init($args)
    {
        $args['fetch_headers'] = trim(($args['fetch_headers'] ?? '') . ' DELIVERED-TO X-ORIGINAL-TO');
        return $args;
    }

    // server side: send the To column (as delivered-to), unless the smart From/To column is already To
    public function messages_list($args)
    {
        if (rcmail_action_mail_index::message_list_smart_column_name() == 'to') {
            return $args;
        }
        if (!in_array('to', $args['cols'])) {
            $args['cols'][] = 'to';
        }
        foreach ((array) $args['messages'] as $header) {
            if (!is_object($header)) {
                continue;
            }
            $addr = null;
            foreach (['delivered-to', 'x-original-to'] as $h) {
                $v = $header->others[$h] ?? null;   // repeated headers: array, top first
                if (!empty($v)) {
                    $v = is_array($v) ? end($v) : $v;
                    if (preg_match('/[^\s<>"]+@[^\s<>"]+/', (string) $v, $m)) {
                        $addr = strtolower($m[0]);
                        break;
                    }
                }
            }
            if ($addr) {
                $header->list_cols = array_merge((array) ($header->list_cols ?? []), ['to' => rcube::Q($addr)]);
            }
        }
        return $args;
    }
}
