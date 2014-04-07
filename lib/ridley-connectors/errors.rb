module Ridley
  module Errors

    module ConnectorsError; end

    class HostConnectionError < RidleyError
      include ConnectorsError
    end

    class DNSResolvError < HostConnectionError
      include ConnectorsError
    end
  end
end
