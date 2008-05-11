" Plugin:       twitter.vim
" LastChange:   Apr 5, 2007
" Version:      0.1.1
" Author:       Amir Mohammad Saied <amirsaied AT gluegadget DOT com>
" License:      Public Domain
"
" Usage:
" Just put twitter.vim and twitter.py in your ~/.vim/plugin
" You have to set your twitters username/password
"   :let g:twitterusername="username"
"   :let g:twitterpassword="password"
"
"   And if you want to keep your user/pass pair forever, 
"   Simply put 'em in your ~/.vimrc
"
" type:
"   :TwitterUpdateStatus <status>   To update your status
"   :TwitterPublicTimeline          To get the public timeline
"   :TwitterFriendsTimeline         To get your friends timeline
"
" Changelog:
"  0.1.1
"   - BUGFIX: It's now possible to pass statuses containing ' (quotation)
"     (Thanks to Armen Baghumian)
"
"  0.1
"   - Supports:
"       Updating your status
"       Getting Public timeline
"       Getting your friends timeline
"
pyfile ~/.vim/plugin/twitter.py

if &compatible || v:version < 603
    finish
endif

if !exists("g:twitterusername")
    let g:twitterusername=""
endif

if !exists("g:twitterpassword")
    let g:twitterpassword=""
endif

command!    -nargs=1    TwitterStatusUpdate     python  StatusUpdate(<q-args>)
command!    -nargs=0    TwitterPublicTimeline   python  GetTimeline('public')
command!    -nargs=0    TwitterFriendsTimeline  python  GetTimeline('friends')
