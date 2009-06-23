Remark
======

A Ruby tool that parses HTML and delivers proper Markup.

Usage
-----

From command-line:

    ruby -Ilib -rubygems bin/remark spec/sample.html

(You can also give input to STDIN instead as file argument.)

From Ruby code:

    Remark.new('<h1>My document</h1><p>Some content</p>').to_markdown
