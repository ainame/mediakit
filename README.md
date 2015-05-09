# Mediakit

mediakit is the libraries for ffmpeg and sox backed media manipulation something.
I've design this library for following purpose.

* have low and high level interfaces as you like use
* easy testing design by separation of concern

## Development Plan

* [x] low-level interface for ffmpeg
* [ ] high-level interface for ffmpeg
* [ ] low-level interface for sox
* [ ] high-level interface for sox

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mediakit'
```

And then execute:

    $ bundle

Or install it yourself as:

$ gem install mediakit

## Requirements

This library behave command wrapper in your script.
So it need each binary command file.

* latest ffmpeg which have ffprobe command

## Usage

### Low Level Usage

The low level means it's near command line usage.
This is a little bore interface for constructing options,
but can pass certain it.

```rb
driver = Mediakit::Drivers::FFmpeg.new
ffmpeg = Mediakit::Runners::FFmpeg.new(driver)

options = Mediakit::Runners::FFmpeg::Options.new(
  Mediakit::Runners::FFmpeg::Options::GlobalOption.new(
    't' => 100,
    'y' => true,
  ),
  Mediakit::Runners::FFmpeg::Options::InputFileOption.new(
    options: nil,
    path:    input,
  ),
  Mediakit::Runners::FFmpeg::Options::OutputFileOption.new(
    options: {
      'vf' => 'crop=320:320:0:0',
      'ar' => '44100',
      'ab' => '128k',
    },
    path:    output,
  ),
)
puts "$ ffmpeg #options"
puts ffmpeg.run(options)
```

### High Level Usage

TBD

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mediakit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## References

* [streamio/streamio-ffmpeg](https://github.com/streamio/streamio-ffmpeg)
* [ruby-av/av](https://github.com/ruby-av/av)
* [Xuggler](http://www.xuggle.com/xuggler/)
* [PHP-FFMpeg/PHP-FFMpeg](https://github.com/PHP-FFMpeg/PHP-FFMpeg)
