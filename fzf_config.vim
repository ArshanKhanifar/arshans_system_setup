" fzf / ripgrep / tags configuration (loaded after plug.vim)

let g:fzf_vim = {}

let s:tagit_cmd = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/bin/tagit'
let g:arshan_ctags_command = s:tagit_cmd
let g:fzf_vim.tags_command = s:tagit_cmd

" Rg with lockfile noise filtered (overrides fzf.vim default)
command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case'
      \ . ' -g "!{*.lock,*-lock.json}" -- '
      \ . fzf#shellescape(<q-args>),
      \   fzf#vim#with_preview(), <bang>0)

" ---------------------------------------------------------------------------
" Async tag generation via bin/tagit (gitignore-aware)
" ---------------------------------------------------------------------------
let s:ctags_pending_open = 0
let s:ctags_running = 0

function! s:ctags_job_exit(job, status)
  let s:ctags_running = 0
  if a:status == 0
    echom 'Tags ready.'
    if s:ctags_pending_open
      let s:ctags_pending_open = 0
      call fzf#vim#tags('')
    endif
  else
    echomsg 'tagit failed (exit ' . a:status . ')'
    let s:ctags_pending_open = 0
  endif
endfunction

function! s:start_ctags_async(open_when_done)
  if s:ctags_running
    echom 'tagit already running…'
    return
  endif
  if !filereadable(g:arshan_ctags_command) && !executable('tagit') && !executable('ctags')
    echomsg 'tagit/ctags not found (install universal-ctags)'
    return
  endif
  let s:ctags_pending_open = a:open_when_done
  let s:ctags_running = 1
  echom 'Generating tags in background (keep working)…'
  let l:cmd = filereadable(g:arshan_ctags_command)
        \ ? g:arshan_ctags_command
        \ : (executable('tagit') ? 'tagit' : 'ctags -R')
  let l:job = job_start(['/bin/sh', '-c', l:cmd], {
        \ 'exit_cb': function('s:ctags_job_exit'),
        \ 'out_mode': 'raw',
        \ 'err_mode': 'raw',
        \ })
  if l:job <= 0
    let s:ctags_running = 0
    echomsg 'Could not start background tagit job; running synchronously…'
    call system(l:cmd)
    if empty(tagfiles())
      echomsg 'tagit failed'
      return
    endif
    echom 'Tags ready.'
    if a:open_when_done
      call fzf#vim#tags('')
    endif
  endif
endfunction

" ,r — prompt once, generate tags without blocking vim, then open picker
function! s:tags()
  if !empty(tagfiles())
    call fzf#vim#tags('')
    return
  endif
  echohl WarningMsg
  let l:gen = input('tags not found. Generate in background? (y/N) ')
  echohl None
  if l:gen !~? '^y'
    echom 'Skipped tag generation.'
    return
  endif
  call s:start_ctags_async(1)
endfunction

command! Tagit call s:start_ctags_async(0)
command! MakeTags Tagit

" ---------------------------------------------------------------------------
" Key maps
" ---------------------------------------------------------------------------
nmap <Leader>a :Rg!<CR>
nmap <Leader>r :call <SID>tags()<CR>

" Word under cursor (Alt-k in iTerm often sends Esc-k)
nmap <M-k>  :Rg! <C-R><C-W><CR>
nmap <Esc>k :Rg! <C-R><C-W><CR>
