require 'spec_helper'

describe XmlSitemap::Index do
  before :all do
    @base_time = Time.mktime(2011, 6, 1, 0, 0, 1)
  end
  
  it 'should be valid if no sitemaps were supplied' do
    index = XmlSitemap::Index.new
    index.render.should == fixture('empty_index.xml')
  end
  
  it 'should raise error if passing a wrong object' do
    index = XmlSitemap::Index.new
    proc { index.add(nil) }.should raise_error ArgumentError, 'XmlSitemap::Map object requred!'
  end
  
  it 'should raise error if passing an empty sitemap' do
    map = XmlSitemap::Map.new('foobar.com', :nohome => true)
    index = XmlSitemap::Index.new
    proc { index.add(map) }.should raise_error ArgumentError, 'Map is empty!'
  end
  
  it 'should render a proper index' do
    m1 = XmlSitemap::Map.new('foobar.com', :time => @base_time) { |m| m.add('about') }
    m2 = XmlSitemap::Map.new('foobar.com', :time => @base_time) { |m| m.add('about') }
    
    index = XmlSitemap::Index.new do |i|
      i.add(m1)
      i.add(m2)
    end
    
    index.render.should == fixture('sample_index.xml')
  end
  
  it 'should save index contents to the filesystem' do
    m1 = XmlSitemap::Map.new('foobar.com', :time => @base_time) { |m| m.add('about') }
    m2 = XmlSitemap::Map.new('foobar.com', :time => @base_time) { |m| m.add('about') }
    
    index = XmlSitemap::Index.new do |i|
      i.add(m1)
      i.add(m2)
    end
    
    path = "/tmp/index_#{Time.now.to_i}.xml"
    index.render_to(path)
    File.read(path).should == fixture('sample_index.xml')
    File.delete(path) if File.exists?(path)
  end
end
