module ApplicationHelper

	def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def set_title(title, options={})
    base_title = "FactorySync"
    prefix = options[:prefix] || ""
    suffix = options[:suffix] || ""
    provide :title, "#{base_title} | #{title}"
    provide :page_title do
      @content = content_tag(:span, prefix)
      @content << content_tag(:strong, title)        
      @content << content_tag(:span, suffix)
    end
  end

  def get_item_id
    logger.debug "cookies  = #{cookies[:item_id]}"
    Item.id_by_existence(cookies[:item_id])
  end
  
  def flatten_hash(hash = params, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end

    flat_hash
  end

  def flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup 
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end

  def hash_as_hidden_fields(hash = params)
    hidden_fields = []
    flatten_hash(hash).each do |name, value|
      value = [value] if !value.is_a?(Array)
      value.each do |v|
        hidden_fields << hidden_field_tag(name, v.to_s, :id => nil)          
      end
    end

    hidden_fields.join("\n")
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def set_width(lg, md)
    @liquid = lg == 12
    @container = @liquid ? "container-liquid" : "container"
    offset_lg = ((12 - lg) / 2 ).floor
    offset_md = ((12 - md) / 2 ).floor
    full_class = "col-md-#{md} col-lg-#{lg} col-md-offset-#{offset_md} col-lg-offset-#{offset_lg}"       
    @width = @liquid ? "full-fluid" : full_class
    @hidden_lg = "hidden-md hidden-lg" if @liquid
    @hidden_sm = "hidden-xs hidden-sm" if @liquid
    @menu = true
    @title = true
    logger.debug "@liquid = #{@liquid}, @container = #{@container}, @width = #{@width}" 
    logger.debug "@hidden_lg = #{@hidden_lg}, @hidden_sm = #{@hidden_sm}"
  end

end
