module Ridley
  class NodeObject
    # Executes a Chef run on the node
    #
    # @return [HostConnector::Response]
    def chef_run
      resource.chef_run(self.public_hostname)
    end

    # Puts the configured encrypted data bag secret on the node
    #
    # @return [HostConnector::Response]
    def put_secret
      resource.put_secret(self.public_hostname)
    end
  end
end
