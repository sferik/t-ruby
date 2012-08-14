module T
  module RequestHelpers
    private

    def fetch_users(users, &block)
      require 't/core_ext/string'
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      require 'retryable'
      retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
        yield users
      end
    end

  end
end
