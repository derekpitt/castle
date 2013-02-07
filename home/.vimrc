nn <silent> <c-j> :bn<CR>
nn <silent> <c-k> :bp<CR>
nn <silent> <c-n> :cNext<CR>




function! Fnsearch(text, ext)
  execute "vimgrep /" . a:text . "/ **/*." . a:ext
  :cwindow
endfunction

command -nargs=* SSearch call Fnsearch(<f-args>)

call pathogen#infect()
filetype plugin indent on


set nobackup
set noswapfile

syntax enable
set background=dark
colorscheme solarized

let g:ctrlp_map = '<c-p>'
let g:ctrlp_working_path_mode = 0


"map <silent> ,B :CoffeeMake -b<CR>
map <silent> ,, :CoffeeMake<CR>
map <silent> ,r :!rake<CR>
map <silent> ,c :!coffee %<CR>
map <silent> ,g :!go run %<CR>


" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif



set ts=2 sts=2 sw=2 expandtab
set hlsearch
set hidden
set ignorecase smartcase
set cursorline
":nnoremap <CR> :nohlsearch<cr>
map <silent> <C-CR> :nohlsearch<cr>
set nu

:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
:set laststatus=2


function! GetASCII (code)
    let dic = {   "32":" ", "33":"!", "34":"\"", "35":"#", "36":"$", "37":"%",
                \ "38":"&", "39":"'", "40":"(", "41":")", "42":"*", "43":"+", "44":",",
                \ "45":"-", "46":".", "47":"/", "48":"0", "49":"1", "50":"2", "51":"3",
                \ "52":"4", "53":"5", "54":"6", "55":"7", "56":"8", "57":"9", "58":":",
                \ "59":";", "60":"<", "61":"=", "62":">", "63":"?", "64":"@", "65":"A",
                \ "66":"B", "67":"C", "68":"D", "69":"E", "70":"F", "71":"G", "72":"H",
                \ "73":"I", "74":"J", "75":"K", "76":"L", "77":"M", "78":"N", "79":"O",
                \ "80":"P", "81":"Q", "82":"R", "83":"S", "84":"T", "85":"U", "86":"V",
                \ "87":"W", "88":"X", "89":"Y", "90":"Z", "91":"[", "92":"\\", "93":"]",
                \ "94":"^", "95":"_", "96":"`", "97":"a", "98":"b", "99":"c", "100":"d",
                \ "101":"e", "102":"f", "103":"g", "104":"h", "105":"i", "106":"j",
                \ "107":"k", "108":"l", "109":"m", "110":"n", "111":"o", "112":"p",
                \ "113":"q", "114":"r", "115":"s", "116":"t", "117":"u", "118":"v",
                \ "119":"w", "120":"x", "121":"y", "122":"z", "123":"{", "124":"|",
                \ "125":"}", "126":"~" }
    if has_key(dic, a:code)
        return dic[a:code]
    else
        return ""
    endif
endfunction


" ACEJUMP
" Based on emacs' Ace Jump feature.
" Type AJ mapping, followed by a lower or uppercase letter.
" All words on the screen starting with that letter will have
" their first letters replaced with a sequential character.
" Type this character to jump to that word.

highlight AceJumpGrey ctermfg=darkgrey
highlight AceJumpRed ctermfg=darkred

function! AceJump ()
    " store some current values for restoring later
    let origPos = getpos('.')
    let origSearch = @/

    " prompt and capture user's search character
    echo "AceJump to words starting with letter: "
    let letter = GetASCII(getchar())
    " return if invalid key, mouse press, etc.
    if len(letter) == 0
        echo ""
        redraw
        return
    endif
    " redraws here and there to get past 'more' prompts
    redraw
    " row/col positions of words beginning with user's chosen letter
    let pos = []

    " monotone all text in visible part of window (dark grey by default)
    call matchadd('AceJumpGrey', '\%'.line('w0').'l\_.*\%'.line('w$').'l', 20)

    " loop over every line on the screen (just the visible lines)
    for row in range(line('w0'), line('w$'))
        " find all columns on this line where a word begins with our letter
        let col = 0
        let matchCol = match(getline(row), '\<'.letter, col)
        while matchCol != -1
            " store any matching row/col positions
            call add(pos, [row, matchCol])
            let col = matchCol + 1
            let matchCol = match(getline(row), '\<'.letter, col)
        endwhile
    endfor

    " if we only found one match, just jump to it without prompting
    if len(pos) == 1
        " set position to the one match
        let [r,c] = pos[0]
        call setpos('.', [0,r,c+1,0])
        " turn off all search highlighting
        call clearmatches()
        " clean up the status line and return
        echo ""
        redraw
        return
    endif

    " jump characters used to mark found words (user-editable)
    let chars = 'abcdefghijlkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.;"[]<>{}|\\'

    " trim found positions list; cannot be longer than jump markers list
    let pos = pos[:len(chars)]

    " jumps list to pair jump characters with found word positions
    let jumps = {}
    " change each found word's first letter to a jump character
    for [r,c] in pos
        " stop marking words if there are no more jump characters
        if len(chars) == 0
            break
        endif
        " 'pop' the next jump character from the list
        let char = chars[0]
        let chars = chars[1:]
        " move cursor to the next found word
        call setpos('.', [0,r,c+1,0])
        " create jump character key to hold associated found word position
        let jumps[char] = [0,r,c+1,0]
        " replace first character in word with current jump character
        exe 'norm r'.char
        " change syntax on the jump character to make it highly visible
        call matchadd('AceJumpRed', '\%'.r.'l\%'.(c+1).'c', 30)
    endfor

    " this redraw is critical to syntax highlighting
    redraw

    " prompt user again for the jump character to jump to
    echo 'AceJump to words starting with "'.letter.'" '
    let jumpChar = GetASCII(getchar())

    " get rid of our syntax search highlighting
    call clearmatches()
    " clear out the status line
    echo ""
    redraw
    " restore previous search register value
    let @/ = origSearch

    " undo all the jump character letter replacement
    norm u

    " if the user input a proper jump character, jump to it
    if has_key(jumps, jumpChar)
        call setpos('.', jumps[jumpChar])
    else
        " if it didn't work out, restore original cursor position
        call setpos('.', origPos)
    endif
endfunction

nnoremap ,a :call AceJump()<CR>




function! SlideroomFrameworkRelated ()
  let ext = expand("%:e")

  if ext == "html"
    :e %:r.coffee
  elseif ext == "coffee"
    :e %:r.html
  endif
endfunction
nnoremap ,. :call SlideroomFrameworkRelated()<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>
