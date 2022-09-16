let mapleader="\\"

" Insert spaces on indent
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

" Line numbers on the left
set number

" Intuitive split navigation
set splitbelow splitright

" mouse navigation on visual mode
set mouse=a

" Shortcut split navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Open split shortcuts
nnoremap <leader>h :split<space>
nnoremap <leader>v :vsplit<space>

" Shortcut tab navigation
map <a-j> :tabp<CR> 
map <a-k> :tabn<CR> 

" Quit all shortcut
nnoremap ZA :quitall<CR>

" Open tab shortcut:
nnoremap <leader>t :tabnew<space>

" Display matching files when tab complete
set path+=**
set wildmode=longest,list,full

" Install plugins with vim-plug
call plug#begin(stdpath('data') . '/plugged')

    " Appearance
    Plug 'ryanoasis/vim-devicons'
    Plug 'morhetz/gruvbox'
    "Plug 'tomasiser/vim-code-dark'
    Plug 'itchyny/lightline.vim'
    Plug 'shinchu/lightline-gruvbox.vim'

    " Nerdtree
    Plug 'preservim/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'

    " Autocompletion
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tpope/vim-surround'
    Plug 'Townk/vim-autoclose'

    " Syntax highlighting
    Plug 'yuezk/vim-js', { 'for': 'js' }
    Plug 'MaxMEllon/vim-jsx-pretty', { 'for': 'jsx' }
    Plug 'vim-scripts/colorizer'

    " Miscellanious
    Plug 'ThePrimeagen/vim-be-good'
    Plug 'matveyt/neoclip'


call plug#end()


"
"       Colour scheme
"

let g:gruvbox_contrast_dark = 'hard'

autocmd VimEnter * hi! Normal guibg=NONE ctermbg=NONE

colorscheme gruvbox


"
"       Lightline
"

" Set gruvbox theme to lightline
let g:lightline = { 'colorscheme': 'gruvbox' }



"
"       NERDTree 
"

let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeMouseMode=3

autocmd StdinReadPre * let s:std_in=1

" Mirror the NERDTree before showing it. This makes it the same on all tabs.
nnoremap <C-b> :NERDTreeMirror<CR>:NERDTreeToggle<CR>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
     \ quit | endif

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * silent NERDTreeMirror

" Start NERDTree when Vim starts with a directory argument.
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Start NERDTree when Vim is started without file arguments.
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif



"
"       CoC
"

" Trigger CoC with ctrl-space
inoremap <silent><expr> <c-space> coc#refresh()



"
"       VimWiki
"

let g:vimwiki_list = [{ 'path': '~/docs/vimwiki/' }]

