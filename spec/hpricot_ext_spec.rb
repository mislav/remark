# encoding: utf-8
require 'rspec'
require 'remark/hpricot_ext'

describe Hpricot, "remark extensions" do
  before(:all) do
    @doc = Hpricot(<<-HTML.strip)
      <?xml version="moo" ?>
      <!DOCTYPE html>
      <html>
        <head>
          <title>Sample document</title>
        </head>
        <body>
          <h1>Sample <strong>Remark</strong> document</h1>
          <p>
            A paragraph with <em>nested</em> <strong>content</strong>
            and <i>Remark</i>-supported elements.
          </p>
          
          <a name="content"> </a>
          <h2>The content</h2>
          <div id="content">
            <p>First</p>
            <p>Second</p>
            Some content
            <em>in-between</em>
            <p>Third</p>
          </div>
          <p class="foo">I has classname</p>
          
          <div id="empty"></div>
          <blockquote>
            Some famous quote
            <blockquote>Nested famous quote</blockquote>
          </blockquote>
          <div class="code">
            <p>Sample code:</p>
            <pre>def preformatted
  text
end
            </pre>
          </div>
          <img src='moo.jpg' alt='cow'>
          <img src='moo.jpg' alt='cow' width='16'>
          
          <code>simple</code> <code>comp ` lex</code> <code>&lt;tag&gt;</code>
          
          <div id="br">
            <p>Foo<br>bar</p>
            <p>Foo<br>
            bar <code>baz</code></p>
            <p>Foo</p><br><br><p>Bar</p><br>
          </div>

          <hr>

          <ul>
            <li>First</li>
            <li>Second</li>
          </ul>
          <ol>
            <li>First</li>
            <li>Second</li>
          </ol>
        </body>
      </html>
    HTML
  end
  
  def remark(elem, options = {})
    (String === elem ? @doc.at(elem) : elem).to_markdown(options)
  end
  
  it "should return empty string for empty document" do
    remark(Hpricot('')).should == ''
  end
  
  it "should ignore DOCTYPE, HEAD and XML processing instructions" do
    remark('head').should be_nil
    remark(@doc.children[0]).should be_nil # doctype
    remark(@doc.children[2]).should be_nil # xmldecl
  end
  
  it "should have whitespace nodes respond to blank" do
    @doc.at('a[@name]').children.first.blank?
  end
  
  it "should support headings" do
    remark('h1').should == "# Sample **Remark** document"
    remark('h2').should == "## The content"
  end
  
  it "should support paragraphs" do
    remark('p').should == "A paragraph with _nested_ **content** and <i>Remark</i>-supported elements."
  end
  
  it "should split paragraphs with an empty line" do
    remark('#content').should == "First\n\nSecond\n\nSome content _in-between_\n\nThird"
  end
  
  it "should keep full HTML for paragraphs if they have attributes" do
    remark('p.foo').should == '<p class="foo">I has classname</p>'
  end
  
  it "should not break on empty DIV" do
    remark('#empty').should == ""
  end
  
  it "should support blockquotes" do
    remark('blockquote > blockquote').should == "> Nested famous quote"
    remark('blockquote').should == "> Some famous quote\n> \n> > Nested famous quote"
  end
  
  it "should support preformatted text" do
    remark('div.code').should == "Sample code:\n\n    def preformatted\n      text\n    end"
  end
  
  it "should support image tags" do
    remark('img[@alt]').should == '![cow](moo.jpg)'
    remark('img[@width]').should == '<img src="moo.jpg" alt="cow" width="16" />'
  end
  
  it "should support code spans" do
    remark('code').should == "`simple`"
    remark('code ~ code').should == "`` comp ` lex ``"
    remark('code ~ code ~ code').should == "`<tag>`"
  end
  
  it "should support BR" do
    remark('#br').should == "Foo  \nbar\n\nFoo  \nbar `baz`\n\nFoo\n\nBar"
  end
  
  it "should support unordered list" do
    remark('ul').should == "* First\n* Second"
  end
  
  it "should support ordered list" do
    remark('ol').should == "1. First\n2. Second"
  end

  it "renders horizontal rule" do
    remark('hr').should == "* * *"
  end
end

