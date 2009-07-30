require 'hpricot'
require 'remark/core_ext'

# this applies the default behavior to virtually all Hpricot classes
Hpricot::Node.module_eval do
  def to_markdown(options = {}) nil end
  def markdown_block?() false end
end

# nothing special to process on Text or CData
Hpricot::Text.module_eval do
  def to_markdown(options = {}) to_s.squeeze_whitespace end
end

Hpricot::CData.module_eval do
  def to_markdown(options = {}) to_s.squeeze_whitespace end
end

# elements that have children
Hpricot::Container.module_eval do
  def to_markdown(options = {})
    return '' unless self.children
    previous_was_block = false
    parent_is_block = self.markdown_block?
    
    # recurse over this element's children
    content = self.children.inject([]) do |all, child|
      current_is_block = child.markdown_block?
      child_content = child.to_markdown(options)
      
      # skip this node if its markdown is nil, empty or, in case
      # that the previous element was a block, all-whitespace
      unless child_content.nil? or child_content.empty? or (previous_was_block and child_content.blank?)
        # handle separating of adjacent markdown blocks with an empty line
        if not all.empty? and current_is_block or previous_was_block
          # strip trailing whitespace if we're opening a new block
          all.last.blank?? all.pop : all.last.rstrip!
          # guard against adding a newline at the beginning
          all << "\n\n" if all.any?
        end
        
        unless 'pre' == child.name
          # strip whitespace from the left if ...
          child_content.lstrip! if previous_was_block or # we're adjacent to a block
            (parent_is_block and child == self.children.first) or # this is the first child
            (not all.empty? and all.last =~ / ( \n)?$/) # we're following a space or a forced line break token
          
          
          # strip whitespace from the right if this is the last node in a block
          child_content.rstrip! if parent_is_block and self.children.last == child
        end
        
        all << child_content
      end
      
      previous_was_block = current_is_block
      all
    end
    
    result = content.join('')
    return result
  end
end

# elements without children
Hpricot::Leaf.module_eval do
  def to_markdown(options = {})
    inner_text.squeeze_whitespace if elem?
  end
end

Hpricot::Elem.module_eval do
  IGNORE = %w(script head style)
  ALLOWED_EMPTY = %w(img br hr )
  MARKDOWN_BLOCK = %w(p blockquote h1 h2 h3 h4 h5 h6 pre hr)
  MARKDOWN_INLINE = %w(em strong code a img br)
  MARKDOWN_RECOGNIZED = MARKDOWN_BLOCK + MARKDOWN_INLINE + %w(div)
  HTML_BLOCK = MARKDOWN_BLOCK + %w(ul ol dl div noscript form table address fieldset)
  
  def to_markdown(options = {})
    return nil if markdown_ignored?(options)
    return '' if markdown_empty?
    return to_s unless markdown_supported_attributes?

    case name
    when 'div', 'noscript'
      super
    when 'p'
      super
    when /^h([1-6])$/
      ('#' * $1.to_i) + ' ' + super
    when 'ul', 'ol'
      remark_list(options)
    when 'li'
      content = super
      content = content.indent if children.any? { |e| e.markdown_block? }
      content
    when 'pre'
      inner_text.rstrip.indent
    when 'em'
      "_#{super}_"
    when 'strong'
      "**#{super}**"
    when 'code'
      code = inner_text
      code.index('`') ? "`` #{code} ``" : "`#{code}`"
    when 'a'
      remark_link(super, attributes['href'], attributes['title'], options)
    when 'img'
      '!' + remark_link(attributes['alt'], attributes['src'], attributes['title'], :reference_links => false)
    when 'blockquote'
      super.indent('> ')
    when 'br'
      "  \n" + inner_html
    else
      to_s
    end
  end
  
  def remark_list(options = {})
    unordered = self.name == 'ul'
    marker = unordered ? '*' : 0
    nested = false
    
    items = self.children_of_type('li').map do |item|
      item = item.to_markdown(options)
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
  
  def markdown_block?
    HTML_BLOCK.include?(name)
  end
  
  def markdown_recognized?
    MARKDOWN_RECOGNIZED.include?(name)
  end
  
  protected
  
  def markdown_ignored?(options)
    IGNORE.include?(name) or
      (options[:ignored_elements] and options[:ignored_elements].include?(self))
  end
  
  def markdown_empty?
    empty? and markdown_recognized? and not ALLOWED_EMPTY.include?(name)
  end
  
  def markdown_supported_attributes?
    case name
    when 'div'
      true
    when 'a'
      attribute_names_match?('href', 'title')
    when 'img'
      attribute_names_match?(%w(alt src), 'title')
    when 'ol', 'ul'
      attributes.empty? and children.all? do |item|
        not item.elem? or (item.name == 'li' and item.attributes.empty?)
      end
    else
      attributes.empty?
    end
  end
  
  def attribute_names_match?(only, optional = nil)
    names = attributes.keys.sort
    names -= Array(optional) if optional
    names == Array(only)
  end
  
  def remark_link(text, href, title = nil, options = {})
    if options[:reference_links]
      if existing = options[:links].find { |h, t| href == h }
        num = options[:links].index(existing) + 1
      else
        options[:links] << [href, title]
        num = options[:links].length
      end
      "[#{text}][#{num}]"
    else
      title_markup = title ? %( "#{title}") : ''
      "[#{text}](#{href}#{title_markup})"
    end
  end
end
