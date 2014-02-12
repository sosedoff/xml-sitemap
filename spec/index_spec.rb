require 'spec_helper'

describe XmlSitemap::Index do
  let(:base_time) { Time.gm(2011, 6, 1, 0, 0, 1) }

  describe '#new' do
    it 'should be valid if no sitemaps were supplied' do
      index = XmlSitemap::Index.new
      index.render.split("\n")[2..-1].join("\n").should == fixture('empty_index.xml').split("\n")[2..-1].join("\n")
    end

    it 'should raise error if passing a wrong object' do
      index = XmlSitemap::Index.new
      expect { index.add(nil) }.to raise_error ArgumentError, 'XmlSitemap::Map object required!'
    end

    it 'should raise error if passing an empty sitemap' do
      map = XmlSitemap::Map.new('foobar.com', :home => false)
      index = XmlSitemap::Index.new
      expect { index.add(map) }.to raise_error ArgumentError, 'Map is empty!'
    end
  end

  describe '#render' do
    it 'renders a proper index' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new do |i|
        i.add(m1)
        i.add(m2)
      end

      index.render.split("\n")[2..-1].join("\n").should == fixture('sample_index.xml').split("\n")[2..-1].join("\n")
    end

    it 'renders a proper index with the secure option' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new(:secure => true) do |i|
        i.add(m1)
        i.add(m2)
      end

      index.render.split("\n")[2..-1].join("\n").should == fixture('sample_index_secure.xml').split("\n")[2..-1].join("\n")
    end

    it 'renders a proper index for multiple subdomains' do
      m1 = XmlSitemap::Map.new('one.foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('two.foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new do |i|
        i.add(m1, :use_offsets => false)
        i.add(m2, :use_offsets => false)
      end

      index.render.split("\n")[2..-1].join("\n").should == fixture('sample_many_subdomains_index.xml').split("\n")[2..-1].join("\n")
    end
  end

  describe '#render_to' do
    let(:index_path) { "/tmp/xml_index.xml" }

    after :all do
      File.delete_if_exists(index_path)
    end

    it 'saves index contents to the filesystem' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new do |i|
        i.add(m1)
        i.add(m2)
      end

      index.render_to(index_path)
      File.read(index_path).split("\n")[2..-1].join("\n").should eq(fixture('sample_index.xml').split("\n")[2..-1].join("\n"))
    end

    it 'should have separate running offsets for different map groups' do
      maps = %w(first second second third).map do |name|
        XmlSitemap::Map.new('foobar.com', :time => base_time, :group => name)  { |m| m.add('about') }
      end

      index = XmlSitemap::Index.new do |i|
        maps.each { |m| i.add(m) }
      end

      index.render_to(index_path)
      File.read(index_path).split("\n")[2..-1].join("\n").should eq(fixture('group_index.xml').split("\n")[2..-1].join("\n"))
    end

    it 'saves index contents to the filesystem with local gzip options for each map' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new do |i|
        i.add(m1, :gzip => true)
        i.add(m2, :gzip => true)
      end

      index.render_to(index_path)
      File.read(index_path).split("\n")[2..-1].join("\n").should eq(fixture('sample_index_with_gz.xml').split("\n")[2..-1].join("\n"))
    end

    it 'saves index contents to the filesystem with global gzip options for all maps' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }

      index = XmlSitemap::Index.new(:gzip => true) do |i|
        i.add(m1)
        i.add(m2)
      end

      index.render_to(index_path)
      File.read(index_path).split("\n")[2..-1].join("\n").should eq(fixture('sample_index_with_gz.xml').split("\n")[2..-1].join("\n"))
    end
  end
end
