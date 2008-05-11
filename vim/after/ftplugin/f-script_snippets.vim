if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet tbd to:".st.et." by:".st.et." do:[ ".st.":D(':i')".et." |<CR><Tab>".st.et."<CR>].".st.et
exec "Snippet it ifTrue:[<CR><Tab>".st.et."<CR>].".st.et
exec "Snippet ift ifFalse:[<CR><Tab>".st.et."<CR>] ifTrue:[<CR><Tab>".st.et."<CR>].".st.et
exec "Snippet itf ifTrue:[<CR><Tab>".st.et."<CR>] ifFalse:[<CR><Tab>".st.et."<CR>].".st.et
exec "Snippet td to:".st.et." do:[".st.et." ".st.":D(':i')".et." |<CR><Tab>".st.et."<CR>].".st.et
exec "Snippet if ifFalse:[<CR><Tab>".st.et."<CR>].".st.et
