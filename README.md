# C3 Cubed

C3 Cubed is a QBE wrapper written in C3

It's files can be found under /lib/c3cubed.c3l

This repo contains 2 example programs written, one being a brainfuck compiler written using the library, the other being an implementation of (Kaleidescope)[https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/LangImpl01.html] written in it.

the first one can be built by doing `c3c build brainfuckc`

and the second one by doing `c3c build kaleidescope`

They both take one argument, which is the source file, and output the QBE IR into stdout.


## Kaleidescope

The kaleidescope implementation provides a few default functions:

- get:
    reads a number from stdin
- putc:
    puts a character onto stdout
- print:
    prints a number onto stdout (no newline)
- printn:
    prints a number onto stdout (newline)

Then it also provides the `:` and `<` operators builtin
