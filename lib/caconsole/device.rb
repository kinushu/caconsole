require 'coreaudio'

module CAConsole


class Device
	attr_accessor :dev, :buf_count, :in_buf, :in_ch, :in_thread

	def initialize(dev)
		@dev = dev

		@buf_count = 1024
		@in_buf = dev.input_buffer(@buf_count)
		@in_ch  = dev.input_stream.channels

		@in_thread = nil
	end

	def name
		@dev.name
	end

def deinterleave_sample(samples, ch)
	# input is interleave samples
	real_sample_num = samples.size / ch
	de_samples = []
	for now_ch in 0..(ch-1) do
		now_ch_samples = []
		for smp_idx in 0..(real_sample_num-1) do
			now_ch_samples[smp_idx] = samples[(smp_idx*ch)+now_ch]
		end
		de_samples[now_ch] = now_ch_samples
	end

	de_samples
end


	def start_input_stream
		@in_buf.start
		@in_thread = Thread.start do
			loop do
				sample = @in_buf.read(@buf_count)
				de_smp = deinterleave_sample(sample,@in_ch)
				yield(de_smp)
			end
		end
	end

	def stop_input_stream
		@in_buf.stop
		if !(@in_thread.nil?)
			@in_thread.kill.join
			@in_thread = nil
		end
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

