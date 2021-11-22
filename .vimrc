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

" CScope function stolen from https://github.com/Big-B
function! LoadCscope()
    let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path1 = strpart(db, 0, match(db, "/cscope.out$"))
        set nocscopeverbose " supress 'duplicate connection' error
        exe "cs add " . db . " " . path1
        set cscopeverbose
    endif
endfunction
au BufEnter /* call LoadCscope()
