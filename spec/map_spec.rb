require 'spec_helper'

describe XmlSitemap::Map do
  before :all do
    @base_time = Time.mktime(2011, 6, 1, 0, 0, 1).utc
    @extra_time = Time.mktime(2011, 7, 1, 0, 0, 1).utc
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
    map.add('world', :updated => @extra_time).updated.should == Time.mktime(2011, 7, 1, 0, 0, 1)
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
end
