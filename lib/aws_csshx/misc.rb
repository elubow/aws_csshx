module AwsCsshx
  class Misc
    class << self

      def symbolize_hash_keys(hash)
        hsh = {}
        hash.each_pair { |k,v|  hsh[k.downcase.to_sym] = v }
        hsh
      end

    end
  end
end
