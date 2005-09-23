" File: bookmarks.vim
" Author: Bernard Barton (bfb21@comcast.net)
" Version: 1.0
" Tested with gvim 6.3.86 (Minimal testing under Windows)
" Last Modified: 09/22/05
"
"
" BOOKMARKS OVERVIEW
" ------------------
" Bookmarks.vim provides an intuitive menu driven interface to facilitate 
" bookmarking files and directories in gvim.  
" 
"    Bookmark Features:
"       -Configurable "popup" bookmark menu (On by default - Ctrl-RightClick)
"       -Bookmarks contain file name and part of text from bookmarked file,
"        making it easier to remember.
"       -The whitespace in bookmarks is compressed, increasing readability.
"       -Can have unlimited number of bookmarks.
"       -Can bookmark place in help files.
"       -Can bookmark local files, remote files, and directories.
"       -Can bookmark blank lines - Line number used.
"       -Can bookmark gvim on-line help docs.
"       -Includes full function bookmark editor -- It's called gvim! 

"
" INSTALLATION
" ------------
" 1. Copy the bookmarks.vim script to the $HOME/.vim/plugin or the
"    $HOME/vimfiles/plugin or the $VIM/vimfiles directory.  Refer to the
"    ':help add-plugin', ':help add-global-plugin' and ':help runtimepath'
"    topics for more details about gvim plugins.
"
" 2. If you do not want the popup menu enabled (<C-RightMouse>) then add
"    this line to your $HOME/.vimrc (not .gvimrc):
"
"       let bm_popup = "off"
"
" 2. Restart gvim.
"
"
" USAGE
" -----
" -ADDING A BOOKMARK:
"   From the "Bookmarks" menu simply select "Add Bookmark" to bookmark the
"   current line.  The bookmarks will be saved to a file named $HOME/.bookmarks, 
"   or under Windows $VIM/_bookmarks.  The Bookmarks menu will be updated with
"   the file name, compressed text, and line number.  The bookmarks are
"   alphabetized in the .bookmarks file, and also within the menu.     
"   The text is compressed to make the bookmarks more readable.  
"   For example, if you bookmarked the following line with a significant 
"   amount of whitespace:
"
"                                          bookmark this line
"
"  The bookmark would appear in the menu like this:

" bookmark this line (43)
"
" Please note that no key mappings have been defined, since you can simply
" use the menu shortcuts as keyboard combinations.  For example, to add
" a bookmark using the keyboard type: Alt-o a.  This activates the
" Bookmarks menu, and then selects "Add Bookmark".  Note that the
" the shortcuts are unavailable under Windows. 
"
"
" -DELETING A BOOKMARK
"   There is no menu-driven method to delete a bookmark.  To delete a bookmark, 
"   select  Bookmarks -> Edit Bookmarks from the menu.  This will open the
"   file $HOME/.bookmarks in gvim.  The bookmarks are sorted, making it 
"   somewhat easier to delete the intended bookmark.  If for example you
"   wanted to delete the bookmarks for a file named myfile.txt, you could 
"   do something like:
"
"      :g/myfile.txt/d
"
"   You can also change the line numbers if desired, which is the number after
"   the :e.  So, changing :e +830 to :e +840 changes the bookmark's line number
"   from 830 to 840.  This is useful if you edit a file, add or delete lines,
"   and want to keep the bookmark.  After editing the .bookmarks file, select
"   Bookmarks -> Update Bookmarks from the menu.  Please note that you do not
"   have to save the file before updating, since the update process will save 
"   the file.  The Bookmarks menu will be updated reflecting your changes.
"
"  
" -USING THE POPUP MENU
"   The popup menu is enabled by default.  To display the menu, simply press and
"   hold the Ctrl key while clicking the right mouse button.  To disable the
"   popup menu, add  this line to your $HOME/.vimrc (not .gvimrc):
"
"       let bm_popup = "off"
"
"   Of course, you can always assign the popup menu to another key mapping.



if has('unix')
  let s:bm_file = $HOME . "/.bookmarks"
else
  let s:bm_file = $HOME . "/_bookmarks"
endif



function! BookmarkAdd()

  set nohlsearch

  let @b = ":amenu <silent> Bookmarks."

  let l:fname = expand('%:t')

  "Escape all dots in file name.
  let l:fname = substitute(l:fname, '\.', '\\.', "g")

  "If vim just opened, and [No File].
  if l:fname == ""
    return
  endif

  let l:fpath = expand('%:p')

  "Get current line number.
  let l:lineNo = line(".")

  "Get text on current line.
  let @l = getline(".")             

  "Compress whitespace in line, so more text visible in bookmark.
  let @l = substitute(@l,"\\s\\+"," ","g")

  "Trim leading and trailing whitespace.
  let @l = substitute(@l,"^\\s\\+\\|\\s\\+$","","g")

  "Limit text to 35 characters.
  let @l = strpart(@l, 0, 35)

  "If bookmark added on blank line. This must follow trimming of
  "whitspace above, in case there are tabs on line. This was
  "causing blank bookmarks to be added to menu. Else add bookmark
  "text with line number in parens.
  if @l == ""
    let @l = "Line number " . l:lineNo
  else
    let @l = @l . ' (' . l:lineNo . ')'
  endif

  "Lines with single backslash \ cause problem. The \\ is interperted
  "as the end of the menu, truncating the menu item.
  let @l =  substitute(@l, '\\', '\\\', "g")

  "Escape any dots in line.
  let @l =  substitute(@l, '\.', '\\.', "g")

  "Escape any pipes | in line. This was causing
  "No bookmark by that name" error in some cases.
  let @l =  substitute(@l, "|", "\\\\|", "g")
  
  "Add \ char to spaces AND tabs for menu syntax.
  let @l = substitute(@l, "\\s\\+", '\\ ', "g")

  let @b = @b . l:fname . '.\ ' . @l . ' :e +' . l:lineNo . ' ' . l:fpath . '<CR>'
  
  "Write bookmark to file and source.
  silent call BookmarkWrite()

  echo "Bookmark added."

  set hlsearch

endfunction



function! BookmarkAddMenu()
  set nohlsearch
  "Remove menu then re-add when adding or updating, to update menu 
  "items.  Using try to eliminate "No such error" message when starting 
  "gvim, and menu doesn't exist.
  try
    :aunmenu Bookmarks
  catch 
  endtry

  "Add the base menu. The 9998 places the Bookmarks menu all the way to the 
  "right next to the Help menu, which is 9999.
  :9998amenu <silent> B&ookmarks.&Add\ Bookmark :silent call BookmarkAdd()<CR>
  :9998amenu <silent> B&ookmarks.&Edit\ Bookmarks :silent call BookmarkEdit()<CR>
  :9998amenu <silent> B&ookmarks.&Update\ Bookmarks :call BookmarkUpdate()<CR>
  :9998amenu <silent> B&ookmarks.-SEP1- :
   
  "Update Bookmarks menu with any recently added bookmarks,
  "and remove any duplicate bookmarks.
  if filereadable(s:bm_file)
    silent call BookmarkRemDupLines()
    exe "source " . escape(s:bm_file, ' ')
  endif 

  set hlsearch
endfunction


function! BookmarkEdit()
  execute "e " . escape(s:bm_file, ' ')
  nohlsearch
endfunction


function! BookmarkWrite()
  nohlsearch
  "Write bookmark to file and source it.
  exe "redir! >> " . s:bm_file
  silent echon @b
  silent redir END
  "Calling this keeps added bookmarks alphabetized.
  call BookmarkAddMenu()
  silent exe "source " . escape(s:bm_file, ' ')
  echo "Bookmark added."
  nohlsearch
endfunction  


function! BookmarkUpdate()
  set nohlsearch
  "Save .bookmarks file if not already saved.
  silent w!
  silent :call BookmarkAddMenu()
  echo "Bookmarks updated"
  "This eliminates highlighting in first column of screen.
  set hlsearch
endfunction


"Remove duplicate lines, and sort.
function! BookmarkRemDupLines()
  set nohlsearch
  try
    exe "e " . escape(s:bm_file, ' ')
    "Remove blank lines
    :silent g/^\s*$/d
    "Remove duplicate lines (no sorting)
    :silent g/^/kl|if search('^'.escape(getline('.'),'\.*[]').'$','bW')|'ld
    "Call Sort function and execute entire file, the range 1,$.
    :1,$Sort
    :w!
    :bd
  catch
  endtry
  set hlsearch
endfunction



" Function for use with Sort(), to compare two strings.
function! Strcmp(str1, str2)
  if (a:str1 < a:str2)
  	return -1
  elseif (a:str1 > a:str2)
    return 1
  else
	  return 0
  endif
endfunction

" Sort lines.  SortR() is called recursively.
function! SortR(start, end, cmp)
  if (a:start >= a:end)
	  return
  endif
  let partition = a:start - 1
  let middle = partition
  let partStr = getline((a:start + a:end) / 2)
  let i = a:start
  while (i <= a:end)
    let str = getline(i)
    exec "let result = " . a:cmp . "(str, partStr)"
    if (result <= 0)
      " Need to put it before the partition.  Swap lines i and partition.
      let partition = partition + 1
      if (result == 0)
        let middle = partition
      endif
      if (i != partition)
        let str2 = getline(partition)
        call setline(i, str2)
        call setline(partition, str)
      endif
    endif
    let i = i + 1
  endwhile

  " Now we have a pointer to the "middle" element, as far as partitioning
  " goes, which could be anywhere before the partition.  Make sure it is at
  " the end of the partition.
  if (middle != partition)
    let str = getline(middle)
    let str2 = getline(partition)
    call setline(middle, str2)
    call setline(partition, str)
  endif
  call SortR(a:start, partition - 1, a:cmp)
  call SortR(partition + 1, a:end, a:cmp)
endfunction

" To Sort a range of lines, pass the range to Sort() along with the name of a
" function that will compare two lines.
function! Sort(cmp) range
  call SortR(a:firstline, a:lastline, a:cmp)
endfunction

" :Sort takes a range of lines and sorts them.
command! -nargs=0 -range Sort <line1>,<line2>call Sort("Strcmp")



call BookmarkAddMenu()


"Enable popup menu by default.  If bm_popup set to "off"
"in ~/.vimrc (NOT .gvimrc!) then will be unset below.
:map <C-RightMouse> <LeftMouse>:popup Bookmarks<CR>

"This avoids "Undefined variable" error, if bm_popup has 
"not been defined in .vimrc.
if exists("bm_popup") && bm_popup == "off"
  :unmap <C-RightMouse>
endif


nohlsearch
