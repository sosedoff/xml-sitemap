# encoding: utf-8
require 'spec_helper'

describe XmlSitemap::Map do
  before :all do
    @base_time = Time.mktime(2011, 6, 1, 0, 0, 1)
  end
  
  it 'should not be empty after creation' do
    map = XmlSitemap::Map.new('foobar.com')
    map.empty?.should == false
  end
  
  it 'should allow full urls in items' do
    # TODO
  end
  
  it 'should have properly encoded entities' do
    # TODO
  end
  
  it 'should not allow more than 50k records' do
    # TODO
  end
  
  it 'should save contents to filesystem' do
    # TODO
  end
end
