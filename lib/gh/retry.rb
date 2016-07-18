require 'gh'

module GH
  # Public: In some cases, the GitHub API can take some number of
  # seconds to reflect a change in the system. This class catches 404
  # responses for any GET request and retries the request.
  class Retry < Wrapper
    DEFAULTS = {
      retries: 5,
      sleep: 1
    }

    def [](key, opts = {})
      generate_response key, fetch_resource(key, opts)
    end

    def fetch_resource(key, opts = {})
      opts = DEFAULTS.merge opts
      retries, sleep_time = opts[:retries], opts[:sleep]
      begin
        retries -= 1
        super(key)
      rescue GH::Error(response_status: 404) => e
        raise(e) unless retries_remaining?(retries)
        sleep sleep_time
        fetch_resource key, retries: retries, sleep: sleep_time
      end
    end

    private

    def retries_remaining?(retries)
      retries > 0
    end
  end
end
