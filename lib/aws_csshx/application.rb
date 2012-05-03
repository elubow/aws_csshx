require 'etc'

class Hash
  def symbolize_keys!
    hsh = {}
    self.each_pair { |k,v|  hsh[k.downcase.to_sym] = v }
    hsh
  end
end

module AwsCsshx
  class Application
    attr :options

    class << self

      def csshx_exists?
        `which csshx > /dev/null 2>&1`
      end

      def aws_settings_exist?
        @options[:aws_access_key] and @options[:aws_secret_key] and @options[:aws_region] and File.exists?(@options[:ec2_private_key])
      end

      def run!(*arguments)
        @options = {}

        # No need to go further unless csshX exists
        abort('csshX file is required') unless csshx_exists?

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
          p @options
          @options.merge!(command_line_options[:options]).symbolize_keys!
          p @options

          # Load the new config file if different
          if conf_file != @options[:conf] and File.exists?(conf_file)
            config = AwsCsshx::ConfigurationFile.new(@options[:conf])
          end

          # Deal with the option issues
          if command_line_options[:invalid_argument]
            $stderr.puts command_line_options[:invalid_argument]
            @options[:help] = true
          end

          # Stop here without all our AWS settings
          abort("Invalid AWS settings") unless aws_settings_exist?

          @server_list = aws_server_list_by_group options[:group]

          `csshx --login root --ssh_args='-i #{options[:ec2_private_key]}' #{@server_list.join(' ')}`

        rescue Exception => e
          puts "Error: #{e.inspect}"
          puts "Trace: #{e.backtrace}"
        end

        # Exit cleanly
        return 0
      end

      def aws_server_list_by_group(group)
        @ec2_api ||= RightAws::Ec2.new(self.options[:aws_access_key], self.options[:aws_secret_key])

        @ec2_api.describe_instances.reject{|i| i[:aws_state] != "running"}.map do |instance|
          instance[:dns_name] if instance[:groups].map{|g| g[:group_name]}.include?(group)
        end.compact
      end

    end
  end
end

