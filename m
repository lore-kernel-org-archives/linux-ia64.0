From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 10 Jul 2004 16:54:05 +0000
Subject: Re: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <200407100954.05708.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16623.29412.381259.793452@napali.hpl.hp.com>
In-Reply-To: <16623.29412.381259.793452@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, July 9, 2004 9:39 pm, David Mosberger wrote:
> I think you'll want to try out the patch below.  If my guess is
> correct and the SGI firmware doesn't support switching into virtual
> mode, then this may fix the boot-problem you are seeing on SN2.

I believe we do.  IIRC we can call into our PROM in either physical or virtual 
mode.

> We found this problem after I noticed that the Ski simulator always
> wanted to fsck its filesystem.  That turned out to be because the
> phys_get_time() in efi.c used __pa() to convert the address of a
> stack-variable to a physical address.  Only problem was that the
> stack-variable was on the init-task's stack, so it was in region 5.
> Effectively, this ended up writing the correct time to a bogus memory
> address.  In the simulator, that was harmless apart from not returning
> the correct time, but in a real machine, it would likely lead to a
> machine-check.  We never saw this problem on tiger or zx1-based
> machines because by the time efi_get_time() is called, they have
> switched EFI into virtual mode, which obviates the need to do the
> virtual->physical conversion.
>
> The patch below looks bigger than what's really going on: all it does
> is convert __pa() to ia64_tpa(), with some extra code to allow NULL
> pointers for optional arguments.

That sounds like a real bug, but applying the patch doesn't help with the 
MCA/hang I see on sn2:

Linux version 2.6.7 (jbarnes@tomahawk.engr.sgi.com) (gcc version 3.3.2) #17 
SMP Sat Jul 10 09:48:17 PDT 2004
EFI v1.02 by SGI: SALsystab=0x30047e4ed0 ACPI 2.0=0x30047e56a0
ACPI: RSDP (v002    SGI                                ) @ 0x00000030047e56a0
ACPI: XSDT (v001    SGI  XSDTSN2 0x00010001  0x00000001) @ 0x00000030047e56e0
ACPI: MADT (v001    SGI  APICSN2 0x00010001  0x00000001) @ 0x00000030047e5740
ACPI: SRAT (v001    SGI  SRATSN2 0x00010001  0x00000001) @ 0x00000030047e57a0
ACPI: SLIT (v001    SGI  SLITSN2 0x00010001  0x00000001) @ 0x00000030047e5830
ACPI: FADT (v003    SGI  FACPSN2 0x00030001  0x00000001) @ 0x00000030047e5900
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x00000030047e58c0
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x0000000000000000
ACPI: SRAT revision 0
ACPI: SLIT localities 1x1
Number of logical nodes in system = 1
Number of memory chunks in system = 1
SAL 2.9: SGI SN2 version 3.31
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
POD entered via MCA, using Cac mode
0 000: POD SysCt Cac> 

(POD is the builtin debugger that's entered when a machine check occurs.)

Thanks,
Jesse
