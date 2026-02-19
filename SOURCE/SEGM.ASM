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
        SEGMENT byte at 948000-94FFFF 'bank14ROM'
        SEGMENT byte at 958000-95FFFF 'bank15ROM'
        SEGMENT byte at 968000-96FFFF 'bank16ROM'
        SEGMENT byte at 978000-97FFFF 'bank17ROM'
        SEGMENT byte at 988000-98FFFF 'bank18ROM'
        SEGMENT byte at 998000-99FFFF 'bank19ROM'
        SEGMENT byte at 9A8000-9AFFFF 'bank1AROM'
        SEGMENT byte at 9B8000-9BFFFF 'bank1BROM'
        SEGMENT byte at 9C8000-9CFFFF 'bank1CROM'
        SEGMENT byte at 9D8000-9DFFFF 'bank1DROM'
        SEGMENT byte at 9E8000-9EFFFF 'bank1EROM'
        SEGMENT byte at 9F8000-9FFFFF 'bank1FROM'

	SEGMENT byte at 000000-001FFF 'banklowRAM'
	SEGMENT byte at 000200-001FFF 'bankcommon'

	SEGMENT	byte at 7E2000-7EFFFF 'bank7ERAM'
	SEGMENT byte at 7F0000-7FFFFF 'bank7FRAM'
	
	END

