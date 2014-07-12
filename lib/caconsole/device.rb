require 'coreaudio'

module CAConsole

def devices
	CoreAudio::devices
end

def set_default_output_device(dev)
	CoreAudio::set_default_output_device(dev)
end

def default_input_device
	CoreAudio::default_input_device
end

def default_output_device
	CoreAudio::default_output_device
end

def init
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


in_buf.stop
th.kill.join
view_th.kill.join

end

class Device

end

module_function :devices, :set_default_output_device, :default_input_device, :default_output_device

end

