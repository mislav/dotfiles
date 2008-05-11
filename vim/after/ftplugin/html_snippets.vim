if !exists('loaded_snippet') || &cp
    finish
endif

function! Onload()
    let st = g:snip_start_tag
    let et = g:snip_end_tag
    return 'onload="'.st.et.'"'
endfunction

function! Id()
    let st = g:snip_start_tag
    let et = g:snip_end_tag
    return ' id="'.st.et.'"'
endfunction

function! Cellspacing()
    let st = g:snip_start_tag
    let et = g:snip_end_tag
    let cd = g:snip_elem_delim
    return ' cellspacing="'.st.cd."D('5')".et.'"'
endfunction

function! FileNoExt()
    return substitute(expand('%'), '\(.*\)\..*$', '\1','')
endfunction

function! Target()
    let st = g:snip_start_tag
    let et = g:snip_end_tag
    return ' target="'.st.et.'"'
endfunction

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet doctype <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"<CR><TAB>\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\"><CR>".st.et
exec "Snippet doc4s <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"<CR>\"http://www.w3.org/TR/html4/strict.dtd\"><CR>".st.et
exec "Snippet doc4t <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"<CR>\"http://www.w3.org/TR/html4/loose.dtd\"><CR>".st.et
exec "Snippet doc4f <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\"<CR>\"http://www.w3.org/TR/html4/frameset.dtd\"><CR>".st.et
exec "Snippet docxs <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Strict//EN\"<CR>\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><CR>".st.et
exec "Snippet docxt <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Transitional//EN\"<CR>\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><CR>".st.et
exec "Snippet docxf <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Frameset//EN\"<CR>\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\"><CR>".st.et
exec "Snippet head <head><CR><TAB><meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\" /><CR><TAB><title>".st.":substitute(expand('%'),'\\(.*\\)\\..*$','\\1','')".et."</title><CR><TAB>".st.et."<CR></head><CR>".st.et
exec "Snippet script <script type=\"text/javascript\" language=\"javascript\" charset=\"utf-8\"><CR>// <![CDATA[<CR><TAB>".st.et."<CR>// ]]><CR></script><CR>".st.et
exec "Snippet title <title>".st.":substitute(expand('%'),'\\(.*\\)\\..*$','\\1','')".et."</title>"
exec "Snippet body <body id=\"".st.":FileNoExt()".et."\" ".st.":Onload()".et."<CR>".st.et."<CR></body><CR>".st.et
exec "Snippet scriptsrc <script src=\"".st.et."\" type=\"text/javascript\" language=\"".st.":D('javascript')".et."\" charset=\"".st.":D('utf-8')".et."\"></script><CR>".st.et
exec "Snippet textarea <textarea name=\"".st.":D('Name')".et."\" rows=\"".st.":D('8')".et."\" cols=\"".st.":D'(40')".et."\">".st.et."</textarea><CR>".st.et
exec "Snippet meta <meta name=\"".st.":D('name')".et."\" content=\"".st.":D('content')".et."\" /><CR>".st.et
exec "Snippet movie <object width=\"".st.et."\" height=\"".st.et."\"<CR>classid=\"clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B\"<CR>codebase=\"http://www.apple.com/qtactivex/qtplugin.cab\"><CR><Tab><param name=\"src\"<CR>value=\"".st.et."\" /><CR><Tab><param name=\"controller\" value=\"".st.et."\" /><CR><param name=\"autoplay\" value=\"".st.et."\" /><CR><Tab><embed src=\"".st.":D('movie.mov')".et."\"<CR><Tab>width=\"".st.":D('320')".et."\" height=\"".st."D('240')".et."\"<CR><Tab>controller=\"".st.":D('true')".et."\" autoplay=\"".st.":D('true')".et."\"<CR><Tab><Tab>scale=\"tofit\" cache=\"true\"<CR><Tab><Tab>pluginspage=\"http://www.apple.com/quicktime/download/\"<CR><Tab>/><CR></object><CR>".st.et
exec "Snippet div <div".st.":Id()".et."><CR>".st.et."<CR></div><CR>".st.et
exec "Snippet mailto <a href=\"mailto:".st.et."?subject=".st.":D('feedback')".et."\">".st.":D('email me')".et."</a>".st.et
exec "Snippet table <table border=\"".st.":D('0')".et."\"".st.":Cellspacing()".et." cellpadding=\"".st.":D('5')".et."\"><CR><Tab><tr><th><:D('Header')".et."</th></tr><CR><Tab><tr><td>".st.et."</td></tr><CR></table>"
exec "Snippet link <link rel=\"".st.":D('stylesheet')".et."\" href=\"".st.":D('/css/master.css')".et."\" type=\"text/css\" media=\"".st.":D('screen')".et."\" title=\"".st.et."\" charset=\"".st.":D('utf-8')".et."\" />"
exec "Snippet form <form action=\"".st.":D(FileNoExt().'_submit')".et."\" method=\"".st.":D('get')".et."\"><CR><Tab>".st.et."<CR><CR><Tab><p><input type=\"submit\" value=\"Continue &rarr;\" /></p><CR></form><CR>".st.et
exec "Snippet ref <a href=\"".st.et."\">".st.et."</a>".st.et
exec "Snippet h1 <h1 id=\"".st.et."\">".st.et."</h1>".st.et
exec "Snippet input <input type=\"".st.":D('text/submit/hidden/button')".et."\" name=\"".st.et."\" value=\"".st.et."\" ".st.et."/>".st.et
exec "Snippet style <style type=\"text/css\" media=\"screen\"><CR>/* <![CDATA[ */<CR><Tab>".st.et."<CR>/* ]]> */<CR></style><CR>".st.et
exec "Snippet base <base href=\"".st.et."\"".st.":Target()".et." />".st.et
