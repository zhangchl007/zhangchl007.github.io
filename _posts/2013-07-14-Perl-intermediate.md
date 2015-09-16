---
layout: post
title: Perl grep map and sort
tag: perl
---
Perl: grep, map and sort

Ich habe vor Jahren einmal im Netz diesen Artikel über Perl's grep, map und sort gefunden und habe ihn immer wieder mal als "Hilfestellung" bei komplexen Themen verwenden können. Da der Originalartikel leider nicht mehr existiert möchte ich ihn jetzt online stellen, da ich denke, daß er es wert ist, nicht verloren zu gehen.
Er erschien so ca. im Jahre 2000 auf http://www.raycosoft.com, offensichtlich war es damals wohl noch ein anderer Seitenbetreiber.

Originalartikel

One of the advantages of the Perl programming language is its rich lexicon of built-in functions (around 193 by my count). Programming tasks that would take dozens of lines of code in other languages can often be done in a few lines of Perl. However, Perl's many functions won't help you unless you know how and when to use them.     

Perl Tutorial:

The grep function

The map function

The sort function

The holy grail

Bibliography

About the author

Acknowledgements


In this tutorial I discuss three functions: grep, map and sort. Grep selects members from a list, map performs transforms on a list and sort sorts a list. Sounds simple? Yes, but you can solve complex problems by using these functions as building blocks. Scroll on ...

Grep
Definition and syntax
Grep vs. loops
Count array elements that match a pattern
Extract unique elements from a list
Extract list elements that occur exactly twice
List text files in the current directory
Select array elements and eliminate duplicates
Select elements from a 2-D array where y > x
Search a simple database for restaurants

Map
Definition and syntax
Map vs. grep vs. foreach
Transform filenames to file sizes
Convert an array to a hash: find the index for an array value
Convert an array to a hash: search for misspelled words
Convert an array to a hash: store selected CGI parameters (map + grep)
Generate a random password
Strip digits from the elements of an array
Print "just another perl hacker"
Transpose a matrix
Find prime numbers: a cautionary tale

Sort
Definition and syntax
Sort by numerical order
Sort by ASCII order
Sort by dictionary order
Sort by reverse order
Sort using multiple keys
Sort a hash by its keys (sort + map)
Sort a hash by its values (sort + map)
Generate an array of sort ranks
Sort words in a file and eliminate duplicates
Efficient sorting (sort + map)
Sorting lines on the last field (sort + map)
More efficient sorting (sort + map)
CPAN modules for sorting
Sort words with 4 or more consecutive vowels (sort + map + grep)
Print the canonical sort order (sort + map + grep)

The grep function

(If you are new to Perl, skip the next two paragraphs and proceed to the "Select lines from a file" example below. Hang loose, you'll pick it up as you go along.)

grep BLOCK LIST
grep EXPR, LIST

The grep function evaluates the BLOCK or EXPR for each element of LIST, locally setting the $_ variable equal to each element. BLOCK is one or more Perl statements delimited by curly brackets. LIST is an ordered set of values. EXPR is one or more variables, operators, literals, functions, or subroutine calls. Grep returns a list of those elements for which the EXPR or BLOCK evaluates to TRUE. If there are multiple statements in the BLOCK, the last statement determines whether the BLOCK evaluates to TRUE or FALSE. LIST can be a list or an array. In a scalar context, grep returns the number of times the expression was TRUE.

Avoid modifying $_ in grep's BLOCK or EXPR, as this will modify the elements of LIST. Also, avoid using the list returned by grep as an lvalue, as this will modify the elements of LIST. (An lvalue is a variable on the left side of an assignment statement.) Some Perl hackers may try to exploit these features, but I recommend that you avoid this confusing style of programming.

Grep vs. loops

This example prints any lines in the file named myfile that contain the (case-insensitive) strings terrorism or nuclear:

 open FILE "<myfile" or die "Can't open myfile: $!";
print grep /terrorism|nuclear/i, <FILE>;

This code consumes a lot of memory for large files because grep evaluates its second argument in a list context, and when the diamond operator (<>) is evaluated in a list context it returns the entire file. A more memory-efficient way to do the same thing is:
while ($line = <FILE>) {
    if ($line =~ /terrorism|nuclear/i) { print $line }
}

This example shows that anything grep can do can also be done by a loop. So why use grep? The glib answer is that grep is more Perlish whereas loops are more C-like. A better answer is that grep makes it obvious that we are selecting elements from a list, and grep is more succinct than a loop. (Software engineers would say that grep has more cohesion than a loop.) Bottom line: if you are not experienced with Perl, go ahead and use loops; as you become familiar with Perl, take advantage of power tools like grep.
Count array elements that match a pattern

In a scalar context, grep returns a count of the selected elements.
$num_apple = grep /^apple$/i, @fruits;

The ^ and $ metacharacters anchor the regular expression to the beginning and end of the string, respectively, so that grep selects apple but not pineapple. 

Extract unique elements from a list

@unique = grep { ++$count{$_} < 2 } 
               qw(a b a c d d e f g f h h);
print "@unique\n";
a b c d e f g h
The $count{$_} is a single element of a Perl hash, which is a list of key-value pairs. (The meaning of "hash" in Perl is related to, but not identical to, the meaning of "hash" in computer science.) The hash keys are the elements of grep's input list; the hash values are running counts of how many times an element has passed through grep's BLOCK. The expression is false for all occurrences of an element except the first.

Extract list elements that occur exactly twice

@crops = qw(wheat corn barley rice corn soybean hay 
            alfalfa rice hay beets corn hay);
@dupes = grep { $count{$_} == 2 } 
              grep { ++$count{$_} > 1 } @crops;
print "@dupes\n";
rice
The second argument to grep is "evaluated in a list context" before the first list element is passed to grep's BLOCK or EXPR. This means that the grep on the right completely loads the %count hash before the grep on the left begins evaluating its BLOCK.

List text files in the current directory

@files = grep { -f and -T } glob '* .*';
print "@files\n";

The glob function emulates Unix shell filename expansions; an asterisk means "give me all the files in the current directory except those beginning with a period". The -f and -T file test operators return TRUE for plain and text files respectively. Testing with -f and -T is more efficient than testing with only -T because the -T operator is not evaluated if a file fails the less costly -f test.

Select array elements and eliminate duplicates

@array = qw(To be or not to be that is the question);
print "@array\n";
@found_words = 
    grep { $_ =~ /b|o/i and ++$counts{$_} < 2; } @array;
print "@found_words\n";
To be or not to be that is the question
To be or not to question
The logical expression $_ =~ /b|o/i uses the match operator to select words that contain o or i (case-insensitive). Putting the match operator test before the hash increment test is slightly more efficient than vice-versa (for this example): if the left-hand expression is FALSE, the right-hand expression is not evaluated.

Select elements from a 2-D array where y > x

# An array of references to anonymous arrays
@data_points = ( [ 5, 12 ], [ 20, -3 ], 
                 [ 2, 2 ], [ 13, 20 ] );
@y_gt_x = grep { $_->[1] > $_->[0] } @data_points;
foreach $xy (@y_gt_x) { print "$xy->[0], $xy->[1]\n" }
5, 12
13, 20

Search a simple database for restaurants

This example is not a practical way to implement a database, but does illustrate that the only limit to the complexity of grep's block is the amount of virtual memory available to the program.

 # @database is array of references to anonymous hashes 
@database = ( 
    { name      => "Wild Ginger", 
      city      => "Seattle",
      cuisine   => "Asian Thai Chinese Japanese",
      expense   => 4, 
      music     => "\0", 
      meals     => "lunch dinner",
      view      => "\0", 
      smoking   => "\0", 
      parking   => "validated",
      rating    => 4, 
      payment   => "MC VISA AMEX", 
    },
#    { ... },  etc.
);

sub findRestaurants {
    my ($database, $query) = @_;
    return grep {
        $query->{city} ? 
            lc($query->{city}) eq lc($_->{city}) : 1 
        and $query->{cuisine} ? 
            $_->{cuisine} =~ /$query->{cuisine}/i : 1 
        and $query->{min_expense} ? 
           $_->{expense} >= $query->{min_expense} : 1 
        and $query->{max_expense} ? 
           $_->{expense} <= $query->{max_expense} : 1 
        and $query->{music} ? $_->{music} : 1 
        and $query->{music_type} ? 
           $_->{music} =~ /$query->{music_type}/i : 1 
        and $query->{meals} ? 
           $_->{meals} =~ /$query->{meals}/i : 1 
        and $query->{view} ? $_->{view} : 1 
        and $query->{smoking} ? $_->{smoking} : 1 
        and $query->{parking} ? $_->{parking} : 1 
        and $query->{min_rating} ? 
           $_->{rating} >= $query->{min_rating} : 1 
        and $query->{max_rating} ? 
           $_->{rating} <= $query->{max_rating} : 1 
        and $query->{payment} ? 
           $_->{payment} =~ /$query->{payment}/i : 1
    } @$database;
}

%query = ( city => 'Seattle', cuisine => 'Asian|Thai' );
@restaurants = findRestaurants(\@database, \%query);
print "$restaurants[0]->{name}\n";
Wild Ginger
The map function

map BLOCK LIST
map EXPR, LIST

The map function evaluates the BLOCK or EXPR for each element of LIST, locally setting the $_ variable equal to each element. It returns a list of the results of each evaluation. Map evaluates BLOCK or EXPR in a list context. Each element of LIST may produce zero, one, or more elements in the output list.

In a scalar context, map returns the number of elements in the results. In a hash context, the output list (a, b, c, d, ...) is cast into the form ( a => b, c => d, ... ). If the number of output list elements is not even, the last hash element will have an undefined value. 

Avoid modifying $_ in map's BLOCK or EXPR, as this will modify the elements of LIST. Also, avoid using the list returned by map as an lvalue, as this will modify the elements of LIST. (An lvalue is a variable on the left side of an assignment statement.) Some Perl hackers may try to exploit these features, but I recommend that you avoid this confusing style of programming.

Map vs. grep vs. foreach

Map can select elements from an array, just like grep. The following two statements are equivalent (EXPR represents a logical expression).
@selected = grep EXPR, @input;
@selected = map { if (EXPR) { $_ } } @input;

Also, map is just a special case of a foreach statement. The statement:
@transformed = map EXPR, @input;

(where EXPR is some expression containing $_) is equivalent to (if @transformed is undefined or empty):
foreach (@input) { push @transformed, EXPR; }

In general, use grep to select elements from an array and map to transform the elements of an array. Other array processing can be done with one of the loop statements (foreach, for, while, until, do while, do until, redo). Avoid using statements in grep/map blocks that do not affect the grep/map results; moving these "side-effect" statements to a loop makes your code more readable and cohesive. 

Transform filenames to file sizes

@sizes = map { -s $_ } @file_names;

The -s file test operator returns the size of a file and will work on regular files, directories, special files, etc.

Convert an array to a hash: find the index for an array value

Instead of searching an array, we can use map to convert the array to a hash and then do a direct lookup by hash key. The code using map is simpler and, if we are doing repeated searches, more efficient.

In this example we use map and a hash to find the array index for a particular value:
@teams = qw(Miami Oregon Florida Tennessee Texas 
            Oklahoma Nebraska LSU Colorado Maryland);
%rank = map { $teams[$_], $_ + 1 } 0 .. $#teams;
print "Colorado: $rank{Colorado}\n"; 
print "Texas: $rank{Texas} (hook 'em, Horns!)\n"; 
Colorado: 9
Texas: 5 (hook 'em, Horns!)
The .. is Perl's range operator and $#teams is the maximum index of the @teams array. When the range operator is bracketed by two numbers, it generates a list of integers for the specified range.

When using map to convert an array to a hash, we need to think about how non-unique array elements affect the hash. In the example above, a non-unique team name will make the code print the lowest rank for that team name. Non-unique team names are a data entry error; one way to handle them would be to add a second map to preprocess the array and convert the second and subsequent occurences of a name to a dummy value (and output an error message).

Convert an array to a hash: search for misspelled words

Converting an array to a hash is a fairly common use for map. In this example the values of the hash are irrelevant; we are only checking for the existence of hash keys.
%dictionary = map { $_, 1 } qw(cat dog man woman hat glove);
@words = qw(dog kat wimen hat man glov);
foreach $word (@words) {
    if (not $dictionary{$word}) {   
        print "Possible misspelled word: $word\n";
    }
}
Possible misspelled word: kat
Possible misspelled word: wimen
Possible misspelled word: glov 
This is more efficient than using the grep function to search the entire dictionary for each word. In contrast to the previous example, duplicate values in the input list do not affect the results.

Convert an array to a hash: store selected CGI parameters

A hash is often the most convenient way to store input parameters to a program or subroutine, and map is often the most convenient way to create the parameter hash.
use CGI qw(param);
%params = map { $_, ( param($_) )[0] } 
              grep { lc($_) ne 'submit' } param();

The param() call returns a list of CGI parameter names; the param($_) call returns the CGI parameter value for a name. If the param($_) call returns multiple values for a CGI parameter, the ( param($_) )[0] syntax extracts only the first value so that the hash is still well-defined. Map's block could be modified to issue a warning message for multi-valued parameters.

Generate a random password

In this example the values of the elements in map's input LIST are irrelevant; only the number of elements in LIST affects the result.
@a = (0 .. 9, 'a' .. 'z');
$password = join '', map { $a[int rand @a] } 0 .. 7;
print "$password\n";
y2ti3dal
(You would have to augment this example for production use, as most computer systems require a letter for the first character of a password.)

Strip digits from the elements of an array

As with grep, avoid modifying $_ in map's block or using the returned list value as an lvalue, as this will modify the elements of LIST.
# Trashes @array  :(
@digitless = map { tr/0-9//d; $_ } @array;    

# Preserves @array  :)
@digitless = map { ($x = $_) =~ tr/0-9//d;    
                   $x; 
                 } @array;

Print "just another perl hacker" using maximal obfuscation

The chr function in the map block below converts a single number into the corresponding ASCII character. The "() =~ /.../g" decomposes the string of digits into a list of strings, each three digits long.
print map( { chr } 
           ('10611711511603209711011111610410111' .
           '4032112101114108032104097099107101114') 
           =~ /.../g
         ), "\n";
just another perl hacker
Transpose a matrix

This works with square or rectangular matrices.
@matrix = ( [1, 2, 3], [4, 5, 6], [7, 8, 9] );
foreach $xyz (@matrix) {
    print "$xyz->[0]  $xyz->[1]  $xyz->[2]\n";
}
@transposed = 
    map { $x = $_;
          [ map { $matrix[$_][$x] } 0 .. $#matrix ];
        } 0 .. $#{$matrix[0]};
print "\n";
foreach $xyz (@transposed) {
    print "$xyz->[0]  $xyz->[1]  $xyz->[2]\n";
}
1  2  3
4  5  6
7  8  9

1  4  7
2  5  8
3  6  9
Find prime numbers: a cautionary tale

Lastly, an example of how NOT to use map. Once you become proficient with map, it is tempting to apply it to every problem involving an array or hash. This can lead to unfortunate code like this:

 foreach $num (1 .. 1000) {
    @expr = map { '$_ % ' . $_ . ' &&' } 2 .. int sqrt $num;
    if (eval "grep { @expr 1 } $num") { print "$num " }
}
1 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 ...
This works, but the code is such an evil mess that it made my dog cry. This code violates rule 1 from the classic work The Elements of Programming Style: Write clearly - don't be too clever.

Look at how easy it is to understand a straightforward implementation of the same algorithm:
CANDIDATE: foreach $num (1 .. 1000) {
    foreach $factor (2 .. int sqrt $num) {
        unless ($num % $factor) { next CANDIDATE }
    }
    print "$num ";
}
1 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 ...
As a bonus, the simple implementation is two orders of magnitude faster than the self-generating code! In general, the simpler your code looks, the more the compiler can optimize it. Of course, a complex implementation of a fast algorithm can trump a simple implementation of a slow algorithm.

Now that we have gazed upon the Dark Side, let us return to the path of righteous, simple code ...
The sort function

sort LIST
sort BLOCK LIST
sort SUBNAME LIST

The sort function sorts the LIST and returns the sorted list value. If SUBNAME or BLOCK is omitted, the sort is in standard string comparison order (i.e., an ASCII sort). If SUBNAME is specified, it gives the name of a subroutine that compares two list elements and returns an integer less than, equal to, or greater than 0, depending on whether the elements are in ascending sort order, equal, or descending sort order, respectively. In place of a SUBNAME, you can provide a BLOCK as an anonymous, in-line sort subroutine.

The two elements to be compared are passed as the variables $a and $b. They are passed by reference, so don't modify $a or $b. If you use a subroutine, it cannot be recursive.

Perl versions prior to 5.6 use the Quicksort algorithm for sorting; version 5.6 and higher use the slightly more efficient Mergesort algorithm. Both are efficient N log N algorithms. 

Sort by numerical order

@array = (8, 2, 32, 1, 4, 16);
print join(' ', sort { $a <=> $b } @array), "\n";
1 2 4 8 16 32
Equivalently:
sub numerically { $a <=> $b }
print join(' ', sort numerically @array), "\n";
1 2 4 8 16 32
Sort by ASCII order (not dictionary order)

@languages = qw(fortran lisp c c++ Perl python java);
print join(' ', sort @languages), "\n";
Perl c c++ fortran java lisp python
Equivalently:
print join(' ', sort { $a cmp $b } @languages), "\n";

Watch out if you have some numbers in the data:
print join(' ', sort 1 .. 11), "\n";
1 10 11 2 3 4 5 6 7 8 9
Sort by dictionary order

use locale; 
@array = qw(ASCII ascap at_large atlarge A ARP arp);
@sorted = sort { ($da = lc $a) =~ s/[\W_]+//g;
                 ($db = lc $b) =~ s/[\W_]+//g;
                 $da cmp $db;
               } @array;
print "@sorted\n";
A ARP arp ascap ASCII atlarge at_large
The use locale pragma is optional - it makes the code more portable if the data contains international characters. This pragma affects the operators cmp, lt, le, ge, gt and some functions - see the perllocale man page for details.

Notice that the order of atlarge and at_large was reversed on output, even though their sort order was identical. (The substitution removed the underscore before the sort.) This happened because this example was run using Perl version 5.005_02. Before Perl version 5.6, the sort function would not preserve the order of keys with identical values. The sort function in Perl versions 5.6 and higher preserves this order. (A sorting algorithm that preserves the order of identical keys is called "stable".) 

Sort by reverse order

To reverse the sort order, reverse the position of the operands of the cmp or <=> operators:
sort { $b <=> $a } @array;

or change the sign of the block's or subroutine's return value:
sort { -($a <=> $b) } @array;

or add the reverse function (slightly less efficient, but perhaps more readable):
reverse sort { $a <=> $b } @array;

Sort using multiple keys

To sort by multiple keys, use a sort subroutine with multiple tests connected by Perl's or operator. Put the primary sort test first, the secondary sort test second, and so on.
# An array of references to anonymous hashes
@employees = ( 
    { FIRST => 'Bill',   LAST => 'Gates',     
      SALARY => 600000, AGE => 45 },
    { FIRST => 'George', LAST => 'Tester'     
      SALARY =>  55000, AGE => 29 },
    { FIRST => 'Sally',  LAST => 'Developer', 
      SALARY =>  55000, AGE => 29 },
    { FIRST => 'Joe',    LAST => 'Tester',    
      SALARY =>  55000, AGE => 29 },
    { FIRST => 'Steve',  LAST => 'Ballmer',   
      SALARY => 600000, AGE => 41 } 
);
sub seniority {
    $b->{SALARY}     <=>  $a->{SALARY}
    or $b->{AGE}     <=>  $a->{AGE}
    or $a->{LAST}    cmp  $b->{LAST}
    or $a->{FIRST}   cmp  $b->{FIRST}
}
@ranked = sort seniority @employees;
foreach $emp (@ranked) {
    print "$emp->{SALARY}\t$emp->{AGE}\t$emp->{FIRST} 
        $emp->{LAST}\n";
}
600000  45      Bill Gates
600000  41      Steve Ballmer
55000   29      Sally Developer
55000   29      George Tester
55000   29      Joe Tester
Sort a hash by its keys

Hashes are stored in an order determined by Perl's internal hashing algorithm; the order changes when you add or delete a hash key. However, you can sort a hash by key value and store the results in an array or better, an array of hashrefs. (A hashref is a reference to a hash.) Don't store the sorted results in a hash; this would resort the keys into the original order.
%hash = (Donald => Knuth, Alan => Turing, John => Neumann);
@sorted = map { { ($_ => $hash{$_}) } } sort keys %hash;
foreach $hashref (@sorted) {
    ($key, $value) = each %$hashref;
    print "$key => $value\n";
}
Alan => Turing
Donald => Knuth
John => Neumann
Sort a hash by its values

Unlike hash keys, hash values are not guaranteed to be unique. If you sort a hash by only its values, the sort order of two elements with the same value may change when you add or delete other values. To do a stable sort by hash values, do a primary sort by value and a secondary sort by key:
%hash = ( Elliot => Babbage, 
          Charles => Babbage,
          Grace => Hopper,
          Herman => Hollerith
        );
@sorted = map { { ($_ => $hash{$_}) } } 
              sort { $hash{$a} cmp $hash{$b}
                     or $a cmp $b
                   } keys %hash;
foreach $hashref (@sorted) {
    ($key, $value) = each %$hashref;
    print "$key => $value\n";
}
Charles => Babbage
Elliot => Babbage
Herman => Hollerith
Grace => Hopper
(Elliot Babbage was Charles's younger brother. He died in abject poverty after numerous attempts to use Charles's Analytical Engine to predict horse races. And did I tell you about Einstein's secret life as a circus performer?)

Generate an array of sort ranks for a list

@x = qw(matt elroy jane sally);
@rank[sort { $x[$a] cmp $x[$b] } 0 .. $#x] = 0 .. $#x;
print "@rank\n";
2 0 1 3
Sort words in a file and eliminate duplicates

This Unix "one-liner" displays a sorted list of the unique words in a file. (The \ escapes the following newline so that Unix sees the command as a single line.) The statement @uniq{@F} = () uses a hash slice to create a hash whose keys are the unique words in the file; it is semantically equivalent to $uniq{ $F[0], $F[1], ... $F[$#F] } = ();  Hash slices have a confusing syntax that combines the array prefix symbol @ with the hash key symbols {}, but they solve this problem succinctly.
perl -0777ane '$, = "\n"; \
   @uniq{@F} = (); print sort keys %uniq' file

-0777  - Slurp entire file instead of single line
-a       - Autosplit mode, split lines into @F array
-e       - Read script from command line
-n       - Loop over script specified on command line: while (<>) { ... }
$,       - Output field separator for print
file      - File name 

Efficient sorting: the Orcish maneuver and the Schwartzian transform

The sort subroutine will usually be called many times for each key. If the run time of the sort is critical, use the Orcish maneuver or Schwartzian transform so that each key is evaluated only once. 

Consider an example where evaluating the sort key involves a disk access: sorting a list of file names by file modification date.
# Brute force - multiple disk accesses for each file
@sorted = sort { -M $a <=> -M $b } @filenames;

# Cache keys in a hash (the Orcish maneuver)
@sorted = sort { ($modtimes{$a} ||= -M $a) <=>
                 ($modtimes{$b} ||= -M $b)
               } @filenames;

The Orcish maneuver was popularized by Joseph Hall. The name is derived from the phrase "or cache", which is the term for the "||=" operator. (Orcish may also be a reference to the Orcs, a warrior race from the Lord of the Rings trilogy.)
# Precompute keys, sort, extract results 
# (The famous Schwartzian transform)
@sorted = map( { $_->[0] }   
               sort( { $a->[1] <=> $b->[1] }
                     map({ [$_, -M] } @filenames)
                   )
             );

The Schwartzian transform is named for its originator, Randall Schwartz, who is the co-author of the book Learning Perl. 

Benchmark results (usr + sys time, as reported by the Perl Benchmark module):

Linux, 333 MHz CPU, 1649 files:
Brute force: 0.14 s   Orcish: 0.07 s   Schwartzian: 0.09 s
WinNT 4.0 SP6, 133 MHz CPU, 1130 files:
Brute force: 7.38 s   Orcish: 1.43 s   Schwartzian: 1.38 s

The Orcish maneuver is usually more difficult to code and less elegant than the Schwartzian transform. I recommend that you use the Schwartzian transform as your method of choice.

Whenever you consider optimizing code for performance, remember these basic rules of optimization: (1) Don't do it (or don't do it yet), (2) Make it right before you make it faster, and (3) Make it clear before you make it faster. 

Sorting lines on the last field (Schwartzian transform)

Given $str with the contents below (each line is terminated by the newline character, \n):
eir    11   9   2   6   3   1   1   81%   63%   13
oos    10   6   4   3   3   0   4   60%   70%   25
hrh    10   6   4   5   1   2   2   60%   70%   15
spp    10   6   4   3   3   1   3   60%   60%   14

Sort the contents using the last field as the sort key.
$str = join "\n", 
            map { $_->[0] }
                sort { $a->[1] <=> $b->[1] }
                     map { [ $_, (split)[-1] ] }
                         split /\n/, $str; 

Another approach is to install and use the CPAN module Sort::Fields. For example:

 use Sort::Fields;
@sorted = fieldsort [ 6, '2n', '-3n' ] @lines;

This statement uses the default column definition, which is a split on whitespace.
Primary sort is an alphabetic (ASCII) sort on column 6.
Secondary sort is a numeric sort on column 2.
Tertiary sort is a reverse numeric sort on column 3. 

Efficient sorting revisited: the Guttman-Rosler transform

Given that the Schwartzian transform is the usually best option for efficient sorting in Perl, is there any way to improve on it? Yes, there is! The Perl sort function is optimized for the default sort, which is in ASCII order. The Guttman-Rosler transform (GRT) does some additional work in the enclosing map functions so that the sort is done in the default order. The Guttman-Rosler transform was first published by Michal Rutka and popularized by Uri Guttman and Larry Rosler.

Consider an example where you want to sort an array of dates. Given data in the format YYYY/MM/DD:
@dates = qw(2001/1/1  2001/07/04  1999/12/25);

what is the most efficient way to sort it in order of increasing date?

The straightforward Schwartzian transform would be:
@sorted = map { $_->[0] }
          sort { $a->[1] <=> $b->[1]
                 or $a->[2] <=> $b->[2]
                 or $a->[3] <=> $b->[3]
               }
          map { [ $_, split m</> $_, 3 ] } @dates;

The more efficient Guttman-Rosler transform is:
@sorted = map { substr $_, 10 }
          sort
          map { m|(\d\d\d\d)/(\d+)/(\d+)|;
                sprintf "%d-%02d-%02d%s", $1, $2, $3, $_
              } @dates;

The GRT solution is harder to code and less readable than the Schwartzian transform solution, so I recommend you use the GRT only in extreme circumstances. For tests using large datasets, Perl 5.005_03 and Linux 2.2.14, the GRT was 1.7 times faster than the Schwartzian transform. For tests using Perl 5.005_02 and Windows NT 4.0 SP6, the GRT was 2.5 times faster. Using the timing data from the first efficiency example, the Guttman-Rosler transform was faster than a brute force sort by a factor of 2.7 and 13 on Linux and Windows, respectively. 

If you are still not satisfied, you may be able to speed up your sorts by upgrading to a more recent version of Perl. The sort function in Perl versions 5.6 and higher uses the Mergesort algorithm, which (depending on the data) is slightly faster than the Quicksort algorithm used by the sort function in previous versions.

Again, remember these basic rules of optimization: (1) Don't do it (or don't do it yet), (2) Make it right before you make it faster, and (3) Make it clear before you make it faster. 

Some CPAN modules for sorting

These modules can be downloaded from http://search.cpan.org/. 

File::Sort - Sort one or more text files by lines
Sort::Fields - Sort lines using one or more columns as the sort key(s)
Sort::ArbBiLex - Construct sort functions for arbitrary sort orders
Text::BibTeX::BibSort - Generate sort keys for bibliographic entries.

The open source community is adding to CPAN regularly - use the search engine to check for new modules. If one of the CPAN sorting modules can be modified to suit your needs, contact the author and/or post your idea to the Usenet group comp.lang.perl.modules. If you write a useful, generalized sorting module, please contribute it to CPAN! 

The holy grail of Perl data transforms

When I presented this material to the Seattle Perl Users Group, I issued the following challenge:

"Find a practical problem that can be effectively solved by a statement using map, sort and grep. The code should run faster and be more compact than alternative solutions."

Within minutes Brian Ingerson came forward with the following Unix one-liner:


Print sorted list of words with 4 or more consecutive vowels

perl -e 'print sort map { uc } grep /[aeiou]{4}/, <>' \
   /usr/dict/words
AQUEOUS
DEQUEUE
DEQUEUED
DEQUEUES
DEQUEUING
ENQUEUE
ENQUEUED
ENQUEUES
HAWAIIAN
OBSEQUIOUS
PHARMACOPOEIA
QUEUE
QUEUED
QUEUEING
QUEUER
QUEUERS
QUEUES
QUEUING
SEQUOIA
(Pharmacopoeia is an official book containing a list of drugs with articles on their preparation and use.)

Print the canonical sort order

While reading the perllocale man page, I came across this handy example of a holy grail, which is more natural and useful than the example above. This prints the canonical order of characters used by the cmp, lt, gt, le and ge operators.
print +(sort grep /\w/, map { chr } 0 .. 255), "\n";
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz
The map converts the numbers to their ASCII value; the grep gets rid of special characters and funky control characters that mess up your screen. The plus sign helps Perl interpret the syntax print (...) correctly.

This example shows that, in this case, the expression '_' lt 'a' is TRUE. If your program has the "use locale" pragma, the canonical order will depend on your current locale.

Bibliography

Grep

Cozens, S., Function of the month - grep

Wall, L., et al, Grep function man page


Map

Cozens, S., Function of the month - map

Hall, J. N., Without map you can only grep your way around

Wall, L., et al, Map function man page


Sort

Christiansen, T., Far more than everything you've ever wanted to know about sorting

Christiansen, T., and Torkington, N., 1998, The Perl Cookbook, Recipe 4.15: Sorting a list by computable field, O'Reilly and Assoc.

Guttman, U. and Rosler, L., 1999, A fresh look at efficient sorting

Hall, J. N., More about the Schwartzian transform

Hall, J. N., 1998, Effective Perl Programming, p. 48., Addison-Wesley.

Knuth, D. E., 1998, The Art of Computer Programming: Sorting and Searching, 2nd ed., chap. 5, Addison-Wesley.

Wall, L., et al, Sort function man page

Wall, L., et al, Perl FAQ entry for sort ("perldoc -q sort")


<a href="http://www.hidemail.de/blog/perl_tutor.shtml">Perl: grep, map and sort</a>
