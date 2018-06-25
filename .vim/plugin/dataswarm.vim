function! DataswarmHeader(user)
  normal gg
  normal Ofrom dataswarm.operators import GlobalDefaults, HiveQLOperator, Hive2FileOperator
  normal o
  normal oGlobalDefaults.set(
  normal o    user='
  let @d = a:user
  normal "dp
  normal a',
  normal oschedule='@never',
  normal odepends_on_past=False,
  normal opool='namespace.lowpri_adhoc'
  normal o
  normal 0Di)
endfunction

function! DataswarmHiveQLOperator()
  normal a = HiveQLOperator(
  normal o    dep_list=[],
  normal ohive_query="""
  normal o"""
  normal o
  normal 0Di)
endfunction

function! DataswarmHive2FileOperator()
  normal a = Hive2FileOperator(
  normal o    dep_list=[],
  normal ofilepath='<TMP_FILE_DS:>',
  normal ohive_query="""
  normal o"""
  normal o
  normal 0Di)
endfunction

function! GetCurrentNamespace()
  let file_path = expand('%:p')
  let split_path = reverse(split(file_path, "/"))
  let last_piece = ""
  for piece in split_path
    if match(piece, "^tasks.*$") > -1
      let namespace = last_piece
      break
    endif
    let last_piece = piece
  endfor
  return namespace
endfunction

function! Presto(cmd)
  let namespace = GetCurrentNamespace()
  :let path = 'presto ' . namespace
  execute('new')
  execute('r!' . path .' --execute "' . a:cmd . '"')
  :set nomodified
endfunction

function! PrestoShowPartitions(table)
  call Presto('show partitions from ' . a:table)
endfunction

function! PrestoShowPartitionsWord()
  normal "dyaw
  call PrestoShowPartitions(@d)
endfunction

function! PrestoDescribe(table)
  call Presto('describe ' . a:table)
endfunction

function! PrestoDescribeWord()
  normal "dyaw
  call PrestoDescribe(@d)
endfunction

function! RunDataswarmTask()
  normal "dyaw
  let dateid=input('Enter <DATEID>: ')
  let path = expand('%:p')
  let stripped = substitute(path, '^.*dataswarm\(-git\)\?/tasks', '', '')
  let module = substitute(substitute(stripped, '/', '.', 'g'), '.py$', '', '')
  let suffix = substitute(module, '\..*$', '', '')
  let module = substitute(module, '^[^\.]*\.', '', '')
  execute('!./tester -c dataswarm' . suffix . ' ' . module . '.' . @d . ' ' . dateid)
endfunction

function! ExpandDataswarmMacro()
  normal F<"dyf>
  let inner = substitute(@d, '[<>]', '', 'g')
  let first = substitute(inner, ':.*$', '', '')
  let second = substitute(inner, '^.*:', '', '')
  if first == 'TMP_TABLE'
    echo 'tmp_' . $USER . '_' . second
  elseif first == 'TMP_FILE_DS'
    let dateid=input('Enter <DATEID>: ')
    echo '/mnt/vol/dataswarm/tmp/' . second . '.' . dateid
  else
    echo @d
  endif
endfunction

function! MakeCreateTableStatement()
  " Get table name
  normal "dyaw
  " Get schema from presto
  let schema = GetTableSchema(@d)
  if schema =~# 'does not exist' || schema =~# 'no viable alternative'
    echo 'There is no table ' . @d . ' in the current namespace'
    return
  endif

  " Make create table statement
  let create_statement = GetCreateTableList(@d, schema)

  " Make room to paste the statement
  normal O
  normal O
  " Paste the statement
  call append(line('.'), create_statement)

  " Indent entire statement two times as this will generally be how much
  " indentation the create statement has in dataswarm
  execute ":normal! V}2>"
  " Indent the body of the statement one more time, use search to handle
  " cases when there is or isn't a partition
  execute ":normal! 2jV/)\<CR>k>\<CR>{"
endfunction

function! GetCreateTableList(table_name, schema)
  let first_line = 'CREATE TABLE IF NOT EXISTS <TABLE:' . a:table_name . '> ('
  let create_statement = [first_line]
  let partition_cols = []
  let split_schema = split(a:schema, '\n')
  " Remove first line about Presto connecting
  call remove(split_schema, 0)
  for line in split_schema
    " Lines should begin with a ", otherwise it is a multiline comment
    if strpart(line, 0, 1) !=# '"'
      continue
    endif
    let line = substitute(line, '^"', '', 'g')
    let line = substitute(line, '"$', '', 'g')
    let line_split = split(line, '","')
    " This is not a valid line
    if len(line_split) < 4
      continue
    endif
    let partition_column = line_split[3]
    if partition_column ==# 'true'
      call add(partition_cols, line_split)
    else
      let field_type = GetFieldType(line_split[1])
      call add(create_statement, line_split[0] . ' ' . field_type . ',')
    endif
  endfor
  let create_statement[-1] = substitute(create_statement[-1], ',$', '', '')
  call add(create_statement, ')')

  " Partition column
  if len(partition_cols) > 0
    let partition_line = 'PARTITIONED BY ('
    for partition_col in partition_cols
      let partition_type = GetFieldType(partition_col[1])
      let partition_line = partition_line . partition_col[0] . ' ' . partition_type . ','
    endfor
    let partition_line = substitute(partition_line, ',$', '', '')
    let partition_line = partition_line . ')'
    call add(create_statement, partition_line)
  endif
  call add(create_statement, "TBLPROPERTIES('RETENTION'='30');")

  return create_statement
endfunction

" Given a table name, query presto and return the schema
function! GetTableSchema(table_name)
  let namespace = GetCurrentNamespace()
  let describe_cmd = 'presto ' . namespace . ' --execute "describe '
  let describe_cmd = describe_cmd . a:table_name . '"'
  let schema = system(describe_cmd)
  return schema
endfunction

" Map presto types to Hive types
function! GetFieldType(field_type)
  if a:field_type ==# "varchar"
    return "STRING"
  else
    return toupper(a:field_type)
  endif
endfunction

map <Leader>ds :call DataswarmHeader($USER)<CR>
map <Leader>hql :call DataswarmHiveQLOperator()<CR>
map <Leader>h2f :call DataswarmHive2FileOperator()<CR>

map <Leader>dr :call RunDataswarmTask()<CR>
map <Leader>pd :call PrestoDescribeWord()<CR>
map <Leader>ym F<yf>
map <Leader>em :call ExpandDataswarmMacro()<CR>
map <Leader>pp :call PrestoShowPartitionsWord()<CR>
nnoremap <leader>ct :call MakeCreateTableStatement()<CR>
