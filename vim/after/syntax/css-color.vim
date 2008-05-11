" Language:	   Colored CSS Color Preview
" Maintainer:	Niklas Hofer <niklas+vim@lanpartei.de>
" URL:		   svn://lanpartei.de/vimrc/after/syntax/css.vim
" Last Change:	2008 Feb 12
" Licence:     No Warranties. Do whatever you want with this. But please tell me!
" Version:     0.6

function! s:FGforBG(bg)
   " takes a 6hex color code and returns a matching color that is visible
   let pure = substitute(a:bg,'^#','','')
   let r = eval('0x'.pure[0].pure[1])
   let g = eval('0x'.pure[2].pure[3])
   let b = eval('0x'.pure[4].pure[5])
   if r*30 + g*59 + b*11 > 12000
      return '#000000'
   else
      return '#ffffff'
   end
endfunction

function! s:SetMatcher(clr,pat)
   let group = 'cssColor'.substitute(a:clr,'^#','','')
   redir => s:currentmatch
      silent! exe 'syn list '.group
   redir END
   if s:currentmatch !~ a:pat.'\/'
      exe 'syn match '.group.' /'.a:pat.'\>/ contained'
      exe 'syn cluster cssColors add='.group
      exe 'hi '.group.' guifg='.s:FGforBG(a:clr)
      exe 'hi '.group.' guibg='.a:clr
      return 1
   else
      return 0
   endif
endfunction

function! s:SetNamedColor(clr,name)
   let group = 'cssColor'.substitute(a:clr,'^#','','')
   exe 'syn keyword '.group.' '.a:name.' contained'
   exe 'syn cluster cssColors add='.group
   exe 'hi '.group.' guifg='.s:FGforBG(a:clr)
   exe 'hi '.group.' guibg='.a:clr
   return 23
endfunction

function! s:PreviewCSSColorInLine(where)
   " TODO use cssColor matchdata
   let foundcolor = matchstr( getline(a:where), '#[0-9A-Fa-f]\{3,6\}\>' )
   let color = ''
   if foundcolor != ''
      if foundcolor =~ '#\x\{6}$'
         let color = foundcolor
      elseif foundcolor =~ '#\x\{3}$'
         let color = substitute(foundcolor, '\(\x\)\(\x\)\(\x\)', '\1\1\2\2\3\3', '')
      else
         let color = ''
      endif
      if color != ''
         return s:SetMatcher(color,foundcolor)
      else
         return 0
      endif
   else
      return 0
   endif
endfunction

if has("gui_running")
   " HACK modify cssDefinition to add @cssColors to its contains
   redir => s:olddef
      silent!  syn list cssDefinition
   redir END
   if s:olddef != ''
      let s:b = strridx(s:olddef,'matchgroup')
      if s:b != -1
         exe 'syn region cssDefinition '.strpart(s:olddef,s:b).',@cssColors'
      endif
   endif

   " w3c Colors
   let i = s:SetNamedColor('#800000', 'maroon')
   let i = s:SetNamedColor('#ff0000', 'red')
   let i = s:SetNamedColor('#ffA500', 'orange')
   let i = s:SetNamedColor('#ffff00', 'yellow')
   let i = s:SetNamedColor('#808000', 'olive')
   let i = s:SetNamedColor('#800080', 'purple')
   let i = s:SetNamedColor('#ff00ff', 'fuchsia')
   let i = s:SetNamedColor('#ffffff', 'white')
   let i = s:SetNamedColor('#00ff00', 'lime')
   let i = s:SetNamedColor('#008000', 'green')
   let i = s:SetNamedColor('#000080', 'navy')
   let i = s:SetNamedColor('#0000ff', 'blue')
   let i = s:SetNamedColor('#00ffff', 'aqua')
   let i = s:SetNamedColor('#008080', 'teal')
   let i = s:SetNamedColor('#000000', 'black')
   let i = s:SetNamedColor('#c0c0c0', 'silver')
   let i = s:SetNamedColor('#808080', 'gray')

   " extra colors
   let i = s:SetNamedColor('#F0F8FF','AliceBlue')
   let i = s:SetNamedColor('#FAEBD7','AntiqueWhite')
   let i = s:SetNamedColor('#7FFFD4','Aquamarine')
   let i = s:SetNamedColor('#F0FFFF','Azure')
   let i = s:SetNamedColor('#F5F5DC','Beige')
   let i = s:SetNamedColor('#FFE4C4','Bisque')
   let i = s:SetNamedColor('#FFEBCD','BlanchedAlmond')
   let i = s:SetNamedColor('#8A2BE2','BlueViolet')
   let i = s:SetNamedColor('#A52A2A','Brown')
   let i = s:SetNamedColor('#DEB887','BurlyWood')
   let i = s:SetNamedColor('#5F9EA0','CadetBlue')
   let i = s:SetNamedColor('#7FFF00','Chartreuse')
   let i = s:SetNamedColor('#D2691E','Chocolate')
   let i = s:SetNamedColor('#FF7F50','Coral')
   let i = s:SetNamedColor('#6495ED','CornflowerBlue')
   let i = s:SetNamedColor('#FFF8DC','Cornsilk')
   let i = s:SetNamedColor('#DC143C','Crimson')
   let i = s:SetNamedColor('#00FFFF','Cyan')
   let i = s:SetNamedColor('#00008B','DarkBlue')
   let i = s:SetNamedColor('#008B8B','DarkCyan')
   let i = s:SetNamedColor('#B8860B','DarkGoldenRod')
   let i = s:SetNamedColor('#A9A9A9','DarkGray')
   let i = s:SetNamedColor('#A9A9A9','DarkGrey')
   let i = s:SetNamedColor('#006400','DarkGreen')
   let i = s:SetNamedColor('#BDB76B','DarkKhaki')
   let i = s:SetNamedColor('#8B008B','DarkMagenta')
   let i = s:SetNamedColor('#556B2F','DarkOliveGreen')
   let i = s:SetNamedColor('#FF8C00','Darkorange')
   let i = s:SetNamedColor('#9932CC','DarkOrchid')
   let i = s:SetNamedColor('#8B0000','DarkRed')
   let i = s:SetNamedColor('#E9967A','DarkSalmon')
   let i = s:SetNamedColor('#8FBC8F','DarkSeaGreen')
   let i = s:SetNamedColor('#483D8B','DarkSlateBlue')
   let i = s:SetNamedColor('#2F4F4F','DarkSlateGray')
   let i = s:SetNamedColor('#2F4F4F','DarkSlateGrey')
   let i = s:SetNamedColor('#00CED1','DarkTurquoise')
   let i = s:SetNamedColor('#9400D3','DarkViolet')
   let i = s:SetNamedColor('#FF1493','DeepPink')
   let i = s:SetNamedColor('#00BFFF','DeepSkyBlue')
   let i = s:SetNamedColor('#696969','DimGray')
   let i = s:SetNamedColor('#696969','DimGrey')
   let i = s:SetNamedColor('#1E90FF','DodgerBlue')
   let i = s:SetNamedColor('#B22222','FireBrick')
   let i = s:SetNamedColor('#FFFAF0','FloralWhite')
   let i = s:SetNamedColor('#228B22','ForestGreen')
   let i = s:SetNamedColor('#DCDCDC','Gainsboro')
   let i = s:SetNamedColor('#F8F8FF','GhostWhite')
   let i = s:SetNamedColor('#FFD700','Gold')
   let i = s:SetNamedColor('#DAA520','GoldenRod')
   let i = s:SetNamedColor('#808080','Grey')
   let i = s:SetNamedColor('#ADFF2F','GreenYellow')
   let i = s:SetNamedColor('#F0FFF0','HoneyDew')
   let i = s:SetNamedColor('#FF69B4','HotPink')
   let i = s:SetNamedColor('#CD5C5C','IndianRed')
   let i = s:SetNamedColor('#4B0082','Indigo')
   let i = s:SetNamedColor('#FFFFF0','Ivory')
   let i = s:SetNamedColor('#F0E68C','Khaki')
   let i = s:SetNamedColor('#E6E6FA','Lavender')
   let i = s:SetNamedColor('#FFF0F5','LavenderBlush')
   let i = s:SetNamedColor('#7CFC00','LawnGreen')
   let i = s:SetNamedColor('#FFFACD','LemonChiffon')
   let i = s:SetNamedColor('#ADD8E6','LightBlue')
   let i = s:SetNamedColor('#F08080','LightCoral')
   let i = s:SetNamedColor('#E0FFFF','LightCyan')
   let i = s:SetNamedColor('#FAFAD2','LightGoldenRodYellow')
   let i = s:SetNamedColor('#D3D3D3','LightGray')
   let i = s:SetNamedColor('#D3D3D3','LightGrey')
   let i = s:SetNamedColor('#90EE90','LightGreen')
   let i = s:SetNamedColor('#FFB6C1','LightPink')
   let i = s:SetNamedColor('#FFA07A','LightSalmon')
   let i = s:SetNamedColor('#20B2AA','LightSeaGreen')
   let i = s:SetNamedColor('#87CEFA','LightSkyBlue')
   let i = s:SetNamedColor('#778899','LightSlateGray')
   let i = s:SetNamedColor('#778899','LightSlateGrey')
   let i = s:SetNamedColor('#B0C4DE','LightSteelBlue')
   let i = s:SetNamedColor('#FFFFE0','LightYellow')
   let i = s:SetNamedColor('#32CD32','LimeGreen')
   let i = s:SetNamedColor('#FAF0E6','Linen')
   let i = s:SetNamedColor('#FF00FF','Magenta')
   let i = s:SetNamedColor('#66CDAA','MediumAquaMarine')
   let i = s:SetNamedColor('#0000CD','MediumBlue')
   let i = s:SetNamedColor('#BA55D3','MediumOrchid')
   let i = s:SetNamedColor('#9370D8','MediumPurple')
   let i = s:SetNamedColor('#3CB371','MediumSeaGreen')
   let i = s:SetNamedColor('#7B68EE','MediumSlateBlue')
   let i = s:SetNamedColor('#00FA9A','MediumSpringGreen')
   let i = s:SetNamedColor('#48D1CC','MediumTurquoise')
   let i = s:SetNamedColor('#C71585','MediumVioletRed')
   let i = s:SetNamedColor('#191970','MidnightBlue')
   let i = s:SetNamedColor('#F5FFFA','MintCream')
   let i = s:SetNamedColor('#FFE4E1','MistyRose')
   let i = s:SetNamedColor('#FFE4B5','Moccasin')
   let i = s:SetNamedColor('#FFDEAD','NavajoWhite')
   let i = s:SetNamedColor('#FDF5E6','OldLace')
   let i = s:SetNamedColor('#6B8E23','OliveDrab')
   let i = s:SetNamedColor('#FF4500','OrangeRed')
   let i = s:SetNamedColor('#DA70D6','Orchid')
   let i = s:SetNamedColor('#EEE8AA','PaleGoldenRod')
   let i = s:SetNamedColor('#98FB98','PaleGreen')
   let i = s:SetNamedColor('#AFEEEE','PaleTurquoise')
   let i = s:SetNamedColor('#D87093','PaleVioletRed')
   let i = s:SetNamedColor('#FFEFD5','PapayaWhip')
   let i = s:SetNamedColor('#FFDAB9','PeachPuff')
   let i = s:SetNamedColor('#CD853F','Peru')
   let i = s:SetNamedColor('#FFC0CB','Pink')
   let i = s:SetNamedColor('#DDA0DD','Plum')
   let i = s:SetNamedColor('#B0E0E6','PowderBlue')
   let i = s:SetNamedColor('#BC8F8F','RosyBrown')
   let i = s:SetNamedColor('#4169E1','RoyalBlue')
   let i = s:SetNamedColor('#8B4513','SaddleBrown')
   let i = s:SetNamedColor('#FA8072','Salmon')
   let i = s:SetNamedColor('#F4A460','SandyBrown')
   let i = s:SetNamedColor('#2E8B57','SeaGreen')
   let i = s:SetNamedColor('#FFF5EE','SeaShell')
   let i = s:SetNamedColor('#A0522D','Sienna')
   let i = s:SetNamedColor('#87CEEB','SkyBlue')
   let i = s:SetNamedColor('#6A5ACD','SlateBlue')
   let i = s:SetNamedColor('#708090','SlateGray')
   let i = s:SetNamedColor('#708090','SlateGrey')
   let i = s:SetNamedColor('#FFFAFA','Snow')
   let i = s:SetNamedColor('#00FF7F','SpringGreen')
   let i = s:SetNamedColor('#4682B4','SteelBlue')
   let i = s:SetNamedColor('#D2B48C','Tan')
   let i = s:SetNamedColor('#D8BFD8','Thistle')
   let i = s:SetNamedColor('#FF6347','Tomato')
   let i = s:SetNamedColor('#40E0D0','Turquoise')
   let i = s:SetNamedColor('#EE82EE','Violet')
   let i = s:SetNamedColor('#F5DEB3','Wheat')
   let i = s:SetNamedColor('#F5F5F5','WhiteSmoke')
   let i = s:SetNamedColor('#9ACD32','YellowGreen')



   let i = 1
   while i <= line("$")
      call s:PreviewCSSColorInLine(i)
      let i = i+1
   endwhile
   unlet i

   autocmd CursorHold * silent call s:PreviewCSSColorInLine('.')
   autocmd CursorHoldI * silent call s:PreviewCSSColorInLine('.')
   set ut=100
endif		" has("gui_running")
