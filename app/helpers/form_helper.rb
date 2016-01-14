module FormHelper
    def custom_form_for(object, *args, &block)
      options = args.extract_options!
      simple_form_for(object, *(args << options.merge(builder: CustomFormBuilder)), &block)
    end
end