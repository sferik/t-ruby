module T
  module Retryable
    NUM_RETRIES = 3

    def retryable(&block)
      retries = NUM_RETRIES
      begin
        yield
      rescue Twitter::Error::ServerError
        if (retries -= 1) > 0
          retry
        else
          raise
        end
      end
    end

  end
end
