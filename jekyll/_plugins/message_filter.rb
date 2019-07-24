module Jekyll
  module MessageFilter
    def message(msg)
      # bad_file = @context.registers[:page]['path']
      # err_msg = "On #{bad_file}: #{msg}"
      puts msg
    end
  end
end

Liquid::Template.register_filter(Jekyll::MessageFilter)
