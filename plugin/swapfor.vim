" SwapFor.vim - Swap a current buffer for specified file
" Copyright (C) Retorillo <http://github.com/retorillo/> 
" Distributed under the terms of the Vim license

" Usage:
" :SwapFor[!] {path}

command! -nargs=1 -complete=file -bang SwapFor :call SwapFor("<args>", "<bang>")

function! SwapFor(path, bang)
	let l:readonly = &readonly
	let l:modified = &modified
	let l:src  = expand("%:p")
	if l:readonly
		echoerr "Current buffer is readonly."
		return
	endif
	if l:src == ""
		echoerr "Current buffer is unsaved. Must save as a file before this command."
		return
	endif
	if a:path == ""
		echoerr "Path is not specified."
		return
	endif
	if a:bang == "" && l:modified == 1
		echoerr "Current buffer is unsaved. Add ! to discard changes and continue swap."
		return
	endif
	let l:dest = fnamemodify(expand(a:path), ":p")
	if l:src == l:dest
		echoerr "Cannnot swap file between the same pathes: " . l:src
		return
	endif
	
	if isdirectory(l:dest) == 1
		echoerr "'" . l:dest . " is directory"
		return
	endif

	if filereadable(l:dest) == 0
		if confirm("'" . l:dest . "' is not found. Want to create empty file and swap by it?", "&Yes\n&Abort") == 2
			return
		endif 
		if writefile([], l:dest) == -1
			echoerr "Cannot create empty file: " . l:dest
			return
		endif
	endif

	let l:dlines = readfile(l:dest)
	let l:slines = readfile(l:src)
	
	if filewritable(l:dest) == 1 && writefile(l:slines, l:dest) == -1
		echoerr "Cannnot write to: " . l:dest
		return
	endif

	%d	
	call append(0, l:dlines)
	silent w
	0
	echo "'" . fnamemodify(l:src, ":t") . "' is swapped for '" . fnamemodify(l:dest, ":t") . "'"
endfunction

