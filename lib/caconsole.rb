require "caconsole/version"
require 'coreaudio'

require 'optparse'

module Caconsole

	module_function

	def get_banner

		i_s = "default  input:#{CoreAudio::default_input_device().name}"
		o_s = "default output:#{CoreAudio::default_output_device().name}"

		banner = <<DATA
Default Audio Device
 #{i_s}
 #{o_s}
Select what you want
 o: select default input device
 q: quit
DATA

	end

	def get_command
		gets.chomp
	end

	def get_command_number
		get_command().to_i
	end

	def audio_output_devices
		devs = CoreAudio::devices
		sel_devs = devs.select {|dev|
			dev.output_stream.channels > 0
		}

		sel_devs
  end

	def select_output_dev
		sel_devs = audio_output_devices

		puts 'List up output devices.'
		sel_devs.each_with_index {|dev, idx|
			puts "#{idx}:#{dev.name}"
		}
		puts 'Select device? '
		idx = get_command_number()

		if dev = sel_devs[idx]
			CoreAudio::set_default_output_device(dev)
			puts "Changed default output device #{dev.name}"
		else
			puts "No changed"
		end
	end

	def loop_proc
		loop{
			print get_banner
			case get_command()
			when 'o' then
				select_output_dev()
			when 'q' then
				break
			end
		}
	end

  def print_devices
		out_devs = audio_output_devices
    puts "output audio devices (#{out_devs.count}):"
		out_devs.each_with_index {|dev, idx|
			puts "#{idx}:#{dev.name}"
		}
	end

end

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: caconsole"

    opts.on("-l", "--list", "View audio devices") do |_v|
        options[:list] = true
    end
end.parse!

if options[:list]
  Caconsole::print_devices
else
  Caconsole::loop_proc
end
