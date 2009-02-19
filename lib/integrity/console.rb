require 'irb'
module Integrity
  class Console
    def initialize(config)
      Integrity.new(config)
      max_length = Integrity.config.keys.map{|k| k.to_s.length}.sort.last + 4
      Integrity.config.keys.sort_by {|k| k.to_s}.each do |k|
        puts "  #{k.to_s.ljust(max_length, ".")} #{Integrity.config[k]}"
      end
    end

    def run
      IRB.setup( nil )
      IRB.conf[:IRB_NAME] = "integrity"
      irb = IRB::Irb.new
      IRB.conf[:IRB_RC].call(irb.context) if IRB.conf[:IRB_RC]
      IRB.conf[:MAIN_CONTEXT] = irb.context

      trap("SIGINT") do
        irb.signal_handle
      end

      catch(:IRB_EXIT) do
        irb.eval_input
      end
    end
  end
end
