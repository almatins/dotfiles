syntax enable
filetype plugin indent on

" background
" set background=light
set background=dark
" show title
set title
" display row number
set number
set relativenumber
set cursorline
set ruler
set showtabline=2
set clipboard=unnamedplus
" indents
set autoindent
set smartindent
set exrc
set guicursor=
set hidden
set noerrorbells
set novisualbell
" tab
set tabstop=4 
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set nu
set nowrap
set nofoldenable
" cases
set ignorecase
set smartcase
set autoread
" swap and backup
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8
set noshowmode
"set completeopt=menuone,noinsert,noselect
set completeopt+=noinsert
set completeopt-=preview
set wildmode=list:longest
set shortmess+=c
set signcolumn=yes
set mouse=a
set vb t_vb=     " no visual be" & flas
set hlsearch

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set colorcolumn=80

call plug#begin('~/.vim/plugged')
" 
" " A universal set of defaults that (hopefully) everyone can agree on
" Plug 'tpope/vim-sensible'
" 
" === languages ===
" language packs
Plug 'sheerun/vim-polyglot'
" typescript syntax file and other settings 
Plug 'leafgarland/typescript-vim'
" dart language support
Plug 'dart-lang/dart-vim-plugin'
" vim-javascript
" Plug 'pangloss/vim-javascript'
" 
" === code completion ===
" code completion 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
" flutter code completion
Plug 'iamcco/coc-flutter'
" 
" " === lint and formatting ===
" " Async lint engine 
" " Plug 'w0rp/ale'
" wrapper for prettier 
Plug 'prettier/vim-prettier', { 'do': 'yarn install', 'branch': 'release/1.x' }
" 
" === files ===
" fuzzy finder to find files
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" " Better file browser
" Plug 'scrooloose/nerdtree'
" " Adds icons to vim plugins
" Plug 'ryanoasis/vim-devicons'
" " continuously updated session files
" Plug 'tpope/vim-obsession'
" 
" " theme and display
" " theme
Plug 'morhetz/gruvbox'
" status and tabline 
Plug 'vim-airline/vim-airline'
" battery status
Plug 'lambdalisue/battery.vim'
" 
" " === Git ===
" " Git wrapper
" Plug 'tpope/vim-fugitive'
" 
" " === editing ===
" insert and delete bracket, parens, quotes in pair 
Plug 'jiangmiao/auto-pairs'
" " Comment stuff out
" Plug 'tpope/vim-commentary'
" " quoting/parenthesis made simple
Plug 'tpope/vim-surround'
" Indent Guides is a plugin for visually displaying indent levels in Vim.
Plug 'nathanaelkane/vim-indent-guides'
" 
" " === tasks todos ===
" " Eclipse TaskList
" Plug 'fisadev/FixedTaskList.vim'
" " Distraction-free writing in Vim.
" Plug 'junegunn/goyo.vim'
" " A simple tool for presenting slides in vim based on text files.
" Plug 'sotte/presenting.vim'
" Vim plugin for .tmux.conf
Plug 'tmux-plugins/vim-tmux'
" 
call plug#end()

let g:coc_disable_startup_warning = 1
let g:prettier#autoformat = 1
let g:airline#extensions#battery#enabled = 1
let g:ale_fix_on_save = 1

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" " Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" " Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
 " coc-prettier
 command! -nargs=0 Prettier :CocCommand prettier.formatFile

" move to the end of line on insert mode
inoremap <C-e> <C-o>$

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

nnoremap <C-p> :Files<CR>
nnoremap <Leader>w :bd<CR>
nnoremap <Leader>l :Buffers<CR>
nnoremap <Leader>h :History<CR>
nnoremap <Leader>p :Prettier<CR>

" disable change case
xnoremap u <nop>
xnoremap U <nop>
nnoremap gu <nop>
nnoremap gU <nop>

" copy paste 
nnoremap <C-c> "yy<CR>
vnoremap <C-c> "yy

colorscheme gruvbox

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" clear search results
nnoremap <silent> // :noh<CR>

" tab navigation mappings
map tt :tabnew
map <M-Right> :tabn<CR>
imap <M-Right> <ESC>:tabn<CR>
map <M-Left> :tabp<CR>
imap <M-Left> <ESC>:tabp<CR>

nnoremap <silent> [oh :call gruvbox#hls_show()<CR>
nnoremap <silent> ]oh :call gruvbox#hls_hide()<CR>
nnoremap <silent> coh :call gruvbox#hls_toggle()<CR>

nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?

" ============================================================================
" NERDTREE
" ============================================================================
" nnoremap <leader>n :NERDTreeFocus<CR>
" nnoremap <C-n> :NERDTree<CR>
" nnoremap <C-t> :NERDTreeToggle<CR>
" nnoremap <C-f> :NERDTreeFind<CR>

" TASKLIST CONFIGURATION
" ============================================================================
" show pending tasks list
" map <F2> :TaskList<CR>

" ============================================================================
" AUTOCLOSE ISORT CONFIGURATION
" ============================================================================
" Fix to let ESC work as espected with Autoclose plugin
" (without this, when showing an autocompletion window, ESC won't leave insert
"  mode)
" let g:AutoClosePumvisible = {"ENTER": "\<C-Y>", "ESC": "\<ESC>"}

" ============================================================================
" VIM_DEV_ICONS CONFIGURATION
" ============================================================================
" loading the plugin
" let g:webdevicons_enable = 1
" " adding the flags to NERDTree
" let g:webdevicons_enable_nerdtree = 1
" " adding the custom source to unite
" let g:webdevicons_enable_unite = 1
" " adding the column to vimfiler
" let g:webdevicons_enable_vimfiler = 1
" " adding to vim-airline's tabline
" let g:webdevicons_enable_airline_tabline = 1
" " adding to vim-airline's statusline
" let g:webdevicons_enable_airline_statusline = 1
" " ctrlp glyphs
" let g:webdevicons_enable_ctrlp = 1
" " adding to vim-startify screen
" let g:webdevicons_enable_startify = 1
" " adding to flagship's statusline
" let g:webdevicons_enable_flagship_statusline = 1
" " turn on/off file node glyph decorations (not particularly useful)
" let g:WebDevIconsUnicodeDecorateFileNodes = 1
" " use double-width(1) or single-width(0) glyphs
" " only manipulates padding, has no effect on terminal or set(guifont) font
" let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
" " whether or not to show the nerdtree brackets around flags
" let g:webdevicons_conceal_nerdtree_brackets = 1
" " the amount of space to use after the glyph character (default ' ')
" let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '
" " Force extra padding in NERDTree so that the filetype icons line up vertically
" let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1
" " Adding the custom source to denite
" let g:webdevicons_enable_denite = 1

" ============================================================================
" INDENTGUIDE CONFIGURATION
" ============================================================================
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level           = 1
let g:indent_guides_auto_colors           = 1
let g:indent_guides_color_change_percent  = 10
let g:indent_guides_space_guides          = 1
let g:indent_guides_tab_guides            = 1
let g:indent_guides_guide_size            = 1
let g:indent_guides_exclude_filetypes     = ['help', 'nerdtree', 'startify', 'Preview','__doc__','rst']

fun! ColorMyPencils()
    let g:gruvbox_contrast_dark = 'hard'
    if exists('+termguicolors')
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    let g:gruvbox_invert_selection='0'

    colorscheme gruvbox

    highlight ColorColumn ctermbg=0 guibg=grey
    hi SignColumn guibg=none
    hi CursorLineNR guibg=None
    highlight Normal guibg=none
    highlight LineNr guifg=#5eacd3
    highlight netrwDir guifg=#5eacd3
    highlight qfFileName guifg=#aed75f
    hi TelescopeBorder guifg=#5eacd
endfun
call ColorMyPencils()
nnoremap <leader>vwm :call ColorMyPencils()<CR>

" gruvbox overrides
let g:gruvbox_contrast_light = "hard"

