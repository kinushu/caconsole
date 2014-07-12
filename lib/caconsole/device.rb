require 'coreaudio'

module CAConsole

class Device
	attr_accessor :dev

	def initialize(dev)
		@dev = dev
	end

	def name
		@dev.name
	end
end

def output_devices
	devs = CoreAudio::devices
	sel_devs = devs.select {|dev| 
		dev.output_stream.channels > 0
	}

	sel_devs.map {|dev| Device.new(dev)}
end

def set_default_output_device(dev)
	ca_dev = dev.dev
	CoreAudio::set_default_output_device(ca_dev)
end

def default_input_device
	Device.new(CoreAudio::default_input_device)
end

def default_output_device
	Device.new(CoreAudio::default_output_device)
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

module_function :output_devices, :set_default_output_device, :default_input_device, :default_output_device

end

