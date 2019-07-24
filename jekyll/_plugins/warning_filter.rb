module Jekyll
  module WarningFilter
    def warn(msg)
      # bad_file = @context.registers[:page]['path']
      # err_msg = "On #{bad_file}: #{msg}"
      puts msg
    end
  end
end

Liquid::Template.register_filter(Jekyll::WarningFilter)
