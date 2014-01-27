This program is currently in alpha status.  It works pretty well at present as a
visualization tool, however crucial features are still missing from the program
like the ability to save the text file back to disk.  Also there may be somewhat
unexpected behavior from the UI, not so much becuase of bugs, but more as a
reflection of how the program attacks the problem.  Before the final release of
this program I would like to implement the following

saving files back to the disk

a proper about dialog

having all the search buttons obey symantics that the user would expect, like
say perhaps searching starting from the current cursor position rather than from
the top and other minor refinements

cutting copying and pasting

an undo facility, preferably a multi level undo


I think If I can implement these features, this program could actually be useful to somebody.

changlog
    version 0.1.2
        Took out rdoc/usage which is no longer supported from 1.9.3 onward,
        tested with ruby 2.1.0 and it still works :), added a line so it loads
        up tiles

    version 0.1.1
        Added rdoc documentation to the source and changed the gem so that it
        will autogenerate this documentation.

    version 0.1.0
        Initial version, partial functionality, needs work
