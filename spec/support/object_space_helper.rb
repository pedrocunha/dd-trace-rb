# typed: false

require 'objspace'

module ObjectSpaceHelper
  class << self
    def estimate_bytesize_supported?
      ::ObjectSpace.respond_to?(:memsize_of) &&
        ::ObjectSpace.memsize_of(Object.new) > 0 # Sanity check for non-CRuby
    end

    def estimate_bytesize(object)
      return nil unless estimate_bytesize_supported?

      # Rough calculation of bytesize; not very accurate.
      object.instance_variables.inject(::ObjectSpace.memsize_of(object)) do |sum, var|
        sum + ::ObjectSpace.memsize_of(object.instance_variable_get(var))
      end
    end

    def open_file_descriptors
      ObjectSpace.each_object(::IO).to_a.sort_by(&:object_id).select do |io|
        begin
          !io.closed?
        rescue IOError
          # Rescue for "uninitialized stream" errors.
          false
        end
      end
    end
  end
end
