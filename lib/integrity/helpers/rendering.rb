module Integrity
  module Helpers
    module Rendering
      def stylesheet_hash
        @_hash ||= Digest::MD5.file(
          options.views + "/integrity.sass").tap { |file| file.hexdigest }
      end

      def show(view, options={})
        @title = breadcrumbs(*options[:title])
        haml view
      end

      def partial(template, locals={})
        haml("_#{template}".to_sym, :locals => locals, :layout => false)
      end
    end
  end
end
