// elastic_compact: drag bar between message list (top) and preview (bottom) for the compact skin.
if (window.rcmail) {
    rcmail.addEventListener('init', function () {
        var list = $('#layout-list');
        if (rcmail.env.task != 'mail' || rcmail.env.action || !list.length) {
            return;
        }
        // message row template: put a 'to' cell right after 'fromto'
        $.each(rcmail.env.widescreen_list_template || [], function () {
            var i = this.cells ? $.inArray('fromto', this.cells) : -1;
            if (i >= 0 && $.inArray('to', this.cells) < 0) {
                this.cells.splice(i + 1, 0, 'to');
            }
        });
        var key = 'elastic_compact.list_height',
            clamp = function (h) { return Math.max(80, Math.min(window.innerHeight - 80, h)); },
            saved = parseInt(rcmail.local_storage_get_item(key), 10);
        if (saved > 0) {
            list.css('height', clamp(saved));
        }
        $('<div class="ec-row-resizer" title="Drag to resize; double-click to reset">')
            .appendTo(list)
            .on('dblclick', function () {
                list.css('height', '');
                rcmail.local_storage_set_item(key, '');
            })
            .on('mousedown', function (e) {
                if (e.which != 1) return;
                e.preventDefault();
                var top = list.offset().top,
                    // overlay keeps mouse events away from the preview iframe while dragging
                    overlay = $('<div class="ec-resize-overlay">').appendTo(document.body);
                $(document)
                    .on('mousemove.elasticcompact', function (e) {
                        list.css('height', clamp(e.pageY - top));
                    })
                    .on('mouseup.elasticcompact', function () {
                        $(document).off('.elasticcompact');
                        overlay.remove();
                        rcmail.local_storage_set_item(key, Math.round(list.outerHeight()));
                    });
            });
    });
}
