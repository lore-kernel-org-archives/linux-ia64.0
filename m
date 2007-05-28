From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 28 May 2007 01:03:14 +0000
Subject: Re: [patch 4/5] ia64: fail mmaps that span areas with incompatible attributes
Message-Id: <87lkf9g3ot.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211622.05198.bjorn.helgaas@hp.com>
In-Reply-To: <200703211622.05198.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Bjorn> Example memory map (from HP sx1000 with VGA enabled): 0x00000 -
Bjorn> 0x9FFFF supports only WB (cacheable) access 0xA0000 - 0xBFFFF
Bjorn> supports only UC (uncacheable) access 0xC0000 - 0xFFFFF
Bjorn> supports only WB (cacheable) access

Bjorn> Some versions of X map the entire 0x00000-0xFFFFF area at once.
Bjorn> With the example above, this mmap must fail because there's no
Bjorn> memory attribute that's safe for the entire area.

This patch breaks X on a ZX2000.

lspci -v gives:
00:00.0 VGA compatible controller: ATI Technologies Inc Radeon RV100 QY [Radeon 
7000/VE] (prog-if 00 [VGA])
        Subsystem: ATI Technologies Inc Unknown device 010a
        Flags: bus master, stepping, 66MHz, medium devsel, latency 192, IRQ 51
        Memory at 80000000 (32-bit, prefetchable) [size8M]
        I/O ports at 0d00 [size%6]
        Memory at 88020000 (32-bit, non-prefetchable) [sizedK]
        Expansion ROM at 88000000 [disabled] [size8K]
        Capabilities: [58] AGP version 2.0
        Capabilities: [50] Power Management version 2

strace on X gives:
...
open("/sys/class/pci_bus/0000:00/legacy_mem", O_RDWR) = 8
mmap(NULL, 1048576, PROT_READ|PROT_WRITE, MAP_SHARED, 8, 0) = -1 EINVAL (Invalid argument)
close(8)                                = 0
write(2, "mmap failure: Invalid argument\n", 31mmap failure: Invalid argument
) = 31
write(2, "\nFatal server error:\n", 21
Fatal server error:



EFI memory map is:
mem00: type=4, attr=0x8, range=[0x0000000000000000-0x0000000000001000) (0MB)
mem01: type=7, attr=0x8, range=[0x0000000000001000-0x00000000000a0000) (0MB)
mem02: type, attr=0x3, range=[0x00000000000a0000-0x00000000000c0000) (0MB)
mem03: type=5, attr=0x8000000000000001, range=[0x00000000000c0000-0x0000000000100000) (0MB)
...

so the patch prevents the mmap from succeeding.

What does the spec say?  *Should* it be possible to map the entire ISA
legacy space in one fell swoop?  X *works* iff I allow the mapping.



--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
