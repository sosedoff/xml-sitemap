require 'spec_helper'

describe XmlSitemap::Index do
  before :all do
    @base_time = Time.gm(2011, 6, 1, 0, 0, 1)
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
    map = XmlSitemap::Map.new('foobar.com', :home => false)
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
  
  it 'should have separate running offsets for different map groups' do
    m1 = XmlSitemap::Map.new('foobar.com', :time => @base_time, :group => "first")  { |m| m.add('about') }
    m2 = XmlSitemap::Map.new('foobar.com', :time => @base_time, :group => "second") { |m| m.add('about') }
    m3 = XmlSitemap::Map.new('foobar.com', :time => @base_time, :group => "second") { |m| m.add('about') }
    m4 = XmlSitemap::Map.new('foobar.com', :time => @base_time, :group => "third")  { |m| m.add('about') }
    
    index = XmlSitemap::Index.new do |i|
      i.add(m1)
      i.add(m2)
      i.add(m3)
      i.add(m4)
    end
    
    path = "/tmp/index_#{Time.now.to_i}.xml"
    index.render_to(path)
    File.read(path).should == fixture('group_index.xml')
    File.delete(path) if File.exists?(path)
  end
  
end
