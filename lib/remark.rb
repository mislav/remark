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
      item.to_s.gsub(/\n+/, ' ') unless item.to_s =~ /^\s*$/
    elsif item.elem?
      if IGNORE.include?(item.name)
        nil
      elsif item.attributes.empty?
        remark_element(item)
      else
        item
      end
    end
  end
  
  def remark_element(elem)
    case elem.name
    when 'p'
      elem.inner_text
    when /^h([1-6])$/
      ('#' * $1.to_i) + ' ' + elem.inner_text
    when 'ul', 'ol'
      remark_list(elem)
    when 'li'
      elem.inner_text
    when 'pre'
      elem.inner_text.gsub(/^/, ' '*4)
    else
      elem
    end
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
