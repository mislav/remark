Remark — HTML→Markdown tool
===========================

<i>Remark</i> parses HTML and delivers proper Markdown.

    $ [sudo] gem install remark

Usage
-----

From command-line:

    remark path/to/file.html
    
or by STDIN:
    
    echo "..." | remark

You can try feeding it a document from the web:

    curl -s daringfireball.net/projects/markdown/basics | remark > result.markdown

See how it does.

If you've cloned the repository, invoke the binary like this:

    ruby -Ilib -rubygems bin/remark spec/sample.html

And this is how you use it from Ruby code:

    Remark.new('<h1>My document</h1><p>Some content</p>').to_markdown
