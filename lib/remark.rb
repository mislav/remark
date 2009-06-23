require 'hpricot'

class Remark
  def initialize(source)
    @doc = Hpricot(source)
  end
  
  def to_markdown
    remark_children(@doc).join("\n\n")
  end
  
  IGNORE = %w(script head style)
  
  private
  
  def valid_attributes?(elem)
    case elem.name
    when 'a'
      (elem.attributes.keys - %w(title)) == %w(href)
    when 'img'
      (elem.attributes.keys - %w(title)).sort == %w(alt src)
    else
      elem.attributes.empty?
    end
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
      item.to_s.gsub(/\n+/, ' ') unless item.to_s =~ /\A\s*\Z/
    elsif item.elem?
      if IGNORE.include?(item.name)
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
    when 'p'
      remark_inline(elem)
    when /^h([1-6])$/
      ('#' * $1.to_i) + ' ' + remark_inline(elem)
    when 'ul', 'ol'
      remark_list(elem)
    when 'li'
      remark_inline(elem)
    when 'pre'
      elem.inner_text.gsub(/^/, ' '*4)
    when 'em'
      "_#{elem.inner_text}_"
    when 'strong'
      "**#{elem.inner_text}**"
    when 'code'
      "`#{elem.inner_text}`"
    when 'a'
      remark_link(elem.inner_html, elem.attributes['href'], elem.attributes['title'])
    when 'img'
      '!' + remark_link(elem.attributes['alt'], elem.attributes['src'], elem.attributes['title'])
    when 'blockquote'
      remark_children(elem).join("\n\n").gsub(/^/, '> ')
    when 'br'
      ' ' + elem.inner_html
    else
      elem
    end
  end
  
  def remark_link(text, href, title = nil)
    title_markup = title ? %( "#{title}") : ''
    "[#{text}](#{href}#{title_markup})"
  end
  
  def remark_inline(elem)
    remark_children(elem).join('').gsub(/\s{2,}/, ' ')
  end
  
  def remark_list(list)
    unordered = list.name == 'ul'
    marker = unordered ? '*' : 0
    remark_children(list).map do |item|
      if unordered
        marker + ' ' + item
      else
        (marker += 1).to_s + '. ' + item
      end
    end.join("\n")
  end
end
