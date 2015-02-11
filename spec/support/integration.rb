module SpecSupport

  def call_and_fail_gracefully(client, *args, &block)
    client.call(*args, &block)
  rescue Reste::SOAPFault => e
    pending e.message
  end

end
