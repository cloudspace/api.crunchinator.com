module ApiQueue
  module Response
    class Forbidden
      def handle(response)
        if response.body == '<h1>Developer Over Qps</h1>'
          # handle QPS rate limiting here somehow
          response # and replace this
        else
          response
        end
      end
    end
  end
end
