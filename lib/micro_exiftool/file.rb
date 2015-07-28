require 'open3'
require 'json'

module MicroExiftool

  class NoSuchFile < StandardError; end
  class ExifToolError < StandardError; end


  class File

    def initialize(path)
      @path = path.to_s
      unless ::File.exist?(@path)
        raise NoSuchFile.new("No such file: #{@path}")
      end
    end

    def [](key)
      file_attributes[key]
    end

    def attributes
      file_attributes.dup
    end

    def update!(new_attributes)
      update_json = [new_attributes.merge('SourceFile' => @path)].to_json

      run_exiftool(
        '-P',                     # dont change timestamp of file
        '-G0',                    # prefix all attributes with "EXIF:", "ITCP:" etc
        '-overwrite_original',    # dont make a backup copy
        '-j=-',                   # read new attributes from stdin as json
        stdin_data: update_json
      )

      @file_attributes.merge!(new_attributes) if defined? @file_attributes
      true
    end


    private

    def file_attributes
      @file_attributes ||= load_attributes
    end

    def load_attributes
      result = run_exiftool('-G0', '-j')
      JSON.parse(result).first
    end

    def run_exiftool(*arguments)
      options = arguments.last.is_a?(Hash) ? arguments.pop : {}
      stdout_string, stderr_string, status = Open3.capture3('exiftool', @path, *arguments, options)
      unless status.exitstatus == 0
        raise ExifToolError.new("Error running exiftool:\n#{stderr_string}")
      end
      stdout_string
    end

  end
end
