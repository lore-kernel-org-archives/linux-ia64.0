From: Keith Owens <kaos@sgi.com>
Date: Mon, 16 Dec 2002 01:24:03 +0000
Subject: [Linux-ia64] gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805566@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Using binutils-2.11.90.0.8-12 (old I know, but it is the only version
supported on Redhat ia64), the rlen field in the body part of the
unwind descriptors is incorrect, it is short of the real body size.
Any function calls after the short body rlen are unwound incorrectly.
The unwind code is correct but the invalid rlen makes unwind think that
the calling function has reached its epilogue.  That results in an
attempt to unwind using the 'return address' in b0 which is no longer
valid.

Commands to demonstrate the problem.  Kernel is a native compile of
2.4.19-ia64-020821 plus SGI changes, the SGI changes have not touched
unwind or binutils.  I have also verified the bug on a standard
2.4.19-ia64-020821 kernel, using both native and 386->ia64 cross
compilers.

For system verification reasons, upgrading to binutils 2.13 is not an
option.  Also a check of the binutils changelog, mailing list archives
and bugzilla found no mention of this bug, AFAICT 2.13 has no fix.

# cd arch/ia64/kernel
# gcc -D__KERNEL__ -I/usr/src/redhat/lbs/linux/include  -Wall \
        -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing \
        -fno-common -fomit-frame-pointer -pipe -ffixed-r13 \
        -mfixed-range=F10-f15,f32-f127 -falign-functions2 \
        -DSGI_SN_EXECUTABLE_STACKS -mconstant-gp -nostdinc \
	-I /usr/lib/gcc-lib/ia64-redhat-linux/2.96/include \
        -DKBUILD_BASENAME=3Dtraps -c -o traps.o traps.c -v

Reading specs from /usr/lib/gcc-lib/ia64-redhat-linux/2.96/specs
gcc version 2.96 20000731 (Red Hat Linux 7.2 2.96-108.7.2)
 /usr/lib/gcc-lib/ia64-redhat-linux/2.96/cpp0 -lang-c -nostdinc -v \
 	-I/usr/src/redhat/lbs/linux/include \
	-I /usr/lib/gcc-lib/ia64-redhat-linux/2.96/include \
	-D__GNUC__=3D2 -D__GNUC_MINOR__=96 -D__GNUC_PATCHLEVEL__=3D0 \
	-D__ia64 -D__ia64__ -D__linux -D__linux__ -D_LONGLONG -Dlinux \
	-Dunix -D__LP64__ -D__ELF__ -D__ia64 -D__ia64__ -D__linux \
	-D__linux__ -D_LONGLONG -D__linux__ -D__unix__ -D__LP64__ \
	-D__ELF__ -D__linux -D__unix -Asystem(linux) -Acpu(ia64) \
	-Amachine(ia64) -D__OPTIMIZE__ -Wall -Wstrict-prototypes \
	-Wno-trigraphs -D__LONG_MAX__=9223372036854775807L -D__KERNEL__ \
	-DSGI_SN_EXECUTABLE_STACKS -DKBUILD_BASENAME=3Dtraps traps.c | \
 /usr/lib/gcc-lib/ia64-redhat-linux/2.96/cc1 -mb-step -quiet -dumpbase \
 	traps.c -mfixed-range=F10-f15,f32-f127 -mconstant-gp -O2 -Wall \
	-Wstrict-prototypes -Wno-trigraphs -version -fno-strict-aliasing \
	-fno-common -fomit-frame-pointer -ffixed-r13 \
	-falign-functions2 -o - | \
 as -x -mconstant-gp -o traps.o -
GNU CPP version 2.96 20000731 (Red Hat Linux 7.2 2.96-108.7.2) (cpplib) (IA=
-64)
#include "..." search starts here:
#include <...> search starts here:
 /usr/src/redhat/lbs/linux/include
 /usr/lib/gcc-lib/ia64-redhat-linux/2.96/include
End of search list.
GNU C version 2.96 20000731 (Red Hat Linux 7.2 2.96-108.7.2) (ia64-redhat-l=
inux) compiled by GNU C version 2.96 20000731 (Red Hat Linux 7.2 2.96-108.7=
.2).
bash-2.05# as -v
GNU assembler version 2.11.90.0.8 (ia64-redhat-linux) using BFD version 2.1=
1.90.0.8

Using the 2.13 readelf to print the unwind data.  readelf is correct,
the encoded rlen in unwind info really is 475.

# /usr/src/redhat/BUILD/binutils-2.13.90.0.2/binutils/readelf -u traps.o

Unwind section '.IA_64.unwind' at offset 0x2600 contains 8 entries:
...
<ia64_fault>: [0x1300-0x1dd0), info at +0xc8
  v1, flags=3D0x0 ( ), len=16 bytes
    R2:prologue_gr(mask=3D[rp,ar.pfs],grsave=3Dr37,rlen=3D8)
	P7:pfs_when(t=3D0)
	P7:mem_stack_f(t=3D2,size%6)
	P7:rp_when(t=3D7)
    R3:body(rlenG5)
	B2:epilogue(t=3D2,ecount=3D0)
    R1:prologue(rlen=3D0)

ia64_fault is 2768 bytes long, 519 slots.  The total of the prologue
and body rlen is only 483 slots.  Any calls past slot 483 are not
unwound correctly.  Unfortunately that includes the call to
die_if_kernel().

# /usr/src/redhat/BUILD/binutils-2.13.90.0.2/binutils/objdump -Sr traps.o
...
0000000000001300 <ia64_fault>:
    1300:	0c 30 31 0e 80 05	[MFI]	    alloc r38=3Dar.pfs,12,7,0
    1306:	00 00 00 02 00 80		    nop.f 0x0
    130c:	01 60 f8 8c			    adds r12=3D-256,r12
    1310:	04 00 00 00 01 00	[MLX]	    nop.m 0x0
    1316:	00 08 00 00 00 c0		    movl r14=3D0x80000000f
    131c:	f1 00 00 60
    1320:	02 00 00 00 01 00	[MII]	    nop.m 0x0
    1326:	50 02 00 62 00 c0		    mov r37=B0;;
=3D=3D 8 slots, end of prologue, correct
    132c:	e1 08 31 80			    and r14=3Dr14,r33
    1330:	05 00 00 00 01 00	[MLX]	    nop.m 0x0
    1336:	00 08 00 00 00 e0		    movl r15=3D0x800000004;;
    133c:	41 00 00 60
.......
			1cd2: PCREL21B	printk
    1cd6:	00 00 00 02 00 00		    nop.f 0x0
    1cdc:	08 00 00 50			    br.call.sptk.many b0=1Cd0 <ia64_fault+0x9d0>;;
    1ce0:	01 70 20 48 00 21	[MII]	    adds r14=3D8,r36
			1ce1: LTOFF22	.LC40
    1ce6:	70 02 04 00 48 20		    addl r39=3D0,r1
    1cec:	05 10 01 84			    mov r41=3Dr34;;
    1cf0:	08 40 01 1c 18 10	[MMI]	    ld8 r40=3D[r14]
    1cf6:	70 02 9c 30 20 40		    ld8 r39=3D[r39]
    1cfc:	05 08 01 84			    mov r42=3Dr33
    1d00:	1d 58 01 46 00 21	[MFB]	    mov r43=3Dr35
			1d02: PCREL21B	printk
    1d06:	00 00 00 02 00 00		    nop.f 0x0
    1d0c:	08 00 00 50			    br.call.sptk.many b0=1D00 <ia64_fault+0xa00>;;
=3D=3D unwind says this (slot 483) is end of body, wrong!
    1d10:	11 38 2d 00 00 24	[MIB]	    mov r39=11=09
			1d12: PCREL21B	force_sig
    1d16:	80 02 34 00 42 00		    mov r40=3Dr13
    1d1c:	08 00 00 50			    br.call.sptk.many b0=1D10 <ia64_fault+0xa10>;;
    1d20:	1c 00 00 00 01 00	[MFB]	    nop.m 0x0
    1d26:	00 00 00 02 00 00		    nop.f 0x0
    1d2c:	90 00 00 40			    br.few 1db0 <ia64_fault+0xab0>
    1d30:	01 10 41 18 01 21	[MII]	    adds r34=144,r12
			1d31: LTOFF22	.LC41
    1d36:	80 02 04 00 48 20		    addl r40=3D0,r1
    1d3c:	05 0a bd 52			    shr.u r41=3Dr33,16;;
    1d40:	19 38 01 44 00 21	[MMB]	    mov r39=3Dr34
			1d42: PCREL21B	sprintf
    1d46:	80 02 a0 30 20 00		    ld8 r40=3D[r40]
    1d4c:	08 00 00 50			    br.call.sptk.many b0=1D40 <ia64_fault+0xa40>;;
    1d50:	1c 00 00 00 01 00	[MFB]	    nop.m 0x0
    1d56:	00 00 00 02 00 00		    nop.f 0x0
    1d5c:	30 00 00 40			    br.few 1d80 <ia64_fault+0xa80>
    1d60:	01 10 41 18 01 21	[MII]	    adds r34=144,r12
			1d61: LTOFF22	.LC42
    1d66:	80 02 04 00 48 20		    addl r40=3D0,r1
    1d6c:	05 00 01 84			    mov r41=3Dr32;;
    1d70:	19 38 01 44 00 21	[MMB]	    mov r39=3Dr34
			1d72: PCREL21B	sprintf
    1d76:	80 02 a0 30 20 00		    ld8 r40=3D[r40]
    1d7c:	08 00 00 50			    br.call.sptk.many b0=1D70 <ia64_fault+0xa70>;;
    1d80:	00 38 01 44 00 21	[MII]	    mov r39=3Dr34
    1d86:	80 02 90 00 42 20		    mov r40=3Dr36
    1d8c:	05 08 01 84			    mov r41=3Dr33
    1d90:	1d 00 00 00 01 00	[MFB]	    nop.m 0x0
=3D=3D this call to die_if_kernel() is treated as post epilogue and unwind =
gives up
			1d92: PCREL21B	die_if_kernel
    1d96:	00 00 00 02 00 00		    nop.f 0x0
    1d9c:	08 00 00 50			    br.call.sptk.many b0=1D90 <ia64_fault+0xa90>;;
    1da0:	11 38 11 00 00 24	[MIB]	    mov r39=3D4
			1da2: PCREL21B	force_sig
    1da6:	80 02 34 00 42 00		    mov r40=3Dr13
    1dac:	08 00 00 50			    br.call.sptk.many b0=1Da0 <ia64_fault+0xaa0>;;
    1db0:	00 00 00 00 01 00	[MII]	    nop.m 0x0
    1db6:	00 30 01 55 00 00		    mov.i ar.pfs=3Dr38
    1dbc:	50 0a 00 07			    mov b0=3Dr37
    1dc0:	1d 60 00 18 02 21	[MFB]	    adds r12%6,r12
    1dc6:	00 00 00 02 00 80		    nop.f 0x0
    1dcc:	08 00 84 00			    br.ret.sptk.many b0;;
    1dd0:	0c 00 00 00 01 00	[MFI]	    nop.m 0x0
    1dd6:	00 00 00 02 00 00		    nop.f 0x0
    1ddc:	00 00 04 00			    nop.i 0x0


