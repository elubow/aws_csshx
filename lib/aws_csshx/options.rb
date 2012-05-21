module AwsCsshx
  class OptionsError < StandardError; end

  class Options < Hash
    attr_reader :opts, :orig_args, :parsed

    def initialize(args)
      super()

      user_home = ENV['HOME']

      @orig_args = args.clone

      @parsed = false
      options = {}

      require 'optparse'
      @opts = OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} <file1> <file2> ..."

          o.separator ""
          o.separator "AWS Options"

          options[:group] = 'default'
          o.on( '-g', '--group <group>', 'AWS security group name to use for the csshX sessions' ) do |group|
              options[:group] = group
          end

          o.on( '-i', '--aws-identity <identity>', 'Use this keyfile as your SSH private key' ) do |identity|
              options[:ec2_private_key] = identity
          end

          o.on( '-r', '--aws-region <region>', 'AWS region to query for the csshX sessions (default: us-east-1)' ) do |region|
              options[:aws_region] = region
          end

          o.on( '-H', '--hosts x,y,z', Array, 'Additional hosts to add to the group (comma separated)' ) do |server_list|
              options[:additional_servers] = server_list
          end

          o.separator ""
          o.separator "csshX Options"

          options[:login] = 'root'
          o.on( '-l', '--login <login>', 'User login to use for the csshX sessions (default: root)' ) do |login|
              options[:login] = login
          end

          options[:csshx_opts] = ''
          o.on( '-o', '--csshx-opts <csshx_opts>', 'Pass the options listed directly to csshx' ) do |csshx_opts|
              options[:csshx_opts] = csshx_opts
          end

          options[:iterm2] = false
          o.on( '-2', '--iterm2', 'Use csshX.iterm instead of csshx' ) do |iterm2|
              options[:iterm2] = true
          end

          o.separator ""

          options[:conf] = "#{Etc.getpwuid.dir}/.csshrc"
          o.on( '-c', '--conf <file>', 'aws_csshX config file (default: .csshrc)' ) do |file|
              if File.exists?(file)
                  options[:conf] = file
              else
                  raise FileDoesNotExist, "Config file #{file} cannot be found."
              end
          end

          o.on('-V', '--version', "Display version information") do
              options[:version] = true
          end

          options[:help] = false
          o.on( '-h', '--help', 'Display this help screen' ) do
              options[:help] = true
          end

          o.separator ""
          o.separator "Examples:"
          o.separator "  Cluster SSH to all machines in the 'utility' security group:"
          o.separator "    #{File.basename($0)} -g utility"
          o.separator ""
      end

      begin
          @opts.parse!(args)
          self[:options] = options
      rescue OptionParser::InvalidOption => e
          self[:invalid_argument] = e.message
          @opts.parse(args, flags={ :delete_invalid_opts => true })
          self[:options] = options
      end
      @parsed = true
    end

    def parsed?
      @parsed
    end
  end
end
