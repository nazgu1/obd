module OBD
  class Connection
    def initialize port, baud = 9600
      @port = port
      @baud = baud

      connect
    end

    def voltage
      send("AT RV")
    end

    def connect
      @serial_port = SerialPort.new @port, @baud # , data_bits: 8, stop_bits: 1, parity: SerialPort::NONE
      @serial_port.read_timeout = 2000
      @serial_port.gets("\r\r>").to_s.chomp("\r\r>")
      send("AT E0")    # turn echo off
      send("AT L0")    # turn linefeeds off
      send("AT S0")    # turn spaces off
      send("AT AT2")   # respond to commands faster
      send("AT SP 00") # automatically select protocol
    end

    def [] command
      OBD::Command.format_result(command, send(OBD::Command.to_hex(command)))
    end

    def send data
      write data
      read
    end

    private

    def read
      data = ''

      while data == '' || data[0] == 'S' do #if data is empty or ELM is in SEARCHING or STOPPED state
        begin
          data = @serial_port.gets("\r\r>").to_s.chomp("\r\r>")
        resque
          return false
        end
      end

      return data
    end

    def write data
      @serial_port.write data.to_s + "\r"
    end
  end
end
