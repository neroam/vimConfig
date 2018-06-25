" put in $HOME/.vim/after/syntax/python.vim
if exists('b:current_syntax')
  let s:current_syntax=b:current_syntax
  unlet b:current_syntax
endif
syn include @SQLSyntax syntax/hql.vim
if exists('s:current_syntax')
  let b:current_syntax=s:current_syntax
endif

syn region hqlRegion contains=@SQLSyntax
  \ matchgroup=hqlDelim
  \ start=+\(hive_query\|hql\|hive_setup\) *= *r\="""+
  \ end=+"""+
  \ keepend
