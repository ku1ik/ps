require 'spec_helper'

shared_examples_for('json response') do
  it 'should be successfull' do
    last_response.should be_ok
  end

  it 'should return results as JSON' do
    last_response.content_type.should == 'application/json'
  end

  it 'should return parsable JSON data' do
    lambda do
      JSON.parse(last_response.body)
    end.should_not raise_error(JSON::ParserError)
  end
end

describe 'App' do
  include Rack::Test::Methods

  def app; Sinatra::Application; end

  describe '/' do
    before do
      get '/' unless example.metadata[:skip_before]
    end

    it_should_behave_like 'json response'

    context 'when no filter nor order given' do
      it 'should call Ps.all with nil as filter/order values', :skip_before => true do
        Ps.should_receive(:all).with(:filter => nil, :order => nil).and_return([])

        get '/'
      end
    end

    context 'when filter given' do
      it 'should call Ps.all with non-empty filter option', :skip_before => true do
        Ps.should_receive(:all).with(:filter => 'foobar', :order => nil).and_return([])

        get '/?filter=foobar'
      end
    end

    context 'when order given' do
      it 'should call Ps.all with non-empty order option', :skip_before => true do
        Ps.should_receive(:all).with(:filter => nil, :order => 'baz').and_return([])

        get '/?order=baz'
      end
    end
  end

  describe '/<pid>' do
    before do
      get "/#{pid}" unless example.metadata[:skip_before]
    end

    context 'when there is no process for given pid' do
      let(:pid) { Ps::MAX_PID + 1 }

      it 'should return 404' do
        last_response.status.should == 404
      end
    end

    context 'when there is a process for given pid' do
      let(:pid) { 1 }

      it 'should call Ps.details to get process information', :skip_before => true do
        Ps.should_receive(:details).with(pid).and_return({})

        get "/#{pid}"
      end

      it_should_behave_like 'json response'
    end
  end
end
