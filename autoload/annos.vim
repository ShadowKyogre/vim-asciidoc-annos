function! annos#IsVisualAlreadyWrapped()
	redir => search_output
		silent exe 's#' . "\\(\\%<'<<<\\|<\\%>'<<\\)\\_[^><]*\\(\\%<'<[^><]*>>\\)\\@!\\_[^><]*>>" . '##ne'
	redir END

	redir => ends_of_anno
		silent exe 's#' . "\\%>'<>>\\%<'>\\|\\%>'<<<\\%<'>" . '##ne'
	redir END

	if search_output =~ '1 match on 1 line'
		return 1
	else
		return 0
	endif
endfunction

function! annos#ShortGenID()
	let res = systemlist("uuidgen|sha256sum|grep -o '^.\\{9\\}'")[0]
	return "anno-" . res
endfunction

function! annos#WrapWordAnno()
	normal! gE
	let id = annos#ShortGenID()
	let pos = getpos('.')[1:2]
	if pos == [1, 1]
		keepjumps exe "normal! i<<" . id . ", \<Esc>Ei\<Right>>>"
	else
		keepjumps exe "normal! Wi<<" . id . ", \<Esc>Ei\<Right>>>"
	endif
	call annos#OpenAnnos()
	call annos#CreateAnno(id)
endfunction

function! annos#WrapVisualAnno()
	" if IsVisualAlreadyWrapped()
	" 	return
	" endif
	let id = annos#ShortGenID()
	let visualend = getpos("'>")[1:2]
	exe 'normal! $'
	let checkend = getpos('.')[1:2]
	if visualend[1]-1 == checkend[1]
		keepjumps exe "normal! `>i\<Right>>>\<Esc>`<Bi<<" . id .", \<Esc>"
	else
		exe "normal! `>E"
		let recheckend = getpos('.')[1:2]
		if recheckend[1] == checkend[1]
			keepjumps exe "normal! i\<Right>>>\<Esc>`<Bi<<" . id . ", \<Esc>"
		else
			keepjumps exe "normal! li>>\<Esc>`<Bi<<" . id . ", \<Esc>"
		endif
	endif
	call annos#OpenAnnos()
	call annos#CreateAnno(id)
endfunction

function! annos#AnnosFname()
	return fnameescape(substitute(expand("%:p"), '\.adoc$', '.comments.adoc', ""))
endfunction

function! annos#AnnosForFname()
	return fnameescape(substitute(expand("%:p"), '\.comments.adoc$', '.adoc', ""))
endfunction

function! annos#OpenAnnosFor()
	let annosf = annos#AnnosForFname()
	let annobufsid = bufnr(annosf)
	if annobufsid != -1
		let annoswinnr = bufwinnr(annobufsid) 
		if annoswinnr != -1
			exe annoswinnr . 'wincmd w'
		else
			exe 'aboveleft vertical vsp ' . annosf
		endif
	else
		exe 'aboveleft vertical vsp ' . annosf
	endif
endfunction

function! annos#OpenAnnos()
	let annosf = annos#AnnosFname()
	let annobufsid = bufnr(annosf)
	if annobufsid != -1
		let annoswinnr = bufwinnr(annobufsid) 
		if annoswinnr != -1
			exe annoswinnr . 'wincmd w'
		else
			exe 'belowright vertical vsp ' . annosf
		endif
	else
		exe 'belowright vertical vsp ' . annosf
	endif
endfunction

function! annos#CreateAnno(id)
	let lastline = getpos("$")[1]
	if lastline == 1
		let isempty = empty(getline(1))
		call append(0, ['[[' . a:id . ']]' , '****', 'Fill me in', '', '****'])
		if isempty
			normal! Gdd
		endif
	else
		call append(lastline, ['', '[[' . a:id . ']]', '****' , 'Fill me in', '', '****'])
	endif
endfunction

function! annos#GoToAnno(id)
	call annos#OpenAnnos()
	call search('^\[\[' . a:id . '\]\]$', 'cw')
endfunction

function! annos#GoToAnnoContext(id)
	call annos#OpenAnnosFor()
	call search('<<' . a:id . ',', 'cw')
endfunction

function! annos#GoToCurrentAnno()
	"let id = expand('<cWORD>')
	let anno_start = searchpos('<<anno-[a-f0-9]\{9\}', 'bcnW')
	let curpos = getpos('.')[1:2]
	let anno_end = searchpos('>>', 'cnW')
	let prev_anno_end = searchpos('>>', 'bcnW')

	if anno_start != [0, 0] && anno_end != [0, 0]
		let in_or_beyond_start = (anno_start == curpos) 
		\ || (anno_start[0] < curpos[0])
		\ || (anno_start[0] == curpos[0] && anno_start[1] <= curpos[1])
		let in_or_before_end = (anno_end == curpos) 
		\ || (anno_end[0] > curpos[0])
		\ || (anno_end[0] == curpos[0] && anno_end[1] >= curpos[1])

		if prev_anno_end != [0, 0]
			let false_alarm = (anno_start[0] == prev_anno_end[0] 
			\ && prev_anno_end[1] > anno_start[1])
			\ || prev_anno_end[0] > anno_start[0]
		else
			let false_alarm = 0
		endif

		if in_or_beyond_start && in_or_before_end && !false_alarm
			call annos#GoToAnno(getline(anno_start[0])[anno_start[1]+1:anno_start[1]+14])
		endif
	endif

	"if id =~ '<<anno-[a-f0-9]\{9\},'
	"	call annos#GoToAnno(id[2:-2])
	"endif
endfunction

function! annos#GoToCurrentAnnoContext()
	let lineno = search('^\[\[anno-[a-f0-9]\{9\}\]\]$', 'cnb')
	if lineno > 0
		let id = matchstr(getline(lineno), '^\[\[\zsanno-[a-z0-9]\{9\}\ze\]\]$')
		call annos#GoToAnnoContext(id)
	endif
endfunction
