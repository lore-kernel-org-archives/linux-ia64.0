From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 22 Jun 2002 08:57:59 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch for 2.4.18 is at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:

	linux-2.4.18-ia64-020622.diff.gz

There are some important bug fixes in this patch:

	- munmap near end of per-region mappable address space no
	  longer causes virtual memory corruption
	- the kernel used to inherit all PSR bits across fork/exec,
	  which is a Bad Thing; this has been fixed

A more detailed changelog is below.

The kernel should work well both on Itanium 1 and Itanium 2.  One
important change is that the kernel now ignores all memory that lies
on a granule ("large kernel page") that contains a hole or something
other than normal memory (e.g., memory-mapped I/O registers).  The net
effect of this is that on most of today's machines, about 64MB of
memory get thrown away because of the stupid <64MB legacy memory
region (which contains a hole due to ISA BIOS space).  With 1GB of
memory, 64MB is about 6% which is more than some of you might be
willing to throw away.  If this is an issue, you can select a granule
size of 16MB (CONFIG_IA64_GRANULE_16MB) and then correspondingly less
memory will be thrown away.  Reasonably well-designed (i.e., 100%
legacy-free machines) won't throw away any memory, so in the long
term, this issue should go away.  In the meantime, buy some stock of
DRAM companies... ;-)

Support for the hp zx1-based machines should be pretty much complete
now.  The virtual memory map works well, as does the 64KB page size.
Two formerly missing drivers (bcm5700 gig ethernet and fm801 sound
chip) have been added.

I have tested this kernel on hp zx1, big sur, and hp ski simulator.
As usual, you're mileage will vary.  Especially the new code for
ignoring memory due to holes is a potential source of nervousness.  I
tried to be careful about getting all the corner-cases correct, but be
sure to test this out before letting it lose on someone else...

Enjoy,

        --david

PS: Sorry, still no perfmon_mckinley.h.  Hopefully it won't be long before
    we can release that...

PPS: I'll be at the kernel workshop/OLS next week, so I won't be able to
    do much while on travel.

ChangeLog

	- Install NaT-page at address zero to speed up speculation
	  across NULL pointers (Ken Chen).
	- Update hp zx1 specific code (Bjorn Helgaas, Alex Williamson,
	  Matthew Willcox)
	- ACPI sync up (Matthew Willcox, Bjorn Helgaas)
	- Ignore memory that's on a granule (large kernel page) that contains
	  holes or non-memory regions (e.g., uncached/writecombine regions).
	- Widen I/O SAPIC base irq numbers to 32 bits (KOCHI Takayoshi)
	- Sync with latest perfmon (Stephane Eranian)
	- Stop inheriting certain PSR bits (e.g., PSR.DB) across
	  clone2() and fork() (Stephane Eranian & yours truly)
	- Pass Don't clear siginfo.si_addr for SIGTRAP caused by debug
          breakpoint
	- McKinley-tuned copy_user(), merged with McKinley-tuned memcpy()
	  (Ken Chen)
	- Fix linker script so GOT gets properly aligned (not just
          __gp).  This avoids spurios "gp out-of-range" errors.
	- Clean up fusion driver (based on suggestion by Keith Owens &
          Grant Grundler)
	- Add bcm5700 gig ethernet driver
	- Add preliminary driver for ForteMedia FM801 sound chip
          (Martin Petersen).
	- Fix bootmem so machine boots much faster if there are large
	  holes in the physical memory map.
	- Fix vm-corruption due to munmap() near end of mappable address space
	- Finish virtual mem_map integration.

