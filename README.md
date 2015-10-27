# Gumbo perl6 binding

## Introduction

From the Gumbo project page :

Gumbo is an implementation of the HTML5 parsing algorithm implemented as a pure C99 library with no outside dependencies. It's designed to serve as a building block for other tools and libraries such as linters, validators, templating languages, and refactoring and analysis tools.


This binbiding only provide a parse-html function that call the main function of gumbo (gumbo_parse) and return a XML::Document object

## Example

```perl
use Gumbo;

my $html = q:to/END_HTML/;
<html>
<head>
        <title>Fancy</title>
</head>
<body>
        <p>It's fancy</p>
</body>
</html>

END_HTML

my $xmldoc = parse-html($html);

say $xmldoc.root.elements(:TAG<p>, :RECURSE<5>)[0][0]; #It's fancy

\# The Gumbo module provide you two variables to look at the duration of the process

say "Time spend in the gumbo_parse call     : ", $gumbo_last_c_parse_duration;
say "Time spend creating the XML::Document, : ", $gumbo_last_xml_creation_duration;

```

## Warning

The XML::Document include all whitespace. That why in the previous example, the 'p' element is not acceded with $xmldoc.root[1][0][0]

Etheir use the XML::Element.elements method (eg: $xmldoc.root.elements[1].elements[0][0]) or the search form of the method.

## Contact

Contact me at scolinet@gmail.com if you have any question.
