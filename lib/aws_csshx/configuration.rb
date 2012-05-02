module AwsCsshx

  class Configuration
    CONFIG_OPTS = %q{ec2_private_key aws_access_key aws_secret_access_key aws_region}
    def initialize(conf)
      @config_file = conf
      if File.exists?(conf)
        load_config_from_file @config_file
      else
        raise FileDoesNotExist, "Config file #{@config_file} cannot be found."
      end
    end

    # Iterate over the config file line by line and throw away things not in our config opts array
    def load_config_from_file(file)
      # TODO Check to see if the file exists
      f = File.open(file, "r")
      f.each_line do |line|
        field,val = line.split('=')
        next unless CONFIG_OPTS.include?(field.chomp!.downcase)
        @opts[field] = val
      end
    end
  end

  class Options < Hash
    attr_reader :opts, :orig_args

    def initialize(args)
      super()

      user_home = ENV['HOME']

      @orig_args = args.clone

      options = {}

      require 'optparse'
      @opts = OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} <file1> <file2> ..."

          o.separator "AWS Options"

          options[:group] = 'default'
          o.on( '-g', '--group <group>', 'AWS security group name to use for the csshX sessions' ) do |group|
              options[:group] = group
          end

          options[:identity] = ENV['EC2_PRIVATE_KEY'] || ''
          o.on( '-i', '--aws-identity <identity>', 'AWS security group name to use for the csshX sessions' ) do |identity|
              options[:aws_identity] = identity
          end

          options[:region] = ENV['EC2_PRIVATE_KEY'] || ''
          o.on( '-r', '--aws-region <region>', 'AWS security group name to use for the csshX sessions' ) do |region|
              options[:aws_region] = region
          end

          o.separator ""

          options[:csshx_opts] = ''
          o.on( '-o', '--csshx-opts <csshx_opts>', 'Pass the options listed directly to csshx' ) do |csshx_opts|
              options[:csshx_opts] = csshx_opts
          end

          options[:iterm2] = false
          o.on( '-2', '--iterm2', 'Use csshX.iterm instead of csshx' ) do |iterm2|
              options[:iterm2] = true
          end

          o.separator ""

          options[:conf] = "#{user_home}/.csshrc"
          o.on( '-c', '--conf <file>', 'aws_csshX config file (defaults to .csshrc)' ) do |file|
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
      end

      begin
          @opts.parse!(args)
          self[:options] = options
      rescue OptionParser::InvalidOption => e
          self[:invalid_argument] = e.message
          @opts.parse(args, flags={ :delete_invalid_opts => true })
          self[:options] = options
      end
    end
  end
end
