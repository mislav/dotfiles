"
" Normal HTML text has no synID-name. So we have to specify this problem
" case here. Note that you should not try to comment lines starting
" with '<?'.
"
call EnhCommentifyFallback4Embedded('&ft == "php" && synFiletype == ""', "html")
