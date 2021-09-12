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


" CScope function stolen from https://github.com/Big-B
function! LoadCscope()
    let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path = strpart(db, 0, match(db, "/cscope.out$"))
        set nocscopeverbose " supress 'duplicate connection' error
        exe "cs add " . db . " " . path
        set cscopeverbose
    endif
endfunction
au BufEnter /* call LoadCscope()
