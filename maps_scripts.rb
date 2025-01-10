##################################################
# Load Files Into MAPS Instrument Memory
# Author: Daniel Fonseka (daniel.fonseka@swri.org)
# Date: 09/22/21
# 
#
# Revisions:
# 20221108 kmello,    Updated cmd arg changes.
# 20230407 sescobedo, Adapted for MAPS 0407/23 by Stephen Escobedo
#
##################################################
require 'cosmos'
require 'cosmos/script'

#load 'config/targets/MAPS/procedures/scripts/helpers/cmd_tools.rb'  # utilities we don't want script runner to step through
load 'cmd_tools.rb'  # utilities we don't want script runner to step through

# TODO: Add checksums, once we discuss which telem packet they are in
# TODO: Find a way to automatically determine the max chunk size or read a
# TODO: config file to retrieve the maximum chunk size
CHUNK_SIZE   = 128 # in bytes
PAYLOAD_SIZE = 256

LUT_SET_0    = 0


#Conversions for HV targets versus real command value
#BULK: m=.8597, x=-1217.4
#MCP_ELE: m=1.5892, x=17.494
#MCP_ION: m-1.5902, x=15.814
#ESA_ELE Lo: m=4.1825, x=1561.2
#ESA_ELE Hi: m=.7782, x=1580.1
#ESA_ION Lo: m=4.2283, x=1544
#ESA_ION Hi: m=.7792, x=1520.8
#DEF_ELE Lo Neg: m=3.9533, x=1540.5
#DEF_ELE Hi Neg: m=.2915, x=1512.7
#DEF_ELE Lo Pos: m=3.9419, x=1562.7
#DEF_ELE Hi Pos: m=.2916, x=1586.1
#DEF_ION Lo Neg: m=3.9533, x=1540.5
#DEF_ION Hi Neg: m=.2947, x=1515.1
#DEF_ION Lo Pos: m=3.9655, x=1563.1
#DEF_ION Hi Pos: m=.2966, x=1591.4

# --------------------------------------------------------------------
def full_sweep(iminimum, imaximum, istep, eminimum, emaximum, estep, dminimum, dmaximum, dstep, delay)
  puts "INSTRUMENT ROTATING AND INTERLEAVED ESA SWEEPING FROM #{iminimum} TO #{imaximum} IN #{istep} EVERY #{delay} SECONDS"
  ins_rot = iminimum
  loop do
    prompt("ROTATE INSTRUMENT TO OUTER ROTATION #{ins_rot} AND THEN PRESS OKAY WHEN READY TO SAMPLE")
    esa_def_sweep(eminimum, emaximum, estep, dminimum, dmaximum, dstep, delay)
    break if ins_rot >= imaximum
    ins_rot = ins_rot + istep
    wait(delay)
  end
end

# --------------------------------------------------------------------
def esa_def_sweep(eminimum, emaximum, estep, dminimum, dmaximum, dstep, delay)
  puts "INTERLEAVED ESA SWEEPING FROM #{eminimum} TO #{emaximum} IN #{estep} EVERY #{delay} SECONDS"
  esa_ele_volt = eminimum
  esa_ion_volt = -1*eminimum
  loop do
    esa_ele_set(esa_ele_volt)
    esa_ion_set(esa_ion_volt)
    break if esa_ele_volt >= emaximum
    esa_ele_volt = esa_ele_volt + estep
    esa_ion_volt = esa_ion_volt - estep
    wait(delay)
    def_sweep(dminimum, dmaximum, dstep, delay)
  end
end

# --------------------------------------------------------------------
def esa_sweep(minimum, maximum, step, delay)
  puts "ESA SWEEPING FROM #{minimum} TO #{maximum} IN #{step} EVERY #{delay} SECONDS"
  esa_ele_volt = minimum
  esa_ion_volt = -1*minimum
  loop do
    esa_ele_set(esa_ele_volt)
    esa_ion_set(esa_ion_volt)
    break if esa_ele_volt >= maximum
    esa_ele_volt = esa_ele_volt + step
    esa_ion_volt = esa_ion_volt - step
    puts "ESA STEPPED TO #{esa_ele_volt} AND WAITING SETTLE TIME"
    wait(delay)
  end
end

# --------------------------------------------------------------------
def def_sweep(minimum, maximum, step, delay)
  puts "DEFLECTOR SWEEPING FROM #{minimum} TO #{maximum} IN #{step} EVERY #{delay} SECONDS"
  def_ele_volt = minimum
  def_ion_volt = -1*minimum
  loop do
    def_ele_set(def_ele_volt)
    def_ion_set(def_ion_volt)
    break if def_ele_volt >= maximum
    def_ele_volt = def_ele_volt + step
    def_ion_volt = def_ion_volt - step
    puts "DEFLECTOR STEPPED TO #{def_ele_volt} AND WAITING SETTLE TIME" 
    wait(delay)
  end
end

# --------------------------------------------------------------------
def bulk_set(voltage)
  puts "BULK TO: #{voltage}"
  volt_conv = voltage*(0.8597)-1217.4
  if volt_conv < 0 then
    volt_conv = 0
  end
  volt = volt_conv.round()
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097217, VALUE #{volt}")
end

# --------------------------------------------------------------------
def mcp_ion_set(voltage)
  puts "MCP ION TO: #{voltage}"
  volt_conv = voltage*(-1.5902)+15.814
  volt = volt_conv.round()
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE #{volt}")
end

# --------------------------------------------------------------------
def mcp_ele_set(voltage)
  puts "MCP ELE TO: #{voltage}"
  volt_conv = voltage*1.5892+17.494
  volt = volt_conv.round()
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE #{volt}")
end

# --------------------------------------------------------------------
def def_ele_set(voltage)
  puts "DEF ELE TO: #{voltage}"
  if voltage.abs > 350 then
    if voltage > 0 then
      volt_conv = voltage*0.2916+1586.1
    else
      volt_conv = voltage*0.2915+1512.7
    end
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097345, VALUE #{volt}")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097348, VALUE 8192")
  else
    if voltage > 0 then
      volt_conv = voltage*3.9419+1562.7
    else
      volt_conv = voltage*3.9533+1540.5
    end
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097348, VALUE 0")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097345, VALUE #{volt}")
  end
end

# --------------------------------------------------------------------
def def_ion_set(voltage)
  puts "DEF ION TO: #{voltage}"
  if voltage.abs > 350 then
    if voltage > 0 then
      volt_conv = voltage*0.2966+1591.4
    else
      volt_conv = voltage*0.2947+1515.1
    end
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097281, VALUE #{volt}")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097284, VALUE 8192")
  else
    if voltage > 0 then
      volt_conv = voltage*3.9655+1563.1
    else
      volt_conv = voltage*3.9533+1540.5
    end
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097284, VALUE 0")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097281, VALUE #{volt}")
  end
end

# --------------------------------------------------------------------
def esa_ele_set(voltage)
  puts "ESA ELE TO: #{voltage}"
  if voltage.abs > 350 then
    volt_conv = voltage*0.7782+1580.1
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE #{volt}")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097476, VALUE 8192")
  else
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097476, VALUE 0")
    volt_conv = voltage*4.1825+1561.2
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE #{volt}")
  end
end

# --------------------------------------------------------------------
def esa_ion_set(voltage)
  puts "ESA ION TO: #{voltage}"
  if voltage.abs > 350 then
    volt_conv = voltage*0.7792+1520.8
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE #{volt}")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097412, VALUE 8192")
  else
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097412, VALUE 0")
    volt_conv = voltage*4.2283+1544
    volt = volt_conv.round()
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE #{volt}")
  end
end

# --------------------------------------------------------------------
def select_binary_file()
  selected_file = open_file_dialog(Cosmos::USERPATH, "Select Binary File to Load")
  if not selected_file.empty? then
    start_addr =  ask("Please enter the destination address.")

    until selected_file
      intent = message_box("Do you want to upload a file?", "Yes", "No", false)
      if intent == "No"
        abort("No File Uploaded")
      end
      selected_file = open_file_dialog()
    end

    load_data_from_file(selected_file, start_addr)
  end
end

# --------------------------------------------------------------------
def load_data_from_file(file_path, addr_start)
  if File::exists? file_path then
    puts("Reading File: #{file_path}")
    data_arr = File.open(file_path, "rb").read.bytes
    send_data_chunks(data_arr, addr_start)
    #send_dhvps_chunks(data_arr, 0, 0)
  end
end

# --------------------------------------------------------------------
def load_hv_table()
  selected_file = open_file_dialog(Cosmos::USERPATH, "Select Ascii File to Load")
  if not selected_file.empty? then

    until selected_file
      intent = message_box("Do you want to upload a file?", "Yes", "No", false)
      if intent == "No"
        abort("No File Uploaded")
      end
      selected_file = open_file_dialog()
    end

    load_table_from_file(selected_file)
  end
end

# --------------------------------------------------------------------
def load_table_from_file(file_path)
  if File::exists? file_path then
    puts("Reading File: #{file_path}")
    File.open(file_path).each do |line|
      arr = line.split(" ")
      addr = Integer(arr[0])
      data = Integer(arr[1])
      cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS #{addr}, VALUE #{data}")
      #puts("cmd(\"MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS #{addr}, VALUE #{data}\")")
      #sleep(0.1)
    end
  end
end

# --------------------------------------------------------------------
def tdc_bin_set()
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63780, DATA 67371009")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63872, DATA 100")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63876, DATA 6619449")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63880, DATA 20578805")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63884, DATA 32834217")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63888, DATA 44630917")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63892, DATA 59114582")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63896, DATA 72811822")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63900, DATA 86967860")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63904, DATA 104072997")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63908, DATA 119933138")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63912, DATA 148048337")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63916, DATA 164760330")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63920, DATA 185273319")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63924, DATA 199756993")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63928, DATA 214044048")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63932, DATA 227610243")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63936, DATA 243535838")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63940, DATA 266277153")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63944, DATA 287445502")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63948, DATA 301929154")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63952, DATA 314774407")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63956, DATA 327685205")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63960, DATA 341120283")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63964, DATA 354162228")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63968, DATA 372578147")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63972, DATA 392435796")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63976, DATA 408230293")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63980, DATA 429267741")
  sleep(0.5)
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63984, DATA 454958904")
  sleep(0.5)
end  

# --------------------------------------------------------------------
def MAPS_STARTUP()
cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63536, DATA 38320")
wait(5)
tdc_bin_set()
wait(1)
cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ELC, START/STOP START, FEE_CFD_THR 2400")
wait(1)
cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ELC, START/STOP STOP, FEE_CFD_THR 2400")
wait(1)
cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ION, START/STOP STOP, FEE_CFD_THR 2400")
wait(1)
cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ION, START/STOP START, FEE_CFD_THR 2400")
wait(5)
cmd("MAPS MAPS_TDC_CALIBRATE with <OPCODE> 36")
wait(5)
cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE HVENG")
wait(1)
cmd("MAPS MAPS_HVPS_EN with <OPCODE> 20, HVPS_STATE ENABLED")
wait(5)
bulk_set(5800)
wait(5)
mcp_ion_set(-100)
mcp_ele_set(100)
wait(4)
mcp_ion_set(-200)
mcp_ele_set(200)
wait(4)
mcp_ion_set(-300)
mcp_ele_set(300)
wait(4)
mcp_ion_set(-400)
mcp_ele_set(400)
wait(4)
mcp_ion_set(-500)
mcp_ele_set(500)
wait(4)
mcp_ion_set(-600)
mcp_ele_set(600)
wait(4)
mcp_ion_set(-700)
mcp_ele_set(700)
wait(4)
mcp_ion_set(-800)
mcp_ele_set(800)
wait(4)
mcp_ion_set(-900)
mcp_ele_set(900)
wait(4)
mcp_ion_set(-1000)
mcp_ele_set(1000)
wait(4)
mcp_ion_set(-1100)
mcp_ele_set(1100)
wait(4)
mcp_ion_set(-1200)
mcp_ele_set(1200)
wait(4)
mcp_ion_set(-1300)
mcp_ele_set(1300)
wait(4)
mcp_ion_set(-1400)
mcp_ele_set(1400)
wait(4)
mcp_ion_set(-1500)
mcp_ele_set(1500)
wait(4)
mcp_ion_set(-1600)
mcp_ele_set(1600)
wait(10)
mcp_ion_set(-1700)
mcp_ele_set(1700)
wait(10)
mcp_ion_set(-1800)
mcp_ele_set(1800) 
wait(10)
mcp_ion_set(-1900)
mcp_ele_set(1900)
wait(10)
mcp_ion_set(-2000)
mcp_ele_set(2000)
wait(10)
def_ion_set(0)
def_ele_set(0)
wait(1)
esa_ion_set(0)
esa_ele_set(0)
wait(1)
end

# --------------------------------------------------------------------
def sweep_esa_900_1100()
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097412, VALUE 8192")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097476, VALUE 8192")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 819")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2280")
  wait(1)
  
  #910 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 811")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2288")
  wait(1)

  #910 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 811")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2288")
  wait(1)
  
  #920 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 803")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2296")
  wait(1)
  
  #930 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 795")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2304")
  wait(1)
  
  #940 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 788")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2312")
  wait(1)
  
  #950 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 780")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2320")
  wait(1)
  
  #960 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 772")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2327")
  wait(1)
  
  #970 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 765")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2334")
  wait(1)
  
  #980 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 757")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2342")
  wait(1)
  
  #990 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 749")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2350")
  wait(1)
  
  #1000 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 741")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2358")
  wait(1)
  
  #1010 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 733")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2366")
  wait(1)
  
  #1020 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 726")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2373")
  wait(1)
  
  #1030 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 718")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2381")
  wait(1)
  
  #1040 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 710")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2389")
  wait(1)
  
  #1050 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 702")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2397")
  wait(1)
  
  #1060 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 694")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2404")
  wait(1)
  
  #1070 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 687")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2412")
  wait(1)
  
  #1080 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 679")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2420")
  wait(1)
  
  #1090 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 671")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2428")
  wait(1)
  
  #1100 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 663")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2436")
  wait(1)
  
  #Half way: ramping back down to 910
  
  #1090 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 671")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2428")
  wait(1)
  
  #1080 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 679")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2420")
  wait(1)
  
  #1070 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 687")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2412")
  wait(1)
  
  #1060 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 694")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2404")
  wait(1)
  
  #1050 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 702")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2397")
  wait(1)
  
  #1040 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 710")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2389")
  wait(1)
  
  #1030 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 718")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2381")
  wait(1)
  
  
  #1020 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 726")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2373")
  wait(1)
  
  #1010 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 733")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2366")
  wait(1)
  
  #1000 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 741")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2358")
  wait(1)
  
  #990 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 749")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2350")
  wait(1)
  
  #980 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 757")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2342")
  wait(1)
  
  #970 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 765")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2334")
  wait(1)
  
  #960 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 772")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2327")
  wait(1)
  
  #950 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 780")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2320")
  wait(1)
  
  #940 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 788")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2312")
  wait(1)
  
  #930 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 795")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2304")
  wait(1)
  
  #920 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 803")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2296")
  wait(1)
  
  #910 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 811")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2288")
  wait(1)
end

# --------------------------------------------------------------------
def mcp_ramp_up()
  #100 V
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 175")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 176")
  wait(10)

  #200
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 334")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 335")
  wait(10)
  
  #300
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 492")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 494")
  wait(10)
  
  #400
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 652")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 653")
  wait(10)
  
  #500
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 811")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 812")
  wait(10)
  
  #600
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 970")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 971")
  wait(10)
  
  #700
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1129")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1130")
  wait(10)
  
  #800
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1288")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1289")
  wait(10)
  
  #900
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1447")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1448")
  wait(10)
  
  #1000
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1606")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1607")
  wait(10)
  
  #1100
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1765")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1766")
  wait(10)
  
  #1200
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 1924")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 1925")
  wait(10)

  #1300
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2083")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2083")
  wait(10)
  
  #1400
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2242")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2242")
  wait(10)
  
  #1500
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2401")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2401")
  wait(10)

  #1600
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2560")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2560")
  wait(30)
  
  #1700
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2719")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2719")
  wait(30)

  #1800
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 2878")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 2878")
  wait(30)

  #1900
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 3037")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 3037")
  wait(30)
  
  #2000
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097249, VALUE 3196")
  cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097265, VALUE 3196")
  wait(30)
end

# --------------------------------------------------------------------
def sweep_esa_700_1450()
  loop do
    #High Range
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097412, VALUE 8192")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097476, VALUE 8192")
    
    #700
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 975")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2124")
    wait(1)
    
    #750 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 936")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2163")
    wait(1)
  
    #800 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 897")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2202")
    wait(1)
    
    #850 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 858")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2241")
    wait(1)
    
    #900 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 819")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2280")
    wait(1)
    
    #950 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 780")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2319")
    wait(1)
    
    #1000 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 741")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2358")
    wait(1)
    
    #1050 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 702")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2397")
    wait(1)
    
    #1100 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 663")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2436")
    wait(1)
    
    #1150 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 624")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2475")
    wait(1)
    
    #1200 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 585")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2513")
    wait(1)
    
    #1250 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 546")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2552")
    wait(1)
    
    #1300 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 507")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2591")
    wait(1)
    
    #1350 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 468")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2630")
    wait(1)
    
    #1400 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 429")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2669")
    wait(1)
    
    #1450 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 390")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2708")
    wait(1)
  
  end
end

# --------------------------------------------------------------------
def sweep_esa_700_1450_def_n10_p10()
  loop do
    #High Range
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097412, VALUE 8192")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097476, VALUE 8192")
    
    #700
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 975")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2124")
    wait(1)
    
    #750 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 936")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2163")
    wait(1)
  
    #800 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 897")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2202")
    wait(1)
    
    #850 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 858")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2241")
    wait(1)
    
    #900 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 819")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2280")
    wait(1)
    
    #950 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 780")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2319")
    wait(1)
    
    #1000 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 741")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2358")
    wait(1)
    
    #1050 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 702")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2397")
    wait(1)
    
    #1100 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 663")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2436")
    wait(1)
    
    #1150 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 624")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2475")
    wait(1)
    
    #1200 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 585")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2513")
    wait(1)
    
    #1250 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 546")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2552")
    wait(1)
    
    #1300 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 507")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2591")
    wait(1)
    
    #1350 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 468")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2630")
    wait(1)
    
    #1400 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 429")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2669")
    wait(1)
    
    #1450 V
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097409, VALUE 390")
    cmd("MAPS MAPS_DHVPS_RAW with <OPCODE> 80, READ_WRITE 1, ADDRESS 2097473, VALUE 2708")
    wait(1)
  
  end
end

# --------------------------------------------------------------------
def send_dhvps_chunks(data_arr, lut_set, lut_select, chunk_size = CHUNK_SIZE, patch_data = true)
  if data_arr.is_a? Array then
    data_arrs = data_arr.each_slice(chunk_size).to_a
    addr_arr  = (0 ... data_arr.size).step(chunk_size).to_a
    
     
    # Checksums of the packets are not yet used for MAPS DHVPS loading 
    # quicker in test runner to run here without interpreting
    # cksum = calc_chksum(data_arr)
    # puts("data_size: %d bytes, cksum: 0x%X" % [data_arr.size, cksum])
    
    num_chunks = addr_arr.size.to_f
    puts("Num_chunks: #{num_chunks} of size #{chunk_size}")
    cnt = 1
    addr_arr.zip(data_arrs).each do |addr, data|
      status_bar("Dhvps_LOAD[0x%04X] %0.0f%%" % [addr, (cnt / num_chunks)*100])
      cmd("MAPS", "MAPS_DHVPS_LOAD", "offset_in_bytes" => addr, "num_bytes" => chunk_size, "data" => data.pack("C*"))
      cnt += 1
      wait(1)# wait here ?
    end
    status_bar("Memory Load Complete.")
    
    # Move the data over from the scratch to the destination
    status_bar("Patching data...")
    puts("Patching data.")
    if patch_data then
      cmd("MAPS", "MAPS_DHVPS_COPY", "set" => lut_set, "select" => lut_select, "len" => data_arr.size/2)
    end
    status_bar("Patching complete!")
    puts("Patching complete.")
    
    # wait for patch cmd to finish and report in HK ...
    # wait(5)
    # wait_packet("MAPS", "HK", 2, 30, 1)  # wait for an updated HK packet
    # wait_check("MAPS BOOT_HK MEM_LD_STATE == 'SUCCESS'", 30, 1)
    
    # verify mem_ld_state not chkfail ?
    # ld_state = tlm("MAPS BOOT_HK MEM_LD_STATE")
    # dmp_state = tlm("MAPS BOOT_HK MEM_DMP_STATE")
    # puts("MEM_LD_STATE: #{ld_state}")
    # puts("MEM_DMP_STATE: #{dmp_state}") 
    
    # check("MAPS BOOT_HK MEM_LD_STATE == 'SUCCESS'")
    # if (ld_state != "SUCCESS")
    #   puts("ERROR: PATCH FAILED.")
    # end
    
    # mem_reset here to clear mem_ld_state ?
    # cmd("MAPS", "MAPS_MEM_RESET")
    
  end
end

# --------------------------------------------------------------------
def send_data_chunks(data_arr, dest_addr, chunk_size = CHUNK_SIZE, patch_data = true)
  if data_arr.is_a? Array then
    data_arrs = data_arr.each_slice(chunk_size).to_a
    addr_arr  = (0 ... data_arr.size).step(chunk_size).to_a
    
    # quicker in test runner to run here without interpreting
    cksum = calc_chksum(data_arr)
    puts("data_size: %d bytes, cksum: 0x%X" % [data_arr.size, cksum])
    
    num_chunks = addr_arr.size.to_f
    puts("Num_chunks: #{num_chunks} of size #{chunk_size}")
    cnt = 1
    addr_arr.zip(data_arrs).each do |addr, data|
      status_bar("Mem_LOAD[0x%04X] %0.0f%%" % [addr, (cnt / num_chunks)*100])
      cmd("MAPS", "MAPS_MEM_LOAD", "offset" => addr, "num_bytes" => chunk_size, "data" => data.pack("C*"))
      cnt += 1
      sleep(0.75)# wait here ?
    end
    status_bar("Memory Load Complete.")
    
    # Move the data over from the scratch to the destination
    status_bar("Patching data...")
    puts("Patching data.")
    if patch_data then
      cmd("MAPS", "MAPS_MEM_PATCH", "address" => dest_addr, "cksum" => cksum, "data_len" => data_arr.size)
    end
    status_bar("Patching complete!")
    puts("Patching complete.")
    
    # wait for patch cmd to finish and report in HK ...
    wait(5)
    wait_packet("MAPS", "BOOT_HK", 2, 30, 1)  # wait for an updated HK packet
    wait_check("MAPS BOOT_HK MEM_LD_STATE == 'SUCCESS'", 30, 1)
    
    # verify mem_ld_state not chkfail ?
    ld_state = tlm("MAPS BOOT_HK MEM_LD_STATE")
    dmp_state = tlm("MAPS BOOT_HK MEM_DMP_STATE")
    puts("MEM_LD_STATE: #{ld_state}")
    puts("MEM_DMP_STATE: #{dmp_state}") 
    
    check("MAPS BOOT_HK MEM_LD_STATE == 'SUCCESS'")
    if (ld_state != "SUCCESS")
      puts("ERROR: PATCH FAILED.")
    end
    
    # mem_reset here to clear mem_ld_state ?
    cmd("MAPS", "MAPS_MEM_RESET")
    
  end
end

# --------------------------------------------------------------------
def tdc_startup()
  cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63536, DATA 38320")
  sleep(0.5)
  tdc_bin_set()
  sleep(0.5)
  cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ELC, START/STOP START, FEE_CFD_THR 2400")
  sleep(0.5)
  cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ELC, START/STOP STOP, FEE_CFD_THR 2400")
  sleep(0.5)
  cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ION, START/STOP STOP, FEE_CFD_THR 2400")
  sleep(0.5)
  cmd("MAPS MAPS_FEE_SET_THR with <OPCODE> 37, SENSOR ION, START/STOP START, FEE_CFD_THR 2400")
  sleep(0.5)
  cmd("MAPS MAPS_TDC_CALIBRATE with <OPCODE> 36")
  sleep(0.5)
end

# --------------------------------------------------------------------
def tdc_stim(enable)
  if enable then
    #Electron stim at 50 kHz, 40 ns delay
    cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63792, DATA 590465")
    sleep(2)
    #Ion stim at 100 kHz, 40 ns delay
    cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63796, DATA 590753")
  else
    #Disable both STIMS
    cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63792, DATA 589985")
    sleep(2)
    cmd("MAPS MAPS_MEM_POKE with <OPCODE> 7, ADDRESS 63796, DATA 589985")
  end
end

# --------------------------------------------------------------------
def maps_lpt()
  #Enable Sorensen Power
  cmd("DLM4015 PWR_ON with PWR_STATE ON, CMD_TEMPLATE 'OUTP:STAT <PWR_STATE>', RSP_TEMPLATE '<OUTP_STAT>', RSP_PACKET 'TLM'")
  
  #Wait for LVENG
  wait_check_packet("MAPS", "HK", 1, 45, 1)
  puts("Successfully booted into Application Code.")
  prompt("Successfully booted into Application Code.")
    
  #TDC calibration and enable
  tdc_startup()
  sleep(5)  

  #Switch to LVSCI mode and verify no counts are being received
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE LVSCI")
  sleep(5)
  wait_check_packet("MAPS", "SCI_ION", 1, 10, 1)
  puts("Successfully received science packet.")
  wait_check("MAPS SCI_UTIL DF_SUM < 10", 10, 1)
  puts("Successfully verified no counts in science packet.")
  prompt("Successfully verified no counts in science packet.")
  sleep(5)  

  #Switch to LVENG and enable STIM and go back to LVSCI and detect STIM counts
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE LVENG")
  sleep(2)
  tdc_stim(1)
  sleep(2)
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE LVSCI")
  puts("Successfully received science packet.")
  wait_check("MAPS SCI_UTIL DF_SUM > 100", 10, 1)
  puts("Successfully verified STIM counts in science packet.")
  prompt("Successfully verified STIM counts in science packet.")
  sleep(5)
  
  #Switch to LVENG and disable STIM, try to enable HV and expected fail
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE LVENG")
  sleep(2)
  tdc_stim(0)
  sleep(2)
  cmd("MAPS MAPS_HVPS_EN with <OPCODE> 20, HVPS_STATE ENABLED")
  sleep(2)
  wait_check("MAPS HK HV_ENABLE == 'DISABLED'", 10, 1)
  puts("Successfully verified HV enable fails in LVENG.")
  prompt("Successfully verified HV enable fails in LVENG.")
  sleep(5)  
  
  #Switch to HVENG, enable bulk, and verify bulk output
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE HVENG")
  sleep(2)
  cmd("MAPS MAPS_HVPS_EN with <OPCODE> 20, HVPS_STATE ENABLED")
  sleep(2)  
  puts("Successfully verified HV enable works in HVENG.")
  prompt("Successfully verified HV enable works in HVENG.")
  bulk_set(2000)
  wait_check("MAPS HK HVPS_BULK_POS_VMON > 500", 10, 1)
  sleep(2)
  puts("Successfully verified HV enable works in HVENG and bulk can be powered.")
  prompt("Successfully verified HV enable works in HVENG and bulk can be powered.")
  sleep(5)
  
  #Switch to LVENG, verify HV is disabled again
  cmd("MAPS MAPS_SET_MODE with <OPCODE> 10, MODE LVENG")
  sleep(2)
  wait_check("MAPS HK HV_ENABLE == 'DISABLED'", 10, 1)
  puts("Successfully verified HV is disabled when switched into LVENG.")
  prompt("Successfully verified HV is disabled when switched into LVENG.")
  
  puts("LPT Completed Successfully.")
  prompt("LPT Completed Successfully.")
end

# This function sends a command to invoke run('inner_rotation_script[<angle>]')
# with correct padding so that STRING_LENGTH = 44 and LENGTH = 48, matching your example.
# You can adjust PKT_ID if needed.
def inner_rotation_cmd(angle)
  # 1) Build the un-padded string
  #    For example: "run('inner_rotation_script[45]')"
  #    But from your snippet, it looks like you have literal parentheses inside single quotes.
  #    We'll match that style: run('inner_rotation_script[45]')
  unpadded = "run('inner_rotation_script[#{angle}]')"

  # 2) Pad the string to length 44 total
  #    The original snippet had some trailing spaces.
  desired_len = 44
  if unpadded.size < desired_len
    padded_str = unpadded.ljust(desired_len, ' ')
  else
    # If for some reason it's longer, you might need to raise an error or trim.
    raise "Command string exceeded 44 chars (#{unpadded.size}). Increase LENGTH or shorten the string."
  end

  # 3) Now send the command
  #    Hardcoding SYNC=3735928559 (0xDEADBEEF), PKT_TYPE=6, PKT_ID=0, etc., per your example.
  #    LENGTH=48 => 4 bytes overhead plus 44 bytes of string in your example.
  #    STRING_LENGTH=44 => how many chars in 'COMMAND_NAME'.
  cmd("DELPHY RUN_SCRIPT with SYNC 3735928559, \
                           PKT_TYPE 6, \
                           PKT_ID 0, \
                           SESSION_TIME 0, \
                           PACKET_TIME 0, \
                           LENGTH 48, \
                           STRING_LENGTH 44, \
                           COMMAND_NAME '#{padded_str}'")
end

# Similar function for the outer rotation script
def outer_rotation_cmd(angle)
  # e.g. "run('outer_rotation_script[45]')"
  unpadded = "run('outer_rotation_script[#{angle}]')"

  desired_len = 44
  if unpadded.size < desired_len
    padded_str = unpadded.ljust(desired_len, ' ')
  else
    raise "Command string exceeded 44 chars (#{unpadded.size}). Increase LENGTH or shorten the string."
  end

  cmd("DELPHY RUN_SCRIPT with SYNC 3735928559, \
                           PKT_TYPE 6, \
                           PKT_ID 0, \
                           SESSION_TIME 0, \
                           PACKET_TIME 0, \
                           LENGTH 48, \
                           STRING_LENGTH 44, \
                           COMMAND_NAME '#{padded_str}'")
end

def full_sweep_auto(i_min, i_max, i_step,
                      o_min, o_max, o_step,
                      e_min, e_max, e_step,
                      d_min, d_max, d_step,
                      delay)
  puts "AUTO SWEEP STARTED:"
  puts "  Inner rotation from #{i_min}..#{i_max}, step=#{i_step}"
  puts "  Outer rotation from #{o_min}..#{o_max}, step=#{o_step}"
  puts "  ESA/Def sweeps from ESA=#{e_min}..#{e_max}, Def=#{d_min}..#{d_max}, step=#{e_step}/#{d_step}"
  puts "  Using delay of #{delay} second(s) between steps."

  # Loop over INNER rotation
  inner_rot = i_min
  loop do
    # Command the inner rotation
    puts "Setting INNER rotation to #{inner_rot}"
    inner_rotation_cmd(inner_rot)  # Calls your function that sends the cmd
    wait(delay)                    # Allow hardware to settle

    # Loop over OUTER rotation
    outer_rot = o_min
    loop do
      # Command the outer rotation
      puts "Setting OUTER rotation to #{outer_rot}"
      outer_rotation_cmd(outer_rot)  # Calls your function that sends the cmd
      wait(delay)

      # Now run the ESA/Deflector sweep at this inner & outer angle
      esa_def_sweep(e_min, e_max, e_step, d_min, d_max, d_step, delay)

      # Increment outer rotation
      break if outer_rot >= o_max
      outer_rot += o_step
      wait(delay)
    end

    # Increment inner rotation
    break if inner_rot >= i_max
    inner_rot += i_step
    wait(delay)
  end

  puts "AUTO FULL SWEEP COMPLETE."
end




# --------------------------------------------------------------------
# MAIN
maps_lpt()
#tdc_stim(1)
#tdc_startup()
#select_binary_file()
#load_hv_table()
#def esa_def_sweep(eminimum, emaximum, estep, dminimum, dmaximum, dstep, delay)
#sweep_esa_700_1400()
#tdc_startup()
#tdc_bin_set()
#mcp_ramp_up()
#full_sweep(iminimum, imaximum, istep, eminimum, emaximum, estep, dminimum, dmaximum, dstep, delay)
#full_sweep(43, 43, 1, 63, 83, 1, -10, 2, 1, 2)
#esa_sweep(min, max, step, delay)
#def_ion_set(0)
#def_ele_set(0)
#esa_sweep(60, 70, 1, 3)
#def_sweep(min, max, step, delay)
#loop do
#def_sweep(-20,20,2,2)
#end
#esa_def_sweep(emin, emax, estep, dmin, dmax, dstep, delay)
#esa_def_sweep(73, 76, 1, -10, 10, 1, 2)
# ---------Startup the Instrument-----------------------------------------------------------------------------
#MAPS_STARTUP()
# ---------Startup the Instrument-----------------------------------------------------------------------------
#bulk_set(0)
#esa_ion_set(0)
#esa_ele_set(0)
#def_ion_set(0)
#def_ele_set(0)
#mcp_ion_set(-2050)
#mcp_ele_set(200)
#mcp_ion_set(0)
#mcp_ele_set(0)

# Suppose you want:
#   Inner rotation: 0 to 90 in steps of 30
#   Outer rotation: 0 to 180 in steps of 60
#   ESA sweep: 60..80 in steps of 5
#   Def sweep: -10..10 in steps of 10
#   2 seconds delay

full_sweep_nested(
  0,   90, 30,       # i_min, i_max, i_step
  0,   180, 60,      # o_min, o_max, o_step
  60,  80,  5,       # e_min, e_max, e_step
  -10, 10,  10,      # d_min, d_max, d_step
  2                  # delay (seconds)
)
