" Set color
colorscheme elflord

" Spaces instead of tabs, tab length
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

" Set numbers and relative number toggling
set number
command Rn set relativenumber!

" Ignore case in search and toggling Case Sensitivity
set ignorecase
set hlsearch
command Cs set ignorecase!

" Turn on spellchecking
set spelllang=en_us
command SC set spell!

" Development helpers, syntax, etc
set autoindent
set nowrap
syntax enable
set tags=tags;/ " Search for tags recursively up

" Set up wild menu and tab completion
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set path+=**

" Enable viewing man pages in vim without going to shell window
runtime ftplugin/man.vim
" Set keyword 'K' to uyse ":Man"
set keywordprg=:Man

" Comment/Uncomment  multiple Python lines at once
function! Compy() range
    execute a:firstline . "," . a:lastline . 's/^/# /'
endfunction

function! Uncompy() range
    execute a:firstline . "," . a:lastline . 's/^# \{0,1}//'
endfunction

" Comment multiple C lines at once
function! Comc() range
   execute a:firstline . "," . a:lastline . 's/^/\/\/ /'
endfunction
   
function! Uncomc() range
   execute a:firstline . "," . a:lastline . 's/^\/\/ \{0,1}//'
endfunction

" Function to freeze the top line of a file
function! FreezeTop()
    execute "1spl"
    set scrollbind
    execute "normal! gg"
    execute "wincmd w"
    set scrollbind
    set sbo=hor
endfunction
nnoremap FT :call FreezeTop()<CR>

function! Columnate()
    execute "%! column -t -s,"
endfunction
nnoremap Col :call Columnate()<CR> 

" CScope autocommand to start cscope and find the path to your
" cscope file from:
" https://vim.fandom.com/wiki/Autoloading_Cscope_Database

function! LoadCscope()
    let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path = strpart(db, 0, match(db, "/cscope.out$"))
        set nocscopeverbose " suppress 'duplicate connection' error
        exe "cs add " . db . " " . path
        set cscopeverbose
    endif
endfunction
au BufEnter /* call LoadCscope()
