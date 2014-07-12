require_relative "caconsole/version"
require_relative "caconsole/device"
require 'curses'

include Curses

def get_banner

i_s = "default  input:#{CAConsole::default_input_device().name}"
o_s = "default output:#{CAConsole::default_output_device().name}"

banner = <<DATA
Default Audio Device
 #{i_s}
 #{o_s}
Select what you want
 o: select default output device
 q: quit
DATA

end

def get_command
	getch
#	gets.chomp
end

def get_command_number
	get_command().to_i
end

def select_output_dev

	# 出力channelあるデバイスを列挙
	sel_devs = CAConsole::output_devices

	msg = "List up output devices.\n"
	sel_devs.each_with_index {|dev, idx|
		msg += "#{idx}:#{dev.name}\n"
	}
	msg += "Select device? \n"

	msgwin = Window.new(10,50,3,3)
	begin
		msgwin.box(?|,?-,?*)
		msgwin.setpos(1,1)
		msgwin.addstr(msg)
		msgwin.refresh

		idx = get_command_number()
	ensure
		msgwin.close
	end

	if dev = sel_devs[idx]
		CAConsole::set_default_output_device(dev)
		devmsg = "Changed default output device #{dev.name} press key"
	else
		devmsg = "No changed press key"
	end

	msgwin = Window.new(5,50,3,3)
	begin
		msgwin.box(?|,?-,?*)
		msgwin.setpos(1,1)
		msgwin.addstr(devmsg)
		msgwin.refresh

		get_command()
	ensure
		msgwin.close
	end

end 

ope_seq = 1
smp_read_count = 0

init_screen
in_dev = CAConsole::default_input_device()

begin
	msgwin = stdscr.subwin(10,70,2,2)
	msgwin.box(?|,?-,?*)

	smp_win = Window.new(5,50,10,2)
	in_dev.start_input_stream do |de_smp|
		msg = ""
		proc = true
		de_smp.each_with_index do |sample, idx|
			if idx == 0 #描画抑制のための一時的措置
				smp_read_count += sample.size 
				if smp_read_count < 4000
					proc = false
				else
					smp_read_count = 0
				end
			end
		    max_val = 
		    	sample.map {|i| i.abs}.max
		    s = sprintf("ch%02d:%05d  ", idx, max_val)
		    msg += s
		end
		if proc
			smp_win.setpos(2,2)
		    smp_win.addstr(msg)
		    smp_win.refresh
		end
	end

	loop{
		msgwin.setpos(2,2)
		msgwin.addstr(get_banner)
		msgwin.refresh

		case get_command()
		when 'o' then
			select_output_dev()
		when 'q' then
		    break
		end

		ope_seq+=1
	}
rescue => e
	p e
ensure
	in_dev.stop_input_stream
	close_screen
end



