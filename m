From: Ville Herva <vherva@niksula.hut.fi>
Date: Sat, 05 Jan 2002 10:41:14 +0000
Subject: Re: [Linux-ia64] 2.4.16 + ia64-011128: Unable to execute a "rwx" program
Message-Id: <marc-linux-ia64-105590698805749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 04, 2002 at 09:06:51PM -0800, you [Jim Wilson] claimed:
> 
> This usually means that the program specifies an interpreter, and the
> interpreter can not be found.
> 
> For a shell script, the interpreter is in the first line.  For instance,
> if I create a shell script called prog, and put in it two lines
> 	#!/bin/foo
> 	exit 0
> and then run it, I get the error "bash: ./prog: no such file or directory".
> The missing file is "/bin/foo" not "prog".

Surely. I just hadn't seen that happen with a compiled c file...
 
> For an ELF executable, the interpreter is stored in the PT_INTERP field.
> "readelf -l prog" will print out the value of the PT_INTERP field along
> with a bunch of other stuff.
> 
> On my system, readelf -l /usr/bin/zip prints out
>   INTERP         0x0000f4 0x080480f4 0x080480f4 0x00013 0x00013 R   0x1
>       [Requesting program interpreter: /lib/ld-linux.so.2]

./fob2          
zsh: no such file or directory: ./fob2
readelf -l ./fob2  
                                                                    
Elf file type is EXEC (Executable file)
Entry point 0x40000000000071a0
There are 7 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x4000000000000040 0x4000000000000040
                 0x0000000000000188 0x0000000000000188  R E    8
  INTERP         0x00000000000001c8 0x40000000000001c8 0x40000000000001c8
                 0x0000000000000011 0x0000000000000011  R      1
      [Requesting program interpreter: /usr/lib/ld.so.1]
  LOAD           0x0000000000000000 0x4000000000000000 0x4000000000000000
                 0x00000000000dee10 0x00000000000dee10  R E    10000
  LOAD           0x00000000000dee10 0x600000000000ee10 0x600000000000ee10
                 0x000000000000a120 0x000000000000c6a0  RW     10000
  DYNAMIC        0x00000000000e8680 0x6000000000018680 0x6000000000018680
                 0x0000000000000220 0x0000000000000220  RW     8
  NOTE           0x00000000000001dc 0x40000000000001dc 0x40000000000001dc
                 0x0000000000000020 0x0000000000000020  R      4
  IA_64_UNWIND   0x00000000000db738 0x40000000000db738 0x40000000000db738
                 0x00000000000036d8 0x00000000000036d8  R      8

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .interp 
   02     .interp .note.ABI-tag .hash .dynsym .dynstr .gnu.version
.gnu.version_d .gnu.version_r .rela.data .rela.got .rela.sdata
.rela.IA_64.pltoff .init .plt .text .fini .rodata .rdata __libc_atexit
__libc_subinit __libc_subfreeres .opd .IA_64.unwind_info .IA_64.unwind 
   03     .data .ctors .dtors .got .dynamic .sdata .srdata .IA_64.pltoff
.sbss .bss 
   04     .dynamic 
   05     .note.ABI-tag 
   06     .IA_64.unwind 

ls -l /usr/lib/ld.so.1
ls: /usr/lib/ld.so.1: No such file or directory

WORKING program: 
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Elf file type is EXEC (Executable file)
Entry point 0x4000000000003bc0
There are 7 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x4000000000000040 0x4000000000000040
                 0x0000000000000188 0x0000000000000188  R E    8
  INTERP         0x00000000000001c8 0x40000000000001c8 0x40000000000001c8
                 0x0000000000000018 0x0000000000000018  R      1
      [Requesting program interpreter: /lib/ld-linux-ia64.so.2]
  LOAD           0x0000000000000000 0x4000000000000000 0x4000000000000000
                 0x000000000001b970 0x000000000001b970  R E    10000
  LOAD           0x000000000001b970 0x600000000000b970 0x600000000000b970
                 0x0000000000000af0 0x0000000000000e30  RW     10000
  DYNAMIC        0x000000000001c018 0x600000000000c018 0x600000000000c018
                 0x0000000000000230 0x0000000000000230  RW     8
  NOTE           0x00000000000001e0 0x40000000000001e0 0x40000000000001e0
                 0x0000000000000020 0x0000000000000020  R      4
  IA_64_UNWIND   0x000000000001b1d8 0x400000000001b1d8 0x400000000001b1d8
                 0x0000000000000798 0x0000000000000798  R      8

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .interp 
   02     .interp .note.ABI-tag .hash .dynsym .dynstr .gnu.version
.gnu.version_r .rela.data .rela.IA_64.unwind_info .rela.got .rela.sdata
.rela.IA_64.pltoff .init .plt .text .fini .rdata .opd .IA_64.unwind_info
.IA_64.unwind 
   03     .data .ctors .dtors .got .dynamic .sdata .srdata .IA_64.pltoff
.sbss .bss 
   04     .dynamic 
   05     .note.ABI-tag 
   06     .IA_64.unwind 

ls -l /lib/ld-linux-ia64.so.2
lrwxrwxrwx    1 root     root           11 Dec 28 09:49 /lib/ld-linux-ia64.so.2 -> ld-2.2.4.so

 
> >This is a c++ program I compiled with the Intel compiler.
> 
> My guess is that you have an old OS with a new executable, or an old
> executable with a new OS, in which case the executable is looking
> for different version of ld.so than the one that comes with the OS.
> 
> Another possibility is that you are missing one of the libraries that comes
> with the Intel compiler.  Or perhaps, you need an environment variable set
> before it will work correctly.

Yes.

Gwenole Beauchesne of Mandrake already pointed out to me that ecc hides a
-static switch in ecc.cfg. Unless I take it away, linking dynamic programs
with ecc works, but results in executables that give "no such file or
directory". If I remove the static switch, it works.

What I didn't realize is that the "no such file or directory" comes from
the unability to load suitable ld.so.

(The test program above is just a few line c program that links against few
dynamic X11 libraries.)


thanks for your time,

-- v --

v@iki.fi

