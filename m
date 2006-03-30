From: Jack Steiner <steiner@sgi.com>
Date: Thu, 30 Mar 2006 15:16:11 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060330151611.GB3360@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't know if this helps or not.
> 
> I ran Jes's kernel on the simulator. Unfortunately, he sent me a stripped
> kernel so I have no symbol table.
> 
> The kernel blows up right after printing:
> 
> 	...
> 	Virtual mem_map starts at 0xa0007fffd5f2c000
> 	Built 1 zonelists
> 	Kernel command line: root=/dev/hda2 init=/bin/bash console=ttyS0
> 	PID hash table entries: 1024 (order: 10, 32768 bytes)
> 	Console: colour dummy device 80x25
> 
> The failure is an MCA caused by a cache hit on a memory reference to an
> uncached address. The simulator detects this error & stops.
> 
> The code that took the failure was memcopy (or equiv). I recognized the
> code from the prefetchs and ld/st sequence. The data appears to be
> an ACPI table that is being copied into kernel memory. The current
> reference is using uncached addresses but 15M instructions in the past, the
> table was referenced cached.
 
I found the problem that is causing the cache/uncached collision. This is
most likely NOT what is causing the problem you are currently chasing, but
it is a problem never-the-less.

(Background: I noticed that recent IA64 kernels are making references to the
same address using both cached & uncached addresses. The kernel fails to
boot on the simulator because it detects a cache-hit on an uncached
reference. Mixing cached & uncached references is not supported).


acpi_os_map_memory() has changed the order of checking the EFI attributes on
pages being mapped. In 2.6.15, if the EFI map indicates that an address
supports both cached & uncached references, acpi_os_map_memory() would map
it as cached.

The most recent kernel has changed this behavior so that the address will be
referenced as uncached.


OLD:
        acpi_os_map_memory
                if (EFI_MEMORY_WB & efi_mem_attributes(phys)) {
                        *virt = (void __iomem *)phys_to_virt(phys);
                } else {
                        *virt = ioremap(phys, size);
                }

NEW
        acpi_os_map_memory() unconditionally calls ioremap() to do the
        mapping

        ioremap
                if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
                         return __ioremap(offset, size);

                if (efi_mem_attribute_range(offset, size, EFI_MEMORY_WB))
                         return phys_to_virt(offset);


Earlier in the boot, the ACPI tables are unconditionally references as cached:

        char *__acpi_map_table(unsigned long phys_addr, unsigned long size)
        {
                return __va(phys_addr);
        }



I suspect there was a reason for this change. I'll add Bjorn to the cc
list. 

Is this problem unique to SN systems. The BIOS reports that most
memory ranges support both CACHED & UNCACHED references. I _think_
this is correct.


