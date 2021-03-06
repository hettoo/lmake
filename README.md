# Lazy Make

Create files for simple projects and process them without much effort.

The script works by extensions: `lmake.pl test.tex` will copy `~/lmake/default.tex` to `test.tex` if it does not exist.
If it does exist, the default action `all` belonging to `.tex` is executed on `test.tex`.
A different action can be given as the second argument.

These actions are specified in the file `~/lmake/config`.
This file contains a sequence of blocks, separated by empty lines.
Each block begins with a comma-delimited sequence of extensions (including the dot).
The next line contains a command that is executed before every action of these extensions, and the remaining lines define specific actions with the syntax `<action>:<command>` or `<action>@<actions>`, where the action list is delimited by whitespace.
Use `$1` and `$2` to refer to the input filename, respectively with and without extension.
Make sure to end all commands with a semicolon.

As an example, here is my `.tex` configuration:
```
.tex
mkdir -p build;cmd="pdflatex -output-directory build ./$1";
all: $cmd;
v: evince build/$2.pdf;
b: BIBINPUTS=build:$BIBINPUTS bibtex build/$2;
f: $cmd && $cmd;
bf@ all b f
```

Note that the intended use is for simple projects that consist of a single file and do not require specific build options.
