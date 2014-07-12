require_relative "caconsole/version"
require_relative "caconsole/device"

def get_banner

i_s = "default  input:#{CAConsole::default_input_device().name}"
o_s = "default output:#{CAConsole::default_output_device().name}"

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

	devs = CAConsole::devices
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
		CAConsole::set_default_output_device(dev)
		puts "Changed default output device #{dev.name}"
	else
		puts "No changed"
	end
end 

module CAConsole

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
