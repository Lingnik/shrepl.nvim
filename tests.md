# Test case 1: basic command (normal mode)
Input buffer:
1 echo "cat"

Command: <leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `echo "cat"`
2 ``` sh
3 cat
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 echo "cat"


# Test case 2: basic command (visual line mode)
Input buffer:
1 echo "cat"

Command: V<leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `echo "cat"`
2 ``` sh
3 cat
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 echo "cat"


# Test case 3: stderr (normal mode)
Input buffer:
1 asdf

Command: <leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `asdf`
2 ``` sh
3 zsh: command not found: asdf
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 asdf


# Test case 4: stderr (visual line mode)
Input buffer:
1 asdf

Command: V<leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `asdf`
2 ``` sh
3 zsh: command not found: asdf
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 asdf


# Test case 5: basic command with pipe (visual mode)
Input buffer:
1 echo "cat" | grep "at"

Command: <leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `echo "cat" | grep "at"`
2 ``` sh
3 cat
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 echo "cat"


# Test case 6: Multi-line basic command
Input buffer:
1 echo \
2  "cat"

Command: V<leader>x

Expected buffer:
1 # 2024-11-20 09:22:50 `echo -n \\n "cat"` <-- NOTE: This can be flexible... I'm not opinionated on how to show this, because I'm more concerned about the code being simple. Might be better to show the code as a separate pair of lines (or a single line in the monoline case) so that the user can snip it elsewhere as needed
2 ``` sh
3 cat
4 ```
5 Exit Code: 0 | Time: 0.000 sec | Timestamp: 2024-11-20 09:22:50
6 
7 echo -n \
8  "cat"

