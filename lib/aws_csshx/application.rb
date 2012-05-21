module AwsCsshx
  class Application
    attr :options

    class << self

      def csshx_exists?
        `which csshx > /dev/null 2>&1`
        $?.success?
      end

      def aws_settings_exist?
        @options[:aws_access_key] and @options[:aws_secret_key] and @options[:aws_region] and File.exists?(@options[:ec2_private_key])
      end

      def has_servers?(list)
        list.count > 0 ? true : false
      end

      def run!(*arguments)
        @options = {}

        # No need to go further unless csshX exists
        raise OptionsError, "csshX file is required" unless csshx_exists?

        begin
          # First we load the config file and then process the command line
          # options since they take precedence.

          # Load the config file if it exists
          conf_file = "#{Etc.getpwuid.dir}/.csshrc"
          if File.exists?(conf_file)
            config = AwsCsshx::ConfigurationFile.new(conf_file)
            @options = config.options
          end

          command_line_options = AwsCsshx::Options.new(arguments)
          @options.merge!(command_line_options[:options])
          @options = AwsCsshx::Misc.symbolize_hash_keys(@options)

          # Load the new config file if different
          if conf_file != @options[:conf] and File.exists?(conf_file)
            config = AwsCsshx::ConfigurationFile.new(@options[:conf])
          end

          # Deal with the option issues
          if command_line_options.parsed? and command_line_options[:invalid_argument]
            $stderr.puts command_line_options[:invalid_argument]
            @options[:help] = true
          end

          # Show the version screen and bounce if requested
          if @options[:version]
            puts "#{$0} #{AwsCsshx::VERSION}"
            return 0
          end

          # Show the help screen and bounce if requested
          if @options[:help]
            puts command_line_options.opts
            return 0
          end

          # Stop here without all our AWS settings
          raise OptionsError, "Invalid AWS settings" unless aws_settings_exist?

          raise OptionsError, "Cannot continue without AWS security group (-g)" unless @options[:group]

          @server_list = aws_server_list_by_group @options[:group]
          aws_server_count = @server_list.count

          # Add any additional servers from the command line to the pool
          add_servers_from_command_line if @options[:additional_servers]

          if has_servers? @server_list
            csshx_switches = create_csshx_switches
            `csshx #{[csshx_switches, @server_list].join(' ')}`
            puts "Opened connections to #{aws_server_count} servers in the '#{@options[:group]}' security group."
            puts "Opened connections to #{@options[:additional_servers].count} servers from command-line options." if @options[:additional_servers]
          else
            raise OptionsError, "No servers found in '#{@options[:group]}' group...bailing out!"
          end

        rescue OptionsError => e
          puts "Error: #{e}"

        rescue Exception => e
          puts "#{e.class} Error: #{e}"
          puts "Backtrace:\n#{e.backtrace.join("\n")}"
        end

        # Exit cleanly
        return 0
      end

      def create_csshx_switches
        switches = []

        # Set the basics by default
        switches.push('--login', @options[:login])
        switches.push("--ssh_args='-i #{@options[:ec2_private_key]}'")

        # Add the additional stuff specific to csshx
        switches.push('--iterm2', @options[:iterm2]) if @options[:iterm2]
        switches.push(@options[:csshx_opts]) if @options[:csshx_opts]
      end

      def add_servers_from_command_line
        @server_list.push(@options[:additional_servers]).flatten!.uniq! if @options[:additional_servers]
      end

      def aws_server_list_by_group(group)
        @ec2_api ||= RightAws::Ec2.new(@options[:aws_access_key], @options[:aws_secret_key])

        @ec2_api.describe_instances.reject{|i| i[:aws_state] != "running"}.map do |instance|
          instance[:dns_name] if instance[:groups].map{|g| g[:group_name]}.include?(group)
        end.compact
      end

    end
  end
end
