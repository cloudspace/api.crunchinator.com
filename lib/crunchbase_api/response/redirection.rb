module ApiQueue
  module Response
    class Redirection
      def handle(response)
        throw :redirect
      end
    end
  end
end
