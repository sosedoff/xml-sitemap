require 'spec_helper'

describe 'XmlSitemap::Item' do
  it 'should raise ArgumentError if invalid :period value was passed' do
    proc { XmlSitemap::Item.new('hello', :period => :foobar) }.
      should raise_error ArgumentError, "Invalid :period value 'foobar'"
  end
end
