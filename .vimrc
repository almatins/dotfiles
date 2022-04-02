syntax enable
filetype plugin indent on

" background
" set background=light
set background=dark
" show title
set title
" display row number
set number
" show relative row number
set relativenumber
" highlight cursorline
set cursorline
" show line and column number
set ruler
" indents
set autoindent
set smartindent
" cursor
set guicursor=
" hide buffer
set hidden
" do not ring bell on error
set noerrorbells
" turn of visual bell
set novisualbell
" tab
set tabstop=2 
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set nu
" turn off wrap
set nowrap
" turn off fold
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
" turn on incremental search
set incsearch
" term gui color
set termguicolors
" minimal number of screen lines to keep above cursor
set scrolloff=8
" turn off visual mode
set noshowmode
"set completeopt=menuone,noinsert,noselect
" insert mode completion, insert only when user select
set completeopt+=noinsert
" add preview
set completeopt-=preview
" list all matches 
set wildmode=list:longest
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" draw the sign column
set signcolumn=yes
" enable mouse for all prev modes
set mouse=a
" no beep or flash message
set vb t_vb= 
" highlight search
set hlsearch

" Give more space for displaying messages.
set cmdheight=4

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" color column 
set colorcolumn=80

" vimplug
call plug#begin('~/.vim/plugged')

" JavaScript bundle for vim, this bundle provides syntax highlighting and
" improved indentation.
Plug 'pangloss/vim-javascript'

" typescript
Plug 'leafgarland/typescript-vim'
Plug 'ianks/vim-tsx'
Plug 'leafgarland/typescript-vim'

" dart
Plug 'dart-lang/dart-vim-plugin'

" flutter
" Plug 'iamcco/coc-flutter'
Plug 'thosakwe/vim-flutter'
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'

" Snippets
Plug 'natebosch/dartlang-snippets'

" completion
" Make your Vim/Neovim as smart as VSCode.
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Vue language server extension for coc.nvim
" Plug 'neoclide/coc-vetur'
" eslint
Plug 'neoclide/coc-eslint'

" Vim syntax highlighting for Vue components.
Plug 'posva/vim-vue'
" flutter
Plug 'thosakwe/vim-flutter'

" prettier
" A Vim plugin for Prettier
Plug 'prettier/vim-prettier'

" indent guide
Plug 'nathanaelkane/vim-indent-guides'
" auto paris
Plug 'jiangmiao/auto-pairs'

" file finder
" A command-line fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvim-lua/plenary.nvim'

" color scheme
" Retro groove color scheme for Vim
Plug 'morhetz/gruvbox'

" status bar
Plug 'vim-airline/vim-airline'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()

" disable startup message for coc
let g:coc_disable_startup_warning = 1
" prettier
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

"coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ 'coc-flutter',
  \ 'coc-snippets',
  \ 'coc-yaml',
  \ 'coc-tslint-plugin',
  \ 'coc-tsserver',
  \ 'coc-emmet',
  \ 'coc-css',
  \ 'coc-html',
  \ 'coc-json',
  \ ]

" indent guides
" ============================================================================
" INDENTGUIDE CONFIGURATION
" ============================================================================
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level           = 2
let g:indent_guides_auto_colors           = 1
let g:indent_guides_color_change_percent  = 20
let g:indent_guides_space_guides          = 1
let g:indent_guides_tab_guides            = 1
let g:indent_guides_guide_size            = 1
let g:indent_guides_exclude_filetypes     = ['help', 'nerdtree', 'startify', 'Preview','__doc__','rst']

" color scheme
colorscheme gruvbox
let g:gruvbox_contrast_light = "hard"

" airline
let g:airline#extensions#battery#enabled = 1

" prettier
nnoremap <Leader>p :Prettier<CR>
" fzf
nnoremap <C-p> :Files<CR>
" flutter
nnoremap <leader>fa :FlutterRun<CR>
nnoremap <leader>fq :FlutterQuit<CR>
nnoremap <leader>fr :FlutterHotReload<CR>
nnoremap <leader>fR :FlutterHotRestart<CR>
nnoremap <leader>fD :FlutterVisualDebug<CR>

" goto code definition
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" git
nnoremap <leader>gdiff :Gvdiffsplit<CR>

" cursor movements
" ----------------
" move to the end of line on insert mode
inoremap <C-e> <C-o>$
" cnext and cprev when vimgrep
nnoremap <Leader>> :cnext<CR>
nnoremap <Leader>< :cprev<CR>

" buffers
" close current buffer
nnoremap <Leader>w :bd<CR>
" show list of buffers
nnoremap <Leader>l :Buffers<CR>
" show history files edited
nnoremap <Leader>h :History<CR>

" disable change case
xnoremap u <nop>
xnoremap U <nop>
nnoremap gu <nop>
nnoremap gU <nop>

" -- ctrl + s for save, instead of freeze
noremap <silent> <C-S> :update<CR>

" copy paste 
nnoremap <C-c> "yy<CR>
vnoremap <C-c> "yy

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

" map tab to escape
" nnoremap <Tab> <Esc>
" vnoremap <Tab> <Esc>gV
" onoremap <Tab> <Esc>
" cnoremap <Tab> <C-C><Esc>
" inoremap <Tab> <Esc>`^
" inoremap <Leader><Tab> <Tab>

" completion on command
set wc=<Esc>

" cursor color
highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue

"flutter
nnoremap <leader>fe :CocCommand flutter.emulators <CR>
nnoremap <leader>fd :below new output:///flutter-dev <CR>

"dart
let g:dart_format_on_save = 1
let g:dartfmt_options = ['--fix', '--line-length 120']

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

