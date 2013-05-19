require 'benchmark'
require 'spec_helper'

describe XmlSitemap::Map do
  let(:base_time)  { Time.gm(2011, 6, 1, 0, 0, 1) }
  let(:extra_time) { Time.gm(2011, 7, 1, 0, 0, 1) }

  describe '#new' do
    it 'should not allow empty domains' do
      expect { XmlSitemap::Map.new(nil) }.to raise_error ArgumentError
      expect { XmlSitemap::Map.new('') }.to raise_error ArgumentError
      expect { XmlSitemap::Map.new(' ') }.to raise_error ArgumentError
    end

    it 'should not allow empty urls' do
      map = XmlSitemap::Map.new('foobar.com')

      expect { map.add(nil)  }.to raise_error ArgumentError
      expect { map.add('')   }.to raise_error ArgumentError
      expect { map.add('  ') }.to raise_error ArgumentError
    end

    it 'should have a default home path' do
      map = XmlSitemap::Map.new('foobar.com')
      map.should_not be_empty
      map.items.first.target.should eq('http://foobar.com/')
    end

    context 'with :home => false' do
      it 'should have no home path' do
        map = XmlSitemap::Map.new('foobar.com', :home => false)
        map.should be_empty
      end
    end
  end

  describe '#add' do
    it 'should autocomplete path with no starting slash' do
      map = XmlSitemap::Map.new('foobar.com')
      map.add('about').target.should eq('http://foobar.com/about')
    end

    it 'should allow full urls in items' do
      map = XmlSitemap::Map.new('foobar.com', :root => false)
      map.add('https://foobar.com/path').target.should eq('https://foobar.com/path')
      map.add('path2').target.should eq('http://foobar.com/path2')
    end

    it 'should render urls in https mode' do
      map = XmlSitemap::Map.new('foobar.com', :secure => true)
      map.add('path').target.should eq('https://foobar.com/path')
    end

    it 'should set entry time' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      map.add('hello').updated.should eq(base_time)
      map.add('world', :updated => extra_time).updated.should eq(Time.gm(2011, 7, 1, 0, 0, 1))
    end

    it 'should raise Argument error if no time or date were provided' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      expect { map.add('hello', :updated => 5) }.
        to raise_error ArgumentError, "Time, Date, or ISO8601 String required for :updated!"
    end

    it 'should not raise Argument error if a iso8601 string is provided' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      expect { map.add('hello', :updated => "2011-09-12T23:18:49Z") }.not_to raise_error
      map.add('world', :updated => extra_time.utc.iso8601).updated.should eq(Time.gm(2011, 7, 1, 0, 0, 1).utc.iso8601)
    end

    it 'should not raise Argument error if a string is provided with :validate_time => false' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      expect { map.add('hello', :validate_time => false, :updated => 'invalid data') }.not_to raise_error
    end

    it 'should raise Argument error if an invalid string is provided' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      expect { map.add('hello', :updated => 'invalid data') }.
        to raise_error ArgumentError, "String provided to :updated did not match ISO8601 standard!"
    end

    it 'should not allow more than 50k records' do
      map = XmlSitemap::Map.new('foobar.com')
      expect {
        1.upto(50001) { |i| map.add("url#{i}") }
      }.to raise_error RuntimeError, 'Only up to 50k records allowed!'
    end

    it 'should not allow urls longer than 2048 characters' do
      long_string = (1..2049).to_a.map { |i| "a" }.join

      map = XmlSitemap::Map.new('foobar.com')
      expect {
        map.add(long_string)
      }.to raise_error ArgumentError, "Target can't be longer than 2,048 characters!"
    end
  end

  describe '#render' do

    before do
      opts1 = { :image_location => "http://foobar.com/foo.gif" }
      opts2 = { :image_location => "http://foobar.com/foo.gif", :image_title => "Image Title" }
      opts3 = { :image_location => "http://foobar.com/foo.gif", :image_caption => "Image Caption" }
      opts4 = { :image_location => "http://foobar.com/foo.gif", :image_license => "Image License" }
      opts5 = { :image_location => "http://foobar.com/foo.gif", :image_geolocation => "Image GeoLocation" }
      opts6 = { :image_location => "http://foobar.com/foo.gif",
                :image_title    => "Image Title",
                :image_caption  => "Image Caption",
                :image_license  => "Image License",
                :image_geolocation => "Image GeoLocation" }
      opts7 = { :video_thumbnail_location => "http://foobar.com/foo.jpg",
                :video_title => "Video Title",
                :video_description => "Video Description",
                :video_content_location => "http://foobar.com/foo.mp4" }
      opts8 = { :video_thumbnail_location => "http://foobar.com/foo.jpg",
                :video_title => "Video Title",
                :video_description => "Video Description",
                :video_player_location => "http://foobar.com/foo.swf" }
      opts9 = { :video_thumbnail_location => "http://foobar.com/foo.jpg",
                :video_title => "Video Title",
                :video_description => "Video Description",
                :video_content_location => "http://foobar.com/foo.mp4",
                :video_player_location => "http://foobar.com/foo.swf",
                :video_duration => 180,
                :video_expiration_date => Time.gm(2012, 6, 1, 0, 0, 1),
                :video_rating => 3.5,
                :video_view_count => 2500,
                :video_publication_date => base_time,
                :video_family_friendly => "no",
                :video_category => "Video Category",
                :video_restriction => "IT",
                :video_gallery_location => "http://foobar.com/foo.mpu",
                :video_price => 20,
                :video_requires_subscription => "no",
                :video_uploader => "Video Uploader",
                :video_platform => "web",
                :video_live => "no" }

      @image_map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      @image_map.add('/path?a=b&c=d&e=image support string', opts1)
      @image_map.add('/path?a=b&c=d&e=image support string', opts2)
      @image_map.add('/path?a=b&c=d&e=image support string', opts3)
      @image_map.add('/path?a=b&c=d&e=image support string', opts4)
      @image_map.add('/path?a=b&c=d&e=image support string', opts5)
      @image_map.add('/path?a=b&c=d&e=image support string', opts6)

      @video_map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      @video_map.add('/path?a=b&c=d&e=video', opts7)
      @video_map.add('/path?a=b&c=d&e=video', opts8)
      @video_map.add('/path?a=b&c=d&e=video', opts9)
    end

    it 'should have properly encoded entities' do
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)
      map.add('/path?a=b&c=d&e=sample string')
      map.render.split("\n")[2..-1].join("\n").should == fixture('encoded_map.xml').split("\n")[2..-1].join("\n")
    end

    context 'with builder engine' do
      it 'should have properly encoded entities' do
        map = XmlSitemap::Map.new('foobar.com', :time => base_time)
        map.add('/path?a=b&c=d&e=sample string')
        s = map.render(:builder)
        # ignore ordering of urlset attributes by dropping first two lines
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with image support' do
        s = @image_map.render(:builder)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_image_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with video support' do
        s = @video_map.render(:builder)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_video_map.xml').split("\n")[2..-1].join("\n")
      end
    end

    context 'with nokogiri engine' do
      it 'should have properly encoded entities' do
        map = XmlSitemap::Map.new('foobar.com', :time => base_time)
        map.add('/path?a=b&c=d&e=sample string')
        s = map.render(:nokogiri)
        # ignore ordering of urlset attributes by dropping first two lines
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with image support' do
        s = @image_map.render(:nokogiri)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_image_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with video support' do
        s = @video_map.render(:nokogiri)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_video_map.xml').split("\n")[2..-1].join("\n")
      end
    end

    context 'with string engine' do
      it 'should have properly encoded entities' do
        map = XmlSitemap::Map.new('foobar.com', :time => base_time)
        map.add('/path?a=b&c=d&e=sample string')
        s = map.render(:string)
        # ignore ordering of urlset attributes by dropping first two lines
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with image support' do
        s = @image_map.render(:string)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_image_map.xml').split("\n")[2..-1].join("\n")
      end

      it 'should have properly encoded entities with video support' do
        s = @video_map.render(:string)
        s.split("\n")[2..-1].join("\n").should == fixture('encoded_video_map.xml').split("\n")[2..-1].join("\n")
      end
    end
  end

  describe '#render_to' do
    it 'should save contents to the filesystem' do
      path = "/tmp/sitemap_#{Time.now.to_i}.xml"
      map = XmlSitemap::Map.new('foobar.com', :time => base_time) do |m|
        m.add('about')
        m.add('terms')
        m.add('privacy')
      end

      map.render_to(path)

      File.read(path).split("\n")[2..-1].join("\n").should eq(fixture('saved_map.xml').split("\n")[2..-1].join("\n"))
      File.delete(path) if File.exists?(path)
    end

    context 'with :gzip => true' do
      it 'should save gzip contents to the filesystem' do
        map = XmlSitemap::Map.new('foobar.com', :time => base_time)

        path = "/tmp/sitemap.xml"
        path_gzip = path + ".gz"

        map.render_to(path)
        map.render_to(path_gzip, :gzip => true)

        checksum(File.read(path)).should eq(checksum(gunzip(path_gzip)))

        File.delete(path) if File.exists?(path)
        File.delete(path_gzip) if File.exists?(path_gzip)
      end

      it 'should add .gz extension if comression is enabled' do
        map = XmlSitemap::Map.new('foobar.com', :time => base_time)
        path = '/tmp/sitemap.xml'
        path_gzip = path + ".gz"

        map.render_to(path)
        map.render_to(path, :gzip => true)

        checksum(File.read(path)).should eq(checksum(gunzip(path_gzip)))

        File.delete(path) if File.exists?(path)
        File.delete(path_gzip) if File.exists?(path_gzip)
      end
    end
  end

  describe 'performance' do
    it 'should test rendering time' do
      pending "comment this line to run benchmarks, takes roughly 30 seconds"
      map = XmlSitemap::Map.new('foobar.com', :time => base_time)

      50000.times do |i|
        map.add("hello#{i}")
      end

      Benchmark.bm do |x|
        x.report("render(:builder)")  { map.render(:builder)  }
        x.report("render(:nokogiri)") { map.render(:nokogiri) }
        x.report("render(:string)")   { map.render(:string)   }
      end
    end
  end
end