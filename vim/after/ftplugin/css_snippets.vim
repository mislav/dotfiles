if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet visibility ".st.":D('visible/hidden/collapse')".et.";".st.et
exec "Snippet list list-style-image: url(".st.et.");".st.et
exec "Snippet text text-shadow: rgb(".st.":D('255')".et.", ".st.":D('255')".et.", ".st.":D('255')".et.", ".st.":D('10px')".et." ".st.":D('10px')".et." ".st.":D('2px')".et.";".st.et." "
exec "Snippet overflow overflow: ".st.":D('visible/hidden/scroll/auto')".et.";".st.et
exec "Snippet white white-space: ".st.":D('normal/pre/nowrap')".et.";".st.et
exec "Snippet clear cursor: url(".st.et.");".st.et
exec "Snippet margin padding-top: ".st.":D('20px')".et.";".st.et
exec "Snippet background background #".st.":D('DDD')".et." url(".st.et.") ".st.":D('repeat/repeat-x/repeat-y/no-repeat')".et." ".st.":D('scroll/fixed')".et." top left/top center/top right/center left/center center/center right/bottom left/bottom center/bottom right/x% y%/x-pos y-pos')".et.";".st.et
exec "Snippet word word-spaceing: ".st.":D('10px')".et.";".st.et
exec "Snippet z z-index: ".st.et.";".st.et
exec "Snippet vertical vertical-align: ".st.":D('baseline/sub/super/top/text-top/middle/bottom/text-bottom/length/%')".et.";".st.et
exec "Snippet marker marker-offset: ".st.":D('10px')".et.";".st.et
exec "Snippet cursor cursor: ".st.":D('default/auto/crosshair/pointer/move/*-resize/text/wait/help')".et.";".st.et
exec "Snippet border border-right: ".st.":D('1')".et."px ".st.":D('solid')".et." #".st.":D('999')".et.";".st.et
exec "Snippet display display: block;".st.et
exec "Snippet padding padding: ".st.":D('20px')".et." ".st.":D('0px')".et.";".st.et
exec "Snippet letter letter-spacing: ".st.et."em;".st.et
exec "Snippet color color: rgb(".st.":D('255')".et.", ".st.":D('255')".et.", ".st.":D('255')".et.");".st.et
exec "Snippet font font-weight: ".st.":D('normal/bold')".et.";".st.et
exec "Snippet position position: ".st.":D('static/relative/absolute/fixed')".et.";".st.et
exec "Snippet direction direction: ".st.":D('ltr|rtl')".et.";".st.et
exec "Snippet float float: ".st.":D('left/right/none')".et.";".st.et
