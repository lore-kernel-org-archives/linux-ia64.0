From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 22 Jun 2002 09:25:23 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest patch is available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4 in file:

	linux-2.4.18-ia64-020622.diff.gz

This kernel should work well both on Itanium 1 and Itanium 2,
including hp zx1-based machines.  64KB page size should also work well
as does the virtual mem_map, which is needed for zx1-based machines
with >1GB of memory.  This patch also fixes the
munmap-near-end-of-mappable-space bug.

IMPORTANT: To avoid memory attribute aliasing issues and the risk of
triggering prefetches on memory holes, the kernel now ignores all
memory inside granules ("large kernel pages") that contain holes or
something other than normal memory (e.g., memory-mapped I/O regions).
On today's systems, this means that the kernel tends to throw away
~64MB of memory (or about 6% on a 1GB machine).  If you want to
minimize the amount of memory being thrown away, you can choose a
granule size of 16MB instead (this will increase alternate TLB miss
handling overhead, however).

Enjoy,

	--david

PS: I'll be at the kernel workshop/OLS next week, so don't expect quick
    responses.

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
	- Stop inheriting certain PSR bits (e.g., PSR.DB) across clone2() and
	  fork() (Stephane Eranian & yours truly)
	- Don't clear siginfo.si_addr for SIGTRAP caused by debug breakpoint
	- McKinley-tuned copy_user(), merged with McKinley-tuned memcpy()
	  (Ken Chen)
	- Fix linker script so GOT gets properly aligned (not just __gp).
	  This avoids spurios "gp out-of-range" errors.
	- Clean up fusion driver (based on suggestion by Keith Owens &
	  Grant Grundler)
	- Add bcm5700 gig ethernet driver
	- Add preliminary driver for ForteMedia FM801 sound chip (Martin
	  Petersen).
	- Fix bootmem so machine boots much faster if there are large holes in
	  the physical memory map.
	- Fix vm-corruption due to munmap() near end of mappable address space
	- Finish virtual mem_map integration.

