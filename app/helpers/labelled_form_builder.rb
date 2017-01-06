# Form builder which builds consistently labelled fields.
# Heavily based on http://likeawritingdesk.com/2011/04/15/very-custom-form-builders-in-rails/
class LabelledFormBuilder < ActionView::Helpers::FormBuilder

  def submit(label = 'Save', *args)
    options = args.extract_options!
    new_class = options[:class] || "button"
    super(label, *(args << options.merge(:class => new_class)))
  end

  def add_another_class(cl, new_class)
    cl.blank? ? new_class : (cl + ' ' + new_class)
  end

  # Creates a labelled field with arbitrary content
  def field(label, &block)
    @template.content_tag("div",
                          @template.content_tag("label",
                                                label.to_s.humanize,
                                                :for => "#{@object_name}_#{label}", :class => 'field-label') +
                            @template.capture(&block),
                            class: 'field')
  end

  def form_id
    options[:html][:id]
  end
  
  def view_angle(label = :view_angle, initial_value = nil)
    field 'Viewing angle' do
      @template.select_tag(label, 
                           @template.options_for_select(ViewAngle.angle_names.map {|n| n.to_s.humanize}, initial_value.to_s),
                           { include_blank: true, form: form_id })
    end
  end

  def photo_state(column = :photo_state, initial_value = nil)
    # field 'State' do
    #     @template.javascript_tag do
    #       all_states = Photo.distinct.pluck(:state).reject(&:nil?)
    #       ('window.all_photo_states = ' + all_states.to_json + ';').html_safe
    #     end +
    #   @template.text_field_tag(column, initial_value, { form: form_id, title: 'State of specimen in this photo' })
    # end
    autocompleted_dbs_field('State', Photo.distinct.pluck(:state).reject(&:nil?), column,
                            title: 'State of specimen in this photo', initial_value: initial_value)
  end

  # Creates an autocompleted field with data obtained from a database query.
  # creates a global javascript value named "all_<column>s".
  # label - field label displayed on the form
  # data - list of possible field values
  # initial_value - initial field value
  # title - field title (tooltip)
  # column - name of column that data is stored in
  def autocompleted_dbs_field(label, data, column, title: nil, initial_value: nil)
    field label do
        @template.javascript_tag do
          ("window.all_#{column.to_s.parameterize.underscore}s = " + data.to_json + ';').html_safe
        end +
      @template.text_field_tag(column, initial_value, { form: form_id, title: title })
    end
  end

  def self.create_tagged_field(method_name)
    define_method(method_name) do |label, *args|
      options = args.extract_options!

      # Add a form attribute in case elements aren't enclosed by the form element
      options[:form] = form_id

      custom_label = options[:label] || label.to_s.humanize
      label_class = add_another_class(options[:label_class], 'field-label')

      if @object.class.validators_on(label).collect(&:class).include? ActiveModel::Validations::PresenceValidator
        label_class = add_another_class(label_class, "required")
      end

      @template.content_tag("div",
                            @template.content_tag("label",
                                                  custom_label,
                                                  :for => "#{@object_name}_#{label}", :class => label_class) +
                            super(label, *(args << options)),
                            class: 'field')
    end
  end

  field_helpers.each do |name|
    # Don't add labels to labels or hidden fields! That's just confusing
    create_tagged_field(name) unless [:label, :hidden_field].include? name
  end
  # I don't know why these aren't in field_helpers
  ['select', 'datetime_select', 'collection_select'].each do |name|
    create_tagged_field(name)
  end
  
end
