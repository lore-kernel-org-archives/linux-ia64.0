From: Manfred Spraul <manfred@colorfullife.com>
Date: Sat, 21 Jun 2003 08:29:13 +0000
Subject: Re: Unix code in Linux
Message-Id: <marc-linux-ia64-105618417318726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

atealloc is even worse than I noticed immediately:

* it allocates a semaphore, just in case. Never used.
* it allocates a spinlock and stores the pointer to the spinlock
  in .m_size of the 2nd map entry.
* then defines and one-line wrapper functions to obfuscate
  what's going on:
	pcibr_ate_alloc is a wrapper around rmalloc.
	rmalloc is a #define to atealloc
	atealloc is the map allocator.
* it seems the author never heared of include files - the 
  function prototypes are scattered around in the .c files,
  instead of including <asm/sn/ate_utils.h>

The actual users are in arch/ia64/sn/io/sn2/

There are 2 users:
*********
win_map: It seems to be used for locating io port and memory ranges for pci device initialization.

* creation: in pciio.c:
  - new maps are allocated with pciio_device_win_map_new().
    They are initially empty.
  - The maps are filled with pciio_device_win_populated().
  - they are destroyed with pciio_device_win_map_free().
* use:
  - allocation with pciio_device_win_alloc().
  - free with pciio_device_win_free().

Users are in pcibr/pcibr_{slot,dvr}.c: pcibr_bus_addr_alloc and pcibr_bus_addr_free.

*********
bs_ext_ate_map and bs_int_ate_map: management of address translation entries (ATE).

* creation: created inside pcibr_attach2, destroyed in pcrbr_detach.
	pcibr/pcibr_dvr.c
* use: in pcibr/pcibr_ate.c
	pcibr_ate_alloc, pcibr_ate_free.

The real user is pcibr_dmamap_alloc.
*********

What about deleting ate_utils.c and adding a rmalloc implementation (textbook or bsd) to linux/lib?
Any volunteers?
--
	Manfred
P.S.: I'd propose that the GPL rule that a change must be tagged with the name of the person who changes (or adds) a file is enforced - atealloc.c is only tagged with "SGI", thus I don't know who should be shot for writing that.


