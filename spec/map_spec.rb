require 'spec_helper'

describe XmlSitemap::Map do
  before :all do
    @base_time = Time.gm(2011, 6, 1, 0, 0, 1)
    @extra_time = Time.gm(2011, 7, 1, 0, 0, 1)
  end
  
  it 'should not allow empty domains' do
    proc { XmlSitemap::Map.new(nil) }.should raise_error ArgumentError
    proc { XmlSitemap::Map.new('') }.should raise_error ArgumentError
    proc { XmlSitemap::Map.new(' ') }.should raise_error ArgumentError
  end
  
  it 'should not allow empty urls' do
    map = XmlSitemap::Map.new('foobar.com')
    proc { map.add(nil)  }.should raise_error ArgumentError
    proc { map.add('')   }.should raise_error ArgumentError
    proc { map.add('  ') }.should raise_error ArgumentError
  end
  
  it 'should have a home path by default' do
    map = XmlSitemap::Map.new('foobar.com')
    map.empty?.should == false
    map.items.first.target.should == 'http://foobar.com/'
  end
  
  it 'should not have a home path with option' do
    map = XmlSitemap::Map.new('foobar.com', :home => false)
    map.empty?.should == true
  end
  
  it 'should autocomplete path with no starting slash' do
    map = XmlSitemap::Map.new('foobar.com')
    map.add('about').target.should == 'http://foobar.com/about'
  end
  
  it 'should allow full urls in items' do
    map = XmlSitemap::Map.new('foobar.com', :root => false)
    map.add('https://foobar.com/path').target.should == 'https://foobar.com/path'
    map.add('path2').target.should == 'http://foobar.com/path2'
  end
  
  it 'should render urls in https mode' do
    map = XmlSitemap::Map.new('foobar.com', :secure => true)
    map.add('path').target.should == 'https://foobar.com/path'
  end
  
  it 'should properly set entry time' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    map.add('hello').updated.should == @base_time
    map.add('world', :updated => @extra_time).updated.should == Time.gm(2011, 7, 1, 0, 0, 1)
  end
  
  it 'should raise Argument error if no time or date were provided' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    proc { map.add('hello', :updated => 5) }.
      should raise_error ArgumentError, "Time, Date, or ISO8601 String required for :updated!"
  end
  
  it 'should not raise Argument error if a iso8601 string is provided' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    proc { map.add('hello', :updated => "2011-09-12T23:18:49Z") }.
      should_not raise_error
    map.add('world', :updated => @extra_time.utc.iso8601).updated.should == Time.gm(2011, 7, 1, 0, 0, 1).utc.iso8601
  end
  
  it 'should not raise Argument error if a string is provided with :validate_time => false' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    proc { map.add('hello', :validate_time => false, :updated => 'invalid data') }.
      should_not raise_error
  end
  
  it 'should raise Argument error if an invalid string is provided' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    proc { map.add('hello', :updated => 'invalid data') }.
      should raise_error ArgumentError, "String provided to :updated did not match ISO8601 standard!"
  end
  
  it 'should have properly encoded entities' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    map.add('/path?a=b&c=d&e=sample string')
    map.render.should == fixture('encoded_map.xml')
  end
  
  it 'should not allow more than 50k records' do
    map = XmlSitemap::Map.new('foobar.com')
    proc {
      1.upto(50000) { |i| map.add("url#{i}") }
    }.should raise_error RuntimeError, 'Only less than 50k records allowed!'
  end
  
  it 'should not allow urls longer than 2048 characters' do
    long_string = (1..2049).to_a.map { |i| "a" }.join
    
    map = XmlSitemap::Map.new('foobar.com')
    proc {
      map.add(long_string)
    }.should raise_error ArgumentError, "Target can't be longer than 2,048 characters!"
  end
  
  it 'should save contents to the filesystem' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time) do |m|
      m.add('about')
      m.add('terms')
      m.add('privacy')
    end
    path = "/tmp/sitemap_#{Time.now.to_i}.xml"
    map.render_to(path)
    File.read(path).should == fixture('saved_map.xml')
    File.delete(path) if File.exists?(path)
  end
  
  it 'should save gzip contents to the filesystem' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    
    path = "/tmp/sitemap.xml"
    path_gzip = path + ".gz"
    
    map.render_to(path)
    map.render_to(path_gzip, :gzip => true)
    
    checksum(File.read(path)).should == checksum(gunzip(path_gzip))
    
    File.delete(path) if File.exists?(path)
    File.delete(path_gzip) if File.exists?(path_gzip)
  end
  
  it 'should add .gz extension if comression is enabled' do
    map = XmlSitemap::Map.new('foobar.com', :time => @base_time)
    path = '/tmp/sitemap.xml'
    path_gzip = path + ".gz"
    
    map.render_to(path)
    map.render_to(path, :gzip => true)
    
    checksum(File.read(path)).should == checksum(gunzip(path_gzip))
    
    File.delete(path) if File.exists?(path)
    File.delete(path_gzip) if File.exists?(path_gzip)
  end
end
