ProjectName		= ShellcodeTemplate

CCX64			= x86_64-w64-mingw32-gcc
CCX86			= i686-w64-mingw32-gcc

CFLAGS			=  -Os -fno-asynchronous-unwind-tables -nostdlib 
CFLAGS 			+= -fno-ident -fpack-struct=8 -falign-functions=1
CFLAGS  		+= -s -ffunction-sections -falign-jumps=1 -w
CFLAGS			+= -falign-labels=1 -fPIC -Wl,-TScripts/Linker.ld
CFLAGS			+= -Wl,-s,--no-seh,--enable-stdcall-fixup
CFLAGS			+= -fno-stack-check -fno-stack-protector -mno-stack-arg-probe

EXEFLAGS                =  -DISEXE -Os -fno-asynchronous-unwind-tables -nostdlib 
EXEFLAGS                += -fno-ident -fpack-struct=8 -falign-functions=1
EXEFLAGS                += -s -ffunction-sections -falign-jumps=1 -w
EXEFLAGS                += -falign-labels=1 -fPIC
EXEFLAGS                += -Wl,-s,--no-seh,--enable-stdcall-fixup
EXEFLAGS				+= -fno-stack-check -fno-stack-protector -mno-stack-arg-probe

DLLFLAGS                =  -DISDLL --entry DllMain -shared -Os -fno-asynchronous-unwind-tables -nostdlib 
DLLFLAGS                += -fno-ident -fpack-struct=8 -falign-functions=1
DLLFLAGS                += -s -ffunction-sections -falign-jumps=1 -w
DLLFLAGS                += -falign-labels=1 -fPIC
DLLFLAGS                += -Wl,-s,--no-seh,--enable-stdcall-fixup
DLLFLAGS				+= -fno-stack-check -fno-stack-protector -mno-stack-arg-probe

EXECUTABLE_X64	= Bin/$(ProjectName).x64.exe
DLL_X64		= Bin/$(ProjectName).x64.dll
RAWBINARY_X64	= Bin/$(ProjectName).x64.bin

#EXECUTABLE_X86	= Bin/$(ProjectName).x86.exe
#RAWBINARY_X86	= Bin/$(ProjectName).x86.bin

all: x64 #x86

x64: clean
	@ echo "[*] Compile x64 executable to extract .text from..."
	
	@ nasm -f win64 Source/Asm/x64/asm.s -o Bin/asm.x64.o
	@ $(CCX64) Source/*.c Bin/asm.x64.o -o $(EXECUTABLE_X64).funny $(CFLAGS) -IInclude -masm=intel

	@ echo "[*] Extract shellcode: $(RAWBINARY_X64)"
	@ python3 Scripts/extract.py -f $(EXECUTABLE_X64).funny -o $(RAWBINARY_X64)
	@ rm $(EXECUTABLE_X64).funny
	
	@ echo "[*] Compile x64 executable..."
	@ $(CCX64) Source/*.c Bin/asm.x64.o -o $(EXECUTABLE_X64) $(EXEFLAGS) -IInclude -masm=intel
	@ echo "[+] $(EXECUTABLE_X64) is $$(ls -la $(EXECUTABLE_X64) | awk '{print $$5}') bytes long"
	
	@ echo "[*] Compiling x64 dll..."
	@ $(CCX64) Source/*.c Bin/asm.x64.o -o $(DLL_X64) $(DLLFLAGS) -IInclude -masm=intel
	@ echo "[+] $(DLL_X64) is $$(ls -la $(DLL_X64) | awk '{print $$5}') bytes long"

#x86: clean
#	@ echo "[*] Compile x86 executable..."
#
#	@ nasm -f win32 Source/Asm/x86/asm.s -o Bin/asm.x86.o
#	@ $(CCX86) Source/*.c Bin/asm.x86.o -o $(EXECUTABLE_X86) $(CFLAGS) $(LFLAGS) -IInclude -masm=intel
#
#	@ echo "[*] Extract shellcode: $(RAWBINARY_X86)"
#	@ python3 Scripts/extract.py -f $(EXECUTABLE_X86) -o $(RAWBINARY_X86)
#
#	@ rm $(EXECUTABLE_X86)

clean:
	@ rm -rf Bin/*.o
	@ rm -rf Bin/*.bin
	@ rm -rf Bin/*.exe
	