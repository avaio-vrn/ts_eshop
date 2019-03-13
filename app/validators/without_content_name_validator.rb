class WithoutContentNameValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if ::Configuration.loaded_get('main'.freeze, 'tovar_model_without_content_name'.freeze).nil? && value.blank?
      object.errors[attribute] << (options[:message] || :blank)
    end
  end
end
