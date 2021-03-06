module ApplicationHelper
  def labelled_form_for(name, *args, &block)
    options = args.extract_options!

    content_tag("div",
                form_for(name, *(args << options.merge(:builder => LabelledFormBuilder)), &block),
                :class => "labelled-form")
  end

  def col_values(model, column)
    model.distinct.pluck(column).reject(&:nil?)
  end

  def search_form(path, content = ''.html_safe, size = 30)
    form_tag(path, method: :get, id: :search) do
      content +
      content_tag('div',
                  # Note onfocus callback positions caret at end of the field
                  text_field_tag(:q, params[:q], autofocus: true, onfocus: "this.value = this.value;", size: size, class: :search) +
                  image_tag('/search.png', class: :search),
                  class: :search)
    end
  end

  def rating_block(photo, class_name = :rating)
    score = photo.rating || 0
    content_tag('div',
                (1..5).map do |i|
                  image_tag '/star.png', class: (i <= score ? 'on' : 'off'), 'data-rating' => i, 'data-photo-id' => photo.id
                end.join.html_safe,
                class: class_name)
  end

  # Returns HTML for an image displaying the thumbnail for the photo.
  # photo - the photo to display
  # delete_button - if true, a delete button will be displayed in the top-right corner of the image
  # rating_flags - if true, a row of stars will be displayed along the bottom of the image.
  #                Clicking on a star will change the rating of the photo.
  # scale - factor to scale the displayed image, relative to the actual image size
  # type - which photo representation should be displayed, e.g. :thumb, :photo
  # link_to_owner - if true, clicking on the photo will go to the owner page (e.g. specimen or site),
  #                 otherwise it will go to the photo page
  # lazy - if true, the image will be loaded lazily
  def photo_image(photo, delete_button: true, rating_flags: true, scale: 1, type: :thumb, link_to_owner: true, lazy: true)
    file = photo.file(type)
    delete_btn = delete_button ?
                   link_to(image_tag('/delete.png', class: :delete), [photo], method: :delete, data: { confirm: 'Are you sure?' }) :
                   ''.html_safe
    rating = rating_flags ? rating_block(photo) : nil
    # When linking to a photo, just play it if it is a video (parameter auto_play = "true")
    content_tag('div',
                delete_btn +
                rating +
                link_to(image_tag(file.path, size: file.size_s(scale), lazy: lazy), link_to_owner ? photo.imageable : photo_path(photo, auto_play: 'true')),
                class: 'photo-container')
  end
#                link_to(image_tag(file.path, size: file.size_s(scale), lazy: lazy), link_to_owner ? photo.imageable : photos_path(photo, auto_play: "true")),

  # Outputs a help button and popup
  # TODO generate unique ID
  def help_button(content)
    id = '1jhdskf'
    content_tag('div',
                content_tag('button', ' ? ', class: 'help-button', 'data-toggle-id' => id) +
                content_tag('div', content, class: :help, id: id),
                class: 'help-container')
  end

  # Options - :container_class, :content_class
  def textbox(label, options = {}, &block)
    content_tag('div',
                content_tag('div', label, class: :header) +
                content_tag('div', capture(&block), class: "content #{options[:content_class]}".strip),
                class: "textbox #{options[:container_class]}".strip)
  end

  def labelled_block(label, &block)
    content_tag("div",
                (label.nil? ? ''.html_safe : content_tag("label", label, class: 'field-label')) + capture(&block),
                class: 'field')
  end

  def block(&block)
    labelled_block(nil, &block)
  end

  # Creates a labelled field with arbitrary content
  def field_tag(label, &block)
    content_tag("div",
                content_tag("label",
                            label.to_s.humanize,
                            :for => "#{@object_name}_#{label}", :class => 'field-label') +
                capture(&block),
                class: 'field')
  end

  # Assumes node methods
  # #content
  # #parent
  # #children
  #
  # include_children and inner_content params are intended for recursive use only
  def tree_to_ul(node, ul_class = nil, include_children = true, inner_content = '')
    if node.blank?
      content_tag(:ul, inner_content)
    else
      html = content_tag(:li, 
                         node.content +
                         content_tag(:ul,
                                     inner_content.html_safe +
                                     (include_children ? node.children.map { |c| tree_to_li(c) }.join.html_safe : '')),
                         class: ul_class)
      tree_to_ul(node.parent, nil, false, html)
    end
  end

  def tree_to_li(node)
    content_tag(:li, node.content)
  end

  def taxon_to_ul(taxon, link = false, show_children = true, taxon_class = nil, show_common_names = false)
    if !taxon.nil?
      tree_to_ul TaxonTreeNode.new(taxon, link, show_children, show_common_names), taxon_class
    end
  end

  def scientific_classification(taxon, link = false, show_children = true, taxon_class = 'focal-taxon', show_common_names = false)
    if taxon
      textbox('Scientific classification', content_class: :txtr) do
        taxon_to_ul(taxon, link, show_children, taxon_class, show_common_names)
      end
    end
  end

  class TaxonTreeNode
    def initialize(taxon, link, show_children, show_common_names = false)
      @taxon = taxon
      @link = link
      @show_children = show_children
      @show_common_names = show_common_names
    end
    def parent
      @taxon.parent_taxon ? TaxonTreeNode.new(@taxon.parent_taxon, true, false, @show_common_names) : nil
    end
    def children
      if @show_children
        @taxon.sub_taxa.map { |c| TaxonTreeNode.new(c, true, false, @show_common_names) }
      else
        []
      end
    end
    def content
      html = @taxon.scientific_name_to_html.html_safe
      if @show_common_names && !@taxon.common_name.blank?
        html = "#{html} (#{@taxon.common_name})".html_safe
      end
      @link ? ActionController::Base.helpers.link_to(html, "/taxa/#{@taxon.id}/edit") : html
    end
  end

  ##################
  private

end
