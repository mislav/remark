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
  
  def squeeze_whitespace
    self.tr("\n\t", ' ').squeeze(' ')
  end
  
  def indent(with = ' ' * 4)
    self.gsub(/^/, with)
  end
end

Hpricot::Text.module_eval do
  def blank?() to_s.blank? end
end
