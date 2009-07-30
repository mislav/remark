require 'remark/hpricot_ext'

class Remark
  DEFAULT_OPTIONS = { :reference_links => true }
  
  def initialize(source, options = {})
    @doc = Hpricot(source)
    @options = DEFAULT_OPTIONS.merge options
    @links = []
    @ignored_elements = nil
  end
  
  def to_markdown
    parent = scope
    collect_ignored_elements(parent)
    links = @options[:links] = [] unless inline_links?
    result = parent.to_markdown(@options)
    result + (inline_links? || links.empty?? '' : "\n\n\n" + output_reference_links(links))
  end
  
  def scope
    if scope = @options[:scope]
      @doc.at(scope)
    elsif body = @doc.at('/html/body')
      candidates = (body / 'p').inject(Hash.new(0)) do |memo, para|
        memo[para.parent] += 1
        memo
      end.invert
      
      candidates[candidates.keys.max]
    else
      @doc
    end
  end
  
  def inline_links?
    !@options[:reference_links]
  end
  
  def output_reference_links(links)
    references = []
    links.each_with_index do |(href, title), i|
      references << "[#{i + 1}]: #{href}#{title ? '  ' + title.inspect : ''}"
    end
    references.join("\n")
  end
  
  private
  
  def ignore_element?(elem)
    IGNORE.include?(elem.name) or (@ignored_elements and @ignored_elements.include?(elem))
  end
  
  def collect_ignored_elements(scope)
    if @options[:ignores]
      @options[:ignored_elements] = @options[:ignores].map do |expr|
        scope.search(expr).to_a
      end.flatten.uniq
    end
  end
end
