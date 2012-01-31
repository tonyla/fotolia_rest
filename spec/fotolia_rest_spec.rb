require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FotoliaRest" do
  describe "Client" do
    describe "valid credentials" do
      before(:each) do
        @config = YAML.load(File.open(File.expand_path(File.dirname(__FILE__) + '/../fotolia_rest.yml')))
        @client = FotoliaRest::Client.new(@config['api_key'], @config['username'], @config['password'])
      end
      it "should be able to make GET requests" do
        result = @client.execute('search', 'getSearchResults', :search_parameters => {:words => 'cat'} )
        result.success?.should be_true
        result.response.should_not be_nil
      end

      it "should be able to login" do
        result = @client.login()
        result.success?.should be_true
        result.response.should_not be_nil
        @client.session_id.should_not be_nil
      end

      it "should be able to make authenticated calls" do
        @client.login()
        result = @client.execute('media', 'getMediaComp', :id => 28261761)
        result.success?.should be_true
        result.response.should_not be_nil
        puts result.response
      end
      it "should be able to make authenticated calls" do
        @client.login()
        result = @client.execute('user', 'getUserData')
        result.success?.should be_true
        result.response.should_not be_nil
        puts result.response
      end

      it "should error on invalid calls" do
        result = @client.execute( 'asdf', '1234' )
        result.success?.should be_false
        result.response.should_not be_nil
        result.error.should be_kind_of(FotoliaRest::FotoliaApiError)
      end
    end

    describe "invalid credentials" do
      before(:each) do
        @client = FotoliaRest::Client.new('', '', '')
      end

      it "should not result in a success" do
        result = @client.execute('search', 'getSearchResults', :search_parameters => {:words => 'cat'} )
        result.success?.should be_false
        result.error.code.should_not be_nil
        result.error.code.should eql('010')
        result.error.message.should_not be_nil
      end
    end

    describe "timeout" do
      before( :each ) do
        @client = FotoliaRest::Client.new('','','')
      end

      it "should result in a timeout exception" do
        using_constants( FotoliaRest::Client, :BASE_URL => 'nowhere.nowhere.nowhere' ) do
          expect {
            @client.execute('anything', 'at', :all => true)
          }.to raise_error(FotoliaRest::FotoliaError)
        end
      end
    end
  end
end
