require 'remark'

describe Remark do
  def remark(source)
    described_class.new(source).to_markdown
  end
  
  it "should let through text content" do
    remark("Foo bar").should == 'Foo bar'
    remark("Foo bar\nbaz").should == 'Foo bar baz'
  end
  
  it "should split paragraphs with an empty line" do
    remark("<p>Foo bar</p>").should == 'Foo bar'
    remark("<p>Foo bar</p><p>baz").should == "Foo bar\n\nbaz"
    remark("<p>Foo bar</p>baz").should == "Foo bar\n\nbaz"
  end
  
  it "should output title syntax" do
    remark("<h1>Foo bar</h1>").should == '# Foo bar'
    remark("<h2>Foo bar</h2>").should == '## Foo bar'
  end
  
  it "should unescape HTML entities" do
    remark("Foo&amp;bar").should == 'Foo&bar'
    remark("<p>If you&#8217;re doing all your development on the &#8220;master&#8221; branch, you&#8217;re not using git").should == "If you’re doing all your development on the “master” branch, you’re not using git"
  end
  
  it "should ignore tags without user-facing content" do
    remark("<script>foo</script>").should == ''
    remark("<head>foo</head>").should == ''
  end
  
  it "should leave known elements with attributes intact" do
    remark("<p class='notice'>Kittens attack!</p>").should == '<p class="notice">Kittens attack!</p>'
  end
  
  it "should leave unknown elements intact" do
    remark(<<-HTML).should == "Foo\n\n<table>data</table>\n\nBar"
      <p>Foo</p>
      <table>data</table>
      <p>Bar</p>
    HTML
  end
  
  it "should support lists" do
    remark(<<-HTML).should == "* foo\n* bar"
      <ul>
        <li>foo</li>
        <li>bar</li>
      </ul>
    HTML
    
    remark(<<-HTML).should == "1. foo\n2. bar"
      <ol>
        <li>foo</li>
        <li>bar</li>
      </ol>
    HTML
  end
  
  it "should support preformatted blocks" do
    remark("<pre>def foo\n  bar\nend</pre>").should == "    def foo\n      bar\n    end"
    remark("<pre><code>def foo\n  bar\nend</code></pre>").should == "    def foo\n      bar\n    end"
  end
end
