require 'spec_helper'

describe 'XmlSitemap' do
  it 'creates a Map via shortcut' do
    XmlSitemap.new('foo.com').should be_a XmlSitemap::Map
    XmlSitemap.map('foo.com').should be_a XmlSitemap::Map
  end
  
  it 'creates an Index via shortcut' do
    XmlSitemap.index.should be_a XmlSitemap::Index
  end
end
