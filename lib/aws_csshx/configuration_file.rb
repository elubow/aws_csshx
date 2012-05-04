# TODO Create config option errors handling class
# TODO Ensure environment variables exist before blindly setting options to them
module AwsCsshx
  class ConfigurationFile
    attr :options

    CONFIG_OPTS = %q{ec2_private_key aws_access_key aws_secret_key aws_region}

    def initialize(conf)
      @config_file = conf
      @options = {}
      if File.exists?(conf)
        load_config_from_file @config_file
      else
        raise FileDoesNotExist, "Config file #{@config_file} cannot be found."
      end
    end

    # Iterate over the config file line by line and throw away things not in our config opts array
    def load_config_from_file(file)
      f = File.open(file, "r")
      f.each_line do |line|
        field,value = line.split('=')
        next if field.nil? or value.nil?
        field.strip!.downcase!
        value.strip!
        next unless CONFIG_OPTS.include?(field)
        @options[field] =
          if    field == 'ec2_private_key' then set_ec2_private_key(value)
          elsif field == 'aws_access_key' then set_aws_access_key(value)
          elsif field == 'aws_secret_key' then set_aws_secret_key(value)
          elsif field == 'aws_region' then set_aws_region(value)
          else  puts "No such option #{field} skipping..."
          end
      end
    end


    #
    # Private(ish) methods for config settings
    #

    def set_aws_region(val)
      if val
        val
      elsif ENV['AWS_REGION']
        ENV['AWS_REGION']
      else
        'us-east-1'
      end
    end

    def set_aws_secret_key(val)
      if val
        val
      elsif ENV['AWS_SECRET_KEY']
        ENV['AWS_SECRET_KEY']
      elsif ENV['AMAZON_SECRET_ACCESS_KEY']
        ENV['AMAZON_SECRET_ACCESS_KEY']
      end
    end

    def set_aws_access_key(val)
      if val
        val
      elsif ENV['AWS_ACCESS_KEY']
        ENV['AWS_ACCESS_KEY']
      elsif ENV['AMAZON_ACCESS_KEY_ID']
        ENV['AMAZON_ACCESS_KEY_ID']
      end
    end

    def set_ec2_private_key(key_file)
      if File.exists?(key_file)
        key_file
      else
        puts "#{key_file} does not exist, using default."
        ENV['EC2_PRIVATE_KEY']
      end
    end
  end
end
