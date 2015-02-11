require "spec_helper"
require "reste/mock/spec_helper"

describe "Reste's mock interface" do
  include Reste::SpecHelper

  before :all do
    reste.mock!
  end

  after :all do
    reste.unmock!
  end

  it "can verify a request and return a fixture response" do
    message = { :username => "luke", :password => "secret" }
    reste.expects(:authenticate).with(:message => message).returns("<fixture/>")

    response = new_client.call(:authenticate) do
      message(:username => "luke", :password => "secret")
    end

    expect(response.http.body).to eq("<fixture/>")
  end

  it "accepts a Hash to specify the response code, headers and body" do
    soap_fault = Fixture.response(:soap_fault)
    response = { :code => 500, :headers => { "X-Result" => "invalid" }, :body => soap_fault }

    reste.expects(:authenticate).returns(response)
    response = new_client(:raise_errors => false).call(:authenticate)

    expect(response).to_not be_successful
    expect(response).to be_a_soap_fault

    expect(response.http.code).to eq(500)
    expect(response.http.headers).to eq("X-Result" => "invalid")
    expect(response.http.body).to eq(soap_fault)
  end

  it "works with multiple requests" do
    authentication_message = { :username => "luke", :password => "secret" }
    reste.expects(:authenticate).with(:message => authentication_message).returns("")

    find_user_message = { :by_username => "lea" }
    reste.expects(:find_user).with(:message => find_user_message).returns("")

    new_client.call(:authenticate, :message => authentication_message)
    new_client.call(:find_user, :message => find_user_message)
  end

  it "fails when the expected operation was not called" do
    # TODO: find out how to test this! [dh, 2012-12-17]
    #reste.expects(:authenticate)
  end

  it "fails when the return value for an expectation was not specified" do
    reste.expects(:authenticate)

    expect { new_client.call(:authenticate) }.
      to raise_error(Reste::ExpectationError, "This expectation was not set up with a response.")
  end

  it "fails with an unexpected request" do
    expect { new_client.call(:authenticate) }.
      to raise_error(Reste::ExpectationError, "Unexpected request to the :authenticate operation.")
  end

  it "fails with multiple requests" do
    authentication_message = { :username => "luke", :password => "secret" }
    reste.expects(:authenticate).with(:message => authentication_message).returns("")

    create_user_message = { :username => "lea" }
    reste.expects(:create_user).with(:message => create_user_message).returns("")

    find_user_message = { :by_username => "lea" }
    reste.expects(:find_user).with(:message => find_user_message).returns("")

    # reversed order from previous spec
    new_client.call(:authenticate, :message => authentication_message)

    expect { new_client.call(:find_user, :message => find_user_message) }.
      to raise_error(Reste::ExpectationError, "Expected a request to the :create_user operation.\n" \
                                              "Received a request to the :find_user operation instead.")
  end

  it "fails when the expected SOAP operation does not match the actual one" do
    reste.expects(:logout).returns("<fixture/>")

    expect { new_client.call(:authenticate) }.
      to raise_error(Reste::ExpectationError, "Expected a request to the :logout operation.\n" \
                                              "Received a request to the :authenticate operation instead.")
  end

  it "fails when there is no actual message to match" do
    message = { :username => "luke" }
    reste.expects(:find_user).with(:message => message).returns("<fixture/>")

    expect { new_client.call(:find_user) }.
      to raise_error(Reste::ExpectationError, "Expected a request to the :find_user operation\n" \
                                              "  with this message: #{message.inspect}\n" \
                                              "Received a request to the :find_user operation\n" \
                                              "  with no message.")
  end

  it "fails when there is no expect but an actual message" do
    reste.expects(:find_user).returns("<fixture/>")
    message = { :username => "luke" }

    expect { new_client.call(:find_user, :message => message) }.
      to raise_error(Reste::ExpectationError, "Expected a request to the :find_user operation\n" \
                                              "  with no message.\n" \
                                              "Received a request to the :find_user operation\n" \
                                              "  with this message: #{message.inspect}")
  end

  it "does not fail when any message is expected and an actual message" do
    reste.expects(:find_user).with(:message => :any).returns("<fixture/>")
    message = { :username => "luke" }

    expect { new_client.call(:find_user, :message => message) }.to_not raise_error
  end

  it "does not fail when any message is expected and no actual message" do
    reste.expects(:find_user).with(:message => :any).returns("<fixture/>")

    expect { new_client.call(:find_user) }.to_not raise_error
  end


  it "allows code to rescue Reste::Error and still report test failures" do
    message = { :username => "luke" }
    reste.expects(:find_user).with(:message => message).returns("<fixture/>")

    expect {
      begin
        new_client.call(:find_user)
      rescue Reste::Error => e
        puts "any real error (e.g. SOAP fault or HTTP error) is OK in the big picture, move on"
      end
    }.to raise_error(Reste::ExpectationError, "Expected a request to the :find_user operation\n" \
                                              "  with this message: #{message.inspect}\n" \
                                              "Received a request to the :find_user operation\n" \
                                              "  with no message.")
  end

  def new_client(globals = {})
    defaults = {
      :endpoint  => "http://example.com",
      :namespace => "http://v1.example.com",
      :log       => false
    }

    Reste.client defaults.merge(globals)
  end

end
