TARGET=setbit

OBJS+=setbit.v

ICELINK_DEV = /dev/$(shell lsblk -f | grep iCELink | cut -d' ' -f1)
ICELINK_TMP = /tmp/iCELink

.PHONY: all clean

all: synt sim

synt: $(TARGET).bit

sim:$(TARGET)_tb.gtkw 

# Synthesis
$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -top $(TARGET) -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json $(TARGET).lpf
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack $< $@

# Simulation
$(TARGET)_tb.out: $(TARGET).v $(TARGET)_tb.v
	iverilog -o $@ $^

$(TARGET)_tb.vcd: $(TARGET)_tb.out
	./$<

$(TARGET)_tb.gtkw: $(TARGET)_tb.vcd 
	gtkwave $< $@ &

# Flashing
flash: flash-mount

flash_mount: $(TARGET).bit
	mkdir -p $(ICELINK_TMP)
	sudo mount $(ICELINK_DEV) $(ICELINK_TMP)
	cp $< $(ICELINK_TMP)
	sync
	sudo umount $(ICELINK_TMP)

flash_icesprog: $(TARGET).bit
	sudo icesprog $<

flash_ecpdap: $(TARGET).bit
	sudo ecpdap program --freq 5000 $<

flash_spi_ecpdap: $(TARGET).bit
	sudo ecpdap flash write --freq 5000 $<

# Cleaning
clean:
	rm -f *.json *_out.config *.bit *_tb.vcd *_tb.gktw *_tb.out

