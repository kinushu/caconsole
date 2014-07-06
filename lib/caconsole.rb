require_relative "caconsole/version"
require 'coreaudio'

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

def select_output_dev

	devs = CoreAudio::devices
	sel_devs = devs.select {|dev| 
		dev.output_stream.channels > 0
	}

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

module Caconsole

buf_count = 1024

in_buf  = CoreAudio.default_input_device.input_buffer(buf_count)
# out_buf = CoreAudio.default_output_device.output_buffer(buf_count)

average_val = 0;
th = Thread.start do
  loop do
    w = in_buf.read(buf_count)
    average_val = 
    	w.map {|i| i.abs}.max
#    	sum(abs(w))/buf_count
  end
end

view_th = Thread.start do
  loop do
    p "ave:#{average_val}\n"
    sleep 1
  end
end

in_buf.start

loop{
    print get_banner
    case get_command()
    when 'o' then
    	select_output_dev()
    when 'q' then
        break
    end
}

in_buf.stop
th.kill.join
view_th.kill.join

end
