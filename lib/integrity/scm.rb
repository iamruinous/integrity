module Integrity
  module SCM
    class SCMUnknownError < StandardError; end

    def self.new(uri, *args)
      scm_class_for(uri).new(uri, *args)
    end

    def self.working_tree_path(uri)
      scm_class_for(uri).working_tree_path(uri)
    end

    private
      # test for Git first since a Git URL is more restrictive than a subversion
      # url
      def self.scm_class_for(uri)
        [ Git, Subversion ].each do |klass|
          return klass if klass.is_this_my_home?( uri )
        end
        raise SCMUnknownError, "could not find any SCM based on URI '#{uri.to_s}'"
      end
  end
end
