# micro_exiftool

micro_exiftool is an extremely basic ruby wrapper for the [ExifTool](http://www.sno.phy.queensu.ca/~phil/exiftool/) command line tool.

It allows to read and write metadata for all files supported by ExifTools, such as JPG or MP3.

This was the simplest tool that fit my own needs and deliberately tries to do as little as possible.

If you need a more complete implementation, you might want to take a look at [mini_exiftool](https://github.com/janfri/mini_exiftool).


## Installation

You need to have exiftool installed and on your PATH.

Add this line to your application's Gemfile:

```ruby
gem 'micro_exiftool'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install micro_exiftool

## Usage

All attributes are plain strings.


### Read attributes

```
file = MicroExiftool::File.new(path_to_file)

file.attributes               # hash including all attributes returned by exiftool
file['EXIF:Copyright']        # the EXIF copyright field
file['IPTC:CopyrightNotice']  # the IPTC copyright field
```

### Update attributes

```
file = MicroExiftool::File.new(path_to_file)

file.update!(
  'EXIF:Copyright' => 'new EXIF copyright',
  'IPTC:CopyrightNotice' => 'new IPTC copyright',
)
```

This will update the attributes of the file in place.

Note that there is (currently) no validation that the fields are actually valid metadata fields. If you set an unknown field, it will be silently ignored.


## Author

Tobias Kraze from [makandra](http://makandra.com/)


## License

Licensed under the MIT license.
