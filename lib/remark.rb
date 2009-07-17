require 'hpricot'

class Remark
  def initialize(source, options = {})
    @doc = Hpricot(source)
    @options = options
    @links = []
    @ignored_elements = nil
  end
  
  def to_markdown
    parent = scope
    collect_ignored_elements(parent)
    remark_block(parent) + (inline_links?? '' : "\n\n\n" + output_reference_links)
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
    @options[:inline_links]
  end
  
  def output_reference_links
    references = []
    @links.each_with_index do |(href, title), i|
      references << "[#{i + 1}]: #{href}#{title ? '  ' + title.inspect : ''}"
    end
    references.join("\n")
  end
  
  IGNORE = %w(script head style)
  BLOCK = %w(p blockquote h1 h2 h3 h4 h5 h6 pre)
  
  private
  
  def valid_attributes?(elem)
    case elem.name
    when 'div'
      true
    when 'a'
      (elem.attributes.keys - %w(title)) == %w(href)
    when 'img'
      (elem.attributes.keys - %w(title)).sort == %w(alt src)
    else
      elem.attributes.empty?
    end
  end
  
  def ignore_element?(elem)
    IGNORE.include?(elem.name) or (@ignored_elements and @ignored_elements.include?(elem))
  end
  
  def collect_ignored_elements(scope)
    if @options[:ignores]
      @ignored_elements = @options[:ignores].map do |expr|
        scope.search(expr).to_a
      end.flatten.uniq
    end
  end
  
  def remark_block(elem)
    remark_children(elem).
      reject { |item| item.blank? }.
      join("\n\n")
  end
  
  def remark_children(node)
    remarked = []
    node.children.each do |item|
      result = remark_item(item)
      remarked << result if result
    end
    remarked
  end
  
  def remark_item(item)
    if item.text?
      item.to_s.gsub(/\n+/, ' ') unless item.blank?
    elsif item.elem?
      if ignore_element?(item)
        nil
      elsif valid_attributes?(item)
        remark_element(item)
      else
        item
      end
    end
  end
  
  def remark_element(elem)
    case elem.name
    when 'div'
      remark_children(elem)
    when 'p'
      remark_inline(elem)
    when /^h([1-6])$/
      ('#' * $1.to_i) + ' ' + remark_inline(elem)
    when 'ul', 'ol'
      remark_list(elem)
    when 'li'
      elem.children.any? { |e| e.elem? and BLOCK.include?(e.name) } ?
        remark_block(elem).indent : remark_inline(elem)
    when 'pre'
      elem.inner_text.rstrip.indent
    when 'em'
      "_#{remark_inline(elem)}_"
    when 'strong'
      "**#{remark_inline(elem)}**"
    when 'code'
      code = elem.inner_text
      code.index('`') ? "`` #{code} ``" : "`#{code}`"
    when 'a'
      remark_link(remark_inline(elem), elem.attributes['href'], elem.attributes['title'])
    when 'img'
      '!' + remark_link(elem.attributes['alt'], elem.attributes['src'], elem.attributes['title'], true)
    when 'blockquote'
      remark_children(elem).join("\n\n").indent('> ')
    when 'br'
      "  \n" + elem.inner_html
    else
      elem
    end
  end
  
  def remark_link(text, href, title = nil, inline = inline_links?)
    if inline
      title_markup = title ? %( "#{title}") : ''
      "[#{text}](#{href}#{title_markup})"
    else
      if existing = @links.find { |h, t| href == h }
        num = @links.index(existing) + 1
      else
        @links << [href, title]
        num = @links.length
      end
      "[#{text}][#{num}]"
    end
  end
  
  def remark_inline(elem)
    remark_children(elem).join('').strip.gsub(/ {2,}(?!\n)/, ' ').gsub(/(\n) +/, '\1')
  end
  
  def remark_list(list)
    unordered = list.name == 'ul'
    marker = unordered ? '*' : 0
    nested = false
    
    items = remark_children(list).map do |item|
      current = unordered ? marker : "#{marker += 1}."
      if item =~ /\A\s/
        nested = true
        item[0, current.length] = current
        item
      else
        current + ' ' + item
      end
    end
    
    items.join("\n" * (nested ? 2 : 1))
  end
end

Object.class_eval do
  def blank?() false end
end

NilClass.class_eval do
  def blank?() true end
end

String.class_eval do
  def blank?
    self.empty? or !!(self =~ /\A\s+\Z/)
  end
  
  def squish
    self.strip.gsub!(/\s+/, ' ')
  end
  
  def indent(with = ' ' * 4)
    self.gsub(/^/, with)
  end
end

Hpricot::Text.class_eval do
  def blank?() to_s.blank? end
end
