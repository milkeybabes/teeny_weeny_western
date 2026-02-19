65C816

; ALL segment definitions to appear here

	SEGMENT byte at 808000-80FF7F 'bank0ROM'
; vectors: assemble long abs jumps in vjdata, with dest address vecjmps
	SEGMENT para at 80FF10-80FF1F 'backchannel'
	SEGMENT byte at 80FF80-80FFDF 'vjdata'
	SEGMENT byte at   FF80-FFDF   'vecjmps'
	SEGMENT byte at 80FFE4-80FFFF 'vecdata'
	SEGMENT byte at   FFE4-FFFF   'vectors'

	SEGMENT byte at 818000-81FFFF 'bank1ROM'
	SEGMENT byte at 828000-82FFFF 'bank2ROM'
	SEGMENT byte at 838000-83FFFF 'bank3ROM'
	SEGMENT byte at 848000-84FFFF 'bank4ROM'
	SEGMENT byte at 858000-85FFFF 'bank5ROM'
	SEGMENT byte at 868000-86FFFF 'bank6ROM'
	SEGMENT byte at 878000-87FFFF 'bank7ROM'
	SEGMENT byte at 888000-88FFFF 'bank8ROM'
	SEGMENT byte at 898000-89FFFF 'bank9ROM'
	SEGMENT byte at 8A8000-8AFFFF 'bankAROM'
	SEGMENT byte at 8B8000-8BFFFF 'bankBROM'
	SEGMENT byte at 8C8000-8CFFFF 'bankCROM'
	SEGMENT byte at 8D8000-8DFFFF 'bankDROM'
	SEGMENT byte at 8E8000-8EFFFF 'bankEROM'
	SEGMENT byte at 8F8000-8FFFFF 'bankFROM'

	SEGMENT byte at 908000-90FFFF 'bank10ROM'
	SEGMENT byte at 918000-91FFFF 'bank11ROM'
	SEGMENT byte at 928000-92FFFF 'bank12ROM'
	SEGMENT byte at 938000-93FFFF 'bank13ROM'

	SEGMENT byte at 000000-001FFF 'banklowRAM'
	SEGMENT byte at 000200-001FFF 'bankcommon'

	SEGMENT	byte at 7E2000-7EFFFF 'bank7ERAM'
	SEGMENT byte at 7F0000-7FFFFF 'bank7FRAM'
	
	END

