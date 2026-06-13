" gitgrep.vim - Lightweight git grep with multi-scope search
" Drop into ~/.vim/plugin/gitgrep.vim
" Keybindings:
"   \gg  - git tracked files only
"   \gb  - git tracked + build folder
"   \gl  - git tracked + build folder + external headers

if exists('g:loaded_gitgrep')
  finish
endif
let g:loaded_gitgrep = 1

" ============================================================
" CONFIG BLOCK - Edit these for your environment
" ============================================================

" Path to build folder, relative to git repo root
let g:gitgrep_build_dir = 'build'

" Windows: specific external library include directories (stable paths)
" Add or remove entries as needed
let g:gitgrep_win_extra_includes = [
  \ 'C:\libs\somelib\include',
  \ 'C:\libs\anotherlib\include',
  \ ]

" ============================================================
" END CONFIG BLOCK
" ============================================================


" --- OS Detection -------------------------------------------

function! s:GetOS() abort
  if has('win32') || has('win64')
    return 'windows'
  endif
  let uname = system('uname -r')
  if uname =~? 'el7'
    return 'rhel7'
  elseif uname =~? 'el8\|el9'
    return 'rhel9'
  endif
  return 'linux'
endfunction


" --- Git repo root detection --------------------------------

function! s:GitRoot() abort
  let root = system('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel 2>/dev/null')
  return substitute(root, '\n\+$', '', '')
endfunction


" --- Build external include paths by OS ---------------------

function! s:ExternalIncludes() abort
  let os = s:GetOS()
  let paths = []

  if os ==# 'windows'
    " VS paths via environment variables
    let vsdir = exists('$VSINSTALLDIR') ? $VSINSTALLDIR : ''
    let vctools = exists('$VCToolsInstallDir') ? $VCToolsInstallDir : ''
    if !empty(vsdir)
      call add(paths, vsdir . 'VC\Tools\MSVC\include')
    endif
    if !empty(vctools)
      call add(paths, vctools . 'include')
    endif
    " Stable install directories from config block
    call extend(paths, g:gitgrep_win_extra_includes)

  elseif os ==# 'rhel7'
    call extend(paths, [
      \ '/usr/include',
      \ '/usr/local/include',
      \ '/usr/include/c++',
      \ ])

  else
    " rhel9 and generic linux
    call extend(paths, [
      \ '/usr/include',
      \ '/usr/local/include',
      \ '/usr/include/c++',
      \ '/usr/include/x86_64-linux-gnu',
      \ ])
  endif

  return paths
endfunction


" --- Core grep function -------------------------------------
"
" a:scopes is a list containing any of: 'git', 'build', 'external'
" Results from all scopes are merged into a single quickfix list.

function! s:GitGrep(scopes) abort
  let word = expand('<cword>')
  if empty(word)
    echohl WarningMsg | echo 'gitgrep: no word under cursor' | echohl NONE
    return
  endif

  let git_root = s:GitRoot()
  if empty(git_root)
    echohl WarningMsg | echo 'gitgrep: not inside a git repository' | echohl NONE
    return
  endif

  let results = []

  " --- Scope 1: git tracked files ---
  if index(a:scopes, 'git') >= 0
    let raw = system(
      \ 'git -C ' . shellescape(git_root) .
      \ ' grep -n ' . shellescape(word) .
      \ ' 2>/dev/null')
    for line in split(raw, '\n')
      " git grep output: filename:lineno:text
      " Prefix with git root so paths are absolute
      if line =~# '^.\+:\d\+:'
        call add(results, git_root . '/' . line)
      endif
    endfor
  endif

  " --- Scope 2: build folder (untracked generated files) ---
  if index(a:scopes, 'build') >= 0
    let build_path = git_root . '/' . g:gitgrep_build_dir
    if isdirectory(build_path)
      let grep_cmd = s:GrepCommand(word, build_path)
      let raw = system(grep_cmd . ' 2>/dev/null')
      call extend(results, split(raw, '\n'))
    else
      echohl WarningMsg
      echo 'gitgrep: build dir not found: ' . build_path
      echohl NONE
    endif
  endif

  " --- Scope 3: external library headers ---
  if index(a:scopes, 'external') >= 0
    for inc_path in s:ExternalIncludes()
      if isdirectory(inc_path)
        let grep_cmd = s:GrepCommand(word, inc_path)
        let raw = system(grep_cmd . ' 2>/dev/null')
        call extend(results, split(raw, '\n'))
      endif
    endfor
  endif

  " --- Populate quickfix and open window ---
  if empty(results)
    echohl WarningMsg | echo 'gitgrep: no results for "' . word . '"' | echohl NONE
    return
  endif

  " cgetexpr expects errorformat-compatible lines (file:line:text)
  " grep -n produces exactly this; git grep needs the root prefix we added above
  call setqflist([], ' ', {
    \ 'title': 'gitgrep: ' . word,
    \ 'lines': results,
    \ 'efm': '%f:%l:%m'
    \ })
  " Move to top of screen, open quickfix at 30 lines, keep focus there
  wincmd t
  copen 30
  wincmd K
endfunction


" --- Platform-aware grep command for filesystem paths -------

function! s:GrepCommand(word, path) abort
  if has('win32') || has('win64')
    " findstr on Windows: /s recursive, /n line numbers, /c: literal string
    return 'findstr /s /n /c:' . shellescape(a:word) .
      \ ' "' . a:path . '\*.h"' .
      \ ' "' . a:path . '\*.hpp"' .
      \ ' "' . a:path . '\*.cpp"'
  else
    return 'grep -rn --include="*.h" --include="*.hpp" --include="*.cpp"' .
      \ ' ' . shellescape(a:word) .
      \ ' ' . shellescape(a:path)
  endif
endfunction


" --- Quickfix behaviour -------------------------------------

autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>

" --- Keybindings --------------------------------------------

" --- Keybindings --------------------------------------------

" \gg  git tracked files only
nnoremap <Leader>gg :call <SID>GitGrep(['git'])<CR>

" \gb  git tracked + build folder
nnoremap <Leader>gb :call <SID>GitGrep(['git', 'build'])<CR>

" \gl  git tracked + build folder + external headers
nnoremap <Leader>gl :call <SID>GitGrep(['git', 'build', 'external'])<CR>