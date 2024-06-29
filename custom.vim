" my filetype file
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    au! BufRead,BufNewFile *.arshrc       setfiletype sh
augroup END

# starlark files (Kurtosis scripts)
autocmd FileType *.star setlocal filetype=python

