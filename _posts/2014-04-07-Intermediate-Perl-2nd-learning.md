---
layout: post
title: Intermediate-Perl-2nd-learning01
tag: Linux
---

<a href="http://perldoc.perl.org/functions/do.html">perldoc/function/do</a>

do

Perl functions A-Z | Perl functions by category | The 'perlfunc' manpage

do BLOCK



Not really a function. Returns the value of the last command in the sequence of commands indicated by BLOCK. When modified by the while or until loop modifier, executes the BLOCK once before testing the loop condition. (On other statements the loop modifiers test the conditional first.)

do BLOCK does not count as a loop, so the loop control statements next, last, or redo cannot be used to leave or restart the block. See perlsyn for alternative strategies.

do EXPR



Uses the value of EXPR as a filename and executes the contents of the file as a Perl script.

is largely like

except that it's more concise, runs no external processes, keeps track of the current filename for error messages, searches the @INC directories, and updates %INC if the file is found. See @INC in perlvar and%INC in perlvar for these variables. It also differs in that code evaluated with do FILENAME cannot see lexicals in the enclosing scope; eval STRING does. It's the same, however, in that it does reparse the file every time you call it, so you probably don't want to do this inside a loop.

If do can read the file but cannot compile it, it returns undef and sets an error message in $@ . If do cannot read the file, it returns undef and sets $! to the error. Always check $@ first, as compilation could fail in a way that also sets $! . If the file is successfully compiled, do returns the value of the last expression evaluated.

Inclusion of library modules is better done with the use and require operators, which also do automatic error checking and raise an exception if there's a problem.

You might like to use do to read in a program configuration file. Manual error checking can be done this way:

   # read in config files: system first, then user

   for $file ("/share/prog/defaults.rc",

              "$ENV{HOME}/.someprogrc")

   {

       unless ($return = do $file) {

           warn "couldn't parse $file: $@" if $@;

           warn "couldn't do $file: $!"    unless defined $return;

           warn "couldn't run $file"       unless $return;

       }

   }

   eval `cat stat.pl`;

   do 'stat.pl';



assignment:

my $bowler;

if( ...some condition... ) {

$bowler = 'Mary Ann';

}

elsif( ... some condition ... ) {

$bowler = 'Ginger';

}

else {

$bowler = 'The Professor';

}

However, with do, we only have to use the variable name once. We can assign to it at

the same time that we declare it because we can combine everything else in the do as if

it were a single expression:

my $bowler = do {

if( ... some condition ... ) { 'Mary Ann' }

elsif( ... some condition ... ) { 'Ginger' }

else { 'The Professor' }

};

32 |

