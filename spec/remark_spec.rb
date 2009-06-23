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
  
  it "should preserve elements in remarked blocks" do
    remark("<p>Foo <ins>bar</ins></p>").should == 'Foo <ins>bar</ins>'
    remark("<h2>Foo <ins>bar</ins></h2>").should == '## Foo <ins>bar</ins>'
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
    remark("<pre><code>def foo\n  &lt;bar&gt;\nend</code></pre>").should == "    def foo\n      <bar>\n    end"
  end
  
  it "should remark inline elements" do
    remark("<p>I'm so <strong>strong</strong></p>").should == "I'm so **strong**"
    remark("<p>I'm so <em>emo</em></p>").should == "I'm so _emo_"
    remark("<p>Write more <code>code</code></p>").should == "Write more `code`"
    remark("<ul><li><em>Inline</em> stuff in <strong>lists</strong></li></ul>").should == "* _Inline_ stuff in **lists**"
    remark("<h1>Headings <em>too</em></h1>").should == '# Headings _too_'
  end
  
  it "should support hyperlinks" do
    remark("<p>Click <a href='http://mislav.uniqpath.com'>here</a></p>").should ==
      "Click [here](http://mislav.uniqpath.com)"
  end
  
  it "should support blockquotes" do
    remark("<blockquote>Cogito, ergo sum</blockquote>").should == '> Cogito, ergo sum'
    remark("<blockquote><p>I think</p><p>therefore I am</p></blockquote>").should == "> I think\n> \n> therefore I am"
  end
end

