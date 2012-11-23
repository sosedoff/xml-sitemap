require 'spec_helper'

describe 'XmlSitemap' do
  describe '#new' do
    it 'returns a new map instance' do
      XmlSitemap.new('foo.com').should be_a XmlSitemap::Map
    end
  end

  describe '#map' do
    it 'returns a new map instance' do
      XmlSitemap.map('foo.com').should be_a XmlSitemap::Map
    end
  end

  describe '#index' do
    it 'returns a new index instancet' do
      XmlSitemap.index.should be_a XmlSitemap::Index
    end
  end

  describe '#version' do
    it 'returns current version string' do
      XmlSitemap.version.should eq(XmlSitemap::VERSION)
    end
  end
end
