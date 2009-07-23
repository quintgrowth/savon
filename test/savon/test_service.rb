require File.join(File.dirname(__FILE__), "..", "helper")

class TestSavonService < Test::Unit::TestCase

  include TestHelper
  include SoapResponseFixture

  context "Savon::Service" do
    setup do
      @some_factory = WsdlFactory.new
      @some_wsdl = Savon::Wsdl.new(some_uri, http_mock(@some_factory.build))
      Savon::Wsdl.stubs(:new).returns(@some_wsdl)

      @service = Savon::Service.new(some_url)
      @service.http = service_http_mock(some_soap_response)
      @result = @service.findById
    end

    should "return a Savon::Response object containing the given response" do
      assert_kind_of Savon::Response, @result
      assert_equal some_soap_response, @result.to_s
    end

    should "return an instance of Savon::Wsdl on wsdl" do
      assert_kind_of Savon::Wsdl, @service.wsdl
    end

    should "raise an ArgumentError when called with an invalid action" do
      assert_raise ArgumentError do
        @service.somethingCrazy
      end
    end
  end

end