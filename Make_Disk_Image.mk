FAT_SECTORS:=65536
DISK_SECTORS:=69632
DISK_START:=2048
DISK_END:=67584

TEMP_IMG := temp.img
PARTED := sudo parted
PARTED_PARAMS := -s -a minimal

partition.img: $(FILES)
	dd if=/dev/zero of=$(TEMP_IMG) bs=512 count=$(FAT_SECTORS)
	mformat -i $(TEMP_IMG) -h 32 -t 32 -n 64 -c 1 ::
	mcopy -i $(TEMP_IMG) $(FILES) ::
	cp $(TEMP_IMG) $@
	rm $(TEMP_IMG)

hd.img: partition.img
	dd if=/dev/zero of=$(TEMP_IMG) bs=512 count=$(DISK_SECTORS)
	$(PARTED) $(TEMP_IMG) $(PARTED_PARAMS) mklabel gpt
	$(PARTED) $(TEMP_IMG) $(PARTED_PARAMS) mkpart EFI FAT16 $(DISK_START)s $(DISK_END)s
	$(PARTED) $(TEMP_IMG) $(PARTED_PARAMS) toggle 1 boot
	dd if=partition.img of=$(TEMP_IMG) bs=512 obs=512 count=$(FAT_SECTORS) seek=$(DISK_START) conv=notrunc
	cp $(TEMP_IMG) $@
	rm $(TEMP_IMG)
