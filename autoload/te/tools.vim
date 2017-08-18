"pop vimshell
function! te#tools#shell_pop() abort
    " 38% height of current window
    let l:line=(38*&lines)/100
    if  l:line < 10 | let l:line = 10 |endif
    let l:fullbuffer=1
    "any list buffer exist or buffer is startify
    if bufexists(expand('%')) && &filetype !=# 'startify'
                \ && &modified == 0
        let l:fullbuffer=0
        if te#env#IsNvim() || !te#env#SupportTerminal()
            execute 'rightbelow '.l:line.'split'
        endif
    endif
    if te#env#IsGui()
        let l:shell='bash'
    else
        let l:shell=&shell
    endif
    if te#env#SupportTerminal()  && te#env#IsVim8()
        if l:fullbuffer == 1 && &modified == 0
            execute ':terminal ++close ++curwin '.l:shell
        else
            "close terminal windows automatically after exit.
            execute ':terminal ++close '.l:shell
            execute 'normal '."\<c-w>r"
        endif
    elseif te#env#SupportTerminal() && te#env#IsNvim()
        :terminal
    else 
        execute 'VimShell' 
    endif
endfunction
"put message from vim command to + register
function! te#tools#vim_get_message()
    let l:command=input('Input command: ')
    if l:command !=# ''
        execute ':redir @+> | silent '.l:command.' | redir END'
    else
        call te#utils#EchoWarning('Empty command is not allowed!', 'err')
    endif
endfunction

"update latest stable t_vim
function! te#tools#update_t_vim() abort
    cd $VIMFILES
    if isdirectory('.git') && te#env#Executable('git')
        let l:command='git fetch --all && '
        let l:command.='git checkout $(git describe --tags `git rev-list --tags --max-count=1`)'
        call te#utils#run_command(l:command, 1)
    else
        call te#utils#EchoWarning('Not a git repository or git not found!', 'err')
    endif
endfunction


function! te#tools#max_win() abort
    if te#env#IsMacVim()
        set fullscreen
    elseif te#env#IsUnix()
        :win 1999 1999
        silent !wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    elseif te#env#IsWindows()
        :simalt~x "maximize window
    else
        :win 1999 1999
    endif
endfunction
