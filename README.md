Vim Asciidoc Annotations
========================

[![asciicast](https://asciinema.org/a/28268.png)](https://asciinema.org/a/28268?autoplay=1&t=15)

A simple plugin to make adding random annotations as internal 
references stored in a separate file. I made this since solutions
like vim-notebook aren't geared towards handling multiple line
annotations for pieces of text.

There are several functions, but here are the ones that are relevant.

* **annos#WrapWordAnno()** - Mark the current word as annotated.
* **annos#WrapVisualAnno()** - Mark the visual selection as annotated.
It will try to move the boundaries so the annotation encapsulates the 
closest words.
* **annos#OpenAnnosFor()** - Open the file that is annotated with the current
asciidoc file.
* **annos#OpenAnnos()** - Open the file that contains the annotation for 
the current asciidoc file.
* **annos#GoToAnno(id)** - Go to the annotation specified in the asciidoc
file containing the annotations.
* **annos#GoToAnnoContext(id)** - Go to the relevant annotated text in
the asciidoc file the annotations file is for.
* **annos#GoToCurrentAnno()** - Go to the annotation for the annotated text.
* **annos#GoToCurrentAnnoContext()** - Go to the context for the current annotation.

There are no commands defined by default.

Will there be markdown versions? That I don't know yet.

One important caveat of this is that **annos#ShortGenID()**, the 
function that generates the IDs for the annotation, assumes that
**uuidgen**, **sha256sum**, and **grep** are installed on 
your system.
