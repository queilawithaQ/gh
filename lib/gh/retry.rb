require 'gh'

module GH
  # Public: In some cases, the GitHub API can take some number of
  # seconds to reflect a change in the system. This class catches 404
  # responses for GET requests to the GitHub API and retries the requests.
  class Retry < Wrapper
    DEFAULTS = {
      retries: 5,
      sleep: 1
    }

    def [](key, opts = {})
      generate_response key, fetch_resource(key, opts)
    end

    def fetch_resource(key, opts = {})
      opts = DEFAULTS.merge(opts)
      begin
        super(key)
      rescue GH::Error(response_status: 404) => e
        raise(e) if opts[:retries] == 1
        sleep opts[:sleep]
        fetch_resource(key, retries: opts[:retries] - 1)
      end
    end
  end
end
