require 'remark'

describe Remark do
  def remark(source, options = {})
    options = {:reference_links => false}.merge(options)
    described_class.new(source, options).to_markdown
  end
  
  it "should let through text content" do
    remark("Foo bar").should == 'Foo bar'
    remark("Foo bar\nbaz").should == 'Foo bar baz'
  end
  
  it "should preserve elements in remarked blocks" do
    remark("<p>Foo <ins>bar</ins></p>").should == 'Foo <ins>bar</ins>'
    remark("<h2>Foo <ins>bar</ins></h2>").should == '## Foo <ins>bar</ins>'
  end
  
  it "should unescape HTML entities" do
    remark("Foo&amp;bar").should == 'Foo&bar'
    remark("<p>If you&#8217;re doing all your development on the &#8220;master&#8221; branch, you&#8217;re not using git").should == "If you’re doing all your development on the “master” branch, you’re not using git"
  end
  
  it "should leave unknown elements intact" do
    remark(<<-HTML).should == "Foo\n\n<table>data</table>\n\nBar"
      <p>Foo</p>
      <table>data</table>
      <p>Bar</p>
    HTML
  end
  
  describe "whitespace" do
    it "should strip excess whitespace" do
      remark(<<-HTML).should == "Foo bar"
        <p>
          Foo
          bar
        </p>
      HTML
    end
  
    it "should strip whitespace in text nodes between processed nodes" do
      remark(<<-HTML).should == "Foo\n\nbar\n\nBaz"
        <p>Foo</p>
        
             bar
        <p>Baz</p>
      HTML
    end
  end
  
  describe "lists" do
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
  
    it "should support lists with nested content" do
      remark(<<-HTML).should == "*   foo\n    \n    bar\n\n*   baz"
        <ul>
          <li><p>foo</p><p>bar</p></li>
          <li><p>baz</p></li>
        </ul>
      HTML
    end
  
    it "should output malformed lists as HTML" do
      remark(<<-HTML).should == "<ul>\n          <span>bar</span>\n        </ul>"
        <ul>
          <span>bar</span>
        </ul>
      HTML
    end
  end
  
  it "should support preformatted blocks" do
    remark("<pre>def foo\n  bar\nend</pre>").should == "    def foo\n      bar\n    end"
    remark("<pre><code>def foo\n  &lt;bar&gt;\nend</code></pre>").should == "    def foo\n      <bar>\n    end"
    remark("<pre>def foo\n</pre>").should == "    def foo"
  end
  
  describe "inline" do
    it "should remark inline elements" do
      remark("<p>I'm so <strong>strong</strong></p>").should == "I'm so **strong**"
      remark("<p>I'm so <em>emo</em></p>").should == "I'm so _emo_"
      remark("<ul><li><em>Inline</em> stuff in <strong>lists</strong></li></ul>").should == "* _Inline_ stuff in **lists**"
      remark("<h1>Headings <em>too</em></h1>").should == '# Headings _too_'
    end
  
    it "should handle nested inline elements" do
      remark("<p>I <strong>love <code>code</code></strong></p>").should == "I **love `code`**"
      remark("<p>I <a href='#'>am <em>fine</em></a></p>").should == "I [am _fine_](#)"
    end
  end
  
  describe "hyperlinks" do
    it "should support hyperlinks" do
      remark("<p>Click <a href='http://mislav.uniqpath.com'>here</a></p>").should ==
        "Click [here](http://mislav.uniqpath.com)"
      remark("<a href='/foo' title='bar'>baz</a>").should == '[baz](/foo "bar")'
    end
  
    it "should have reference-style hyperlinks" do
      remark("<p>Click <a href='foo' title='mooslav'>here</a> and <a href='bar'>there</a></p>", :reference_links => true).should ==
        "Click [here][1] and [there][2]\n\n\n[1]: foo  \"mooslav\"\n[2]: bar"
      remark("<p>Click <a href='foo'>here</a> and <a href='foo'>there</a></p>", :reference_links => true).should ==
        "Click [here][1] and [there][1]\n\n\n[1]: foo"
      remark("", :reference_links => true).should == ""
    end
  end
  
  it "should support ignores" do
    remark("<p>Foo <span>bar</span> baz</p>", :ignores => ['span']).should == "Foo baz"
  end
  
  describe "scoping" do
    before do
      @html = <<-HTML
        <html>
          <body>
            <div id="div1">
              <p>Only 1 paragraph</p>
            </div>
            <div id="div3">
              <p>Wow, 3 paragraphs</p>
              <p>This must be where the content is</p>
              <p>I'm sure</p>
            </div>
            <div id="div2">
              <p>Only 2 paragraphs</p>
              <p>How disappointing</p>
            </div>
          </body>
        </html>
      HTML
    end
    
    it "should scope to the most likely element that holds content" do
      remark(@html).should == "Wow, 3 paragraphs\n\nThis must be where the content is\n\nI'm sure"
    end
    
    it "should scope to the explicit scope" do
      remark(@html, :scope => '#div2').should == "Only 2 paragraphs\n\nHow disappointing"
    end
  end
end
