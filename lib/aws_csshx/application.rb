module AwsCsshx
  class Application
    class << self

      def run!(*arguments)
        opt = AwsCsshx::Options.new(arguments)
        options = opt[:options]

        # Deal with the option issues
        if opt[:invalid_argument]
          $stderr.puts opt[:invalid_argument]
          options[:help] = true
        end

        if options[:help]
          $stderr.puts version()
          $stderr.puts opt.opts
          return 1
        end

        begin
          # Load the config file if it exists
          if File.exists?(options[:conf])
            config = AwsCsshx::Configuration.new(options[:conf])
          end
        rescue
        end

        # Exit cleanly
        return 0
      end

    end
  end
end
