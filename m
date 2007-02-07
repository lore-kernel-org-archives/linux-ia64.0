From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Feb 2007 00:55:33 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200702070055.l170tXCQ014089@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

[include/asm-x86_64/swiotlb.h and arch/x86_64/kernel/pci-swiotlb.c
 were touched while cleaning up some ia64 stuff in the shared lib/swiotlb.c
 Andi Kleen is OK with the changes].

Thanks!

-Tony

 arch/ia64/Kconfig                |    9 -
 arch/ia64/hp/common/hwsw_iommu.c |    4 
 arch/ia64/kernel/crash.c         |   16 +-
 arch/ia64/kernel/crash_dump.c    |    3 
 arch/ia64/kernel/efi.c           |    2 
 arch/ia64/kernel/entry.S         |    2 
 arch/ia64/kernel/iosapic.c       |    5 
 arch/ia64/kernel/machine_kexec.c |   19 --
 arch/ia64/kernel/process.c       |   16 ++
 arch/ia64/kernel/ptrace.c        |   14 -
 arch/ia64/kernel/setup.c         |   31 +--
 arch/ia64/kernel/vmlinux.lds.S   |    1 
 arch/ia64/mm/contig.c            |   76 ++++++---
 arch/ia64/mm/discontig.c         |   46 +----
 arch/ia64/mm/init.c              |   38 ++++
 arch/ia64/sn/kernel/huberror.c   |   16 +-
 arch/x86_64/kernel/pci-swiotlb.c |    2 
 include/asm-ia64/dma.h           |    2 
 include/asm-ia64/esi.h           |    1 
 include/asm-ia64/meminit.h       |    3 
 include/asm-ia64/pgalloc.h       |    3 
 include/asm-ia64/swiotlb.h       |    9 +
 include/asm-ia64/thread_info.h   |    4 
 include/asm-ia64/unistd.h        |    4 
 include/asm-x86_64/swiotlb.h     |    8 -
 lib/swiotlb.c                    |  306 ++++++++++++++++++++++++++-------------
 26 files changed, 417 insertions(+), 223 deletions(-)

Alex Williamson:
      [IA64] Clear IRQ affinity when unregistered
      [IA64] remove bogus prototype ia64_esi_init()

Aron Griffis:
      [IA64] use snprintf() on features field of /proc/cpuinfo

Bernhard Walle:
      [IA64] Fix NULL-pointer dereference in ia64_machine_kexec()

bibo,mao:
      [IA64] enable singlestep on system call
      [IA64] find thread for user rbs address

Bob Picco:
      [IA64] register memory ranges in a consistent manner
      [IA64] clean up sparsemem memory_present call

Fenghua Yu:
      [IA64] Hook up getcpu system call for IA64

George Beshers:
      [IA64] show_mem() for IA64 sparsemem NUMA

Horms:
      [IA64] Zero size /proc/vmcore on ia64
      [IA64] kexec: typo in the saved_max_pfn description in contig.c
      [IA64] kexec: Minor enhancement to includes in crash.c
      [IA64] kexec: Remove inline declaration of efi_get_pal_addr()
      [IA64] add newline to PAL-code warning message
      [IA64] kexec: Move machine_shutdown from machine_kexec.c to process.c

Jan Beulich:
      [IA64] Enable SWIOTLB only when needed
      [IA64] missing exports hwsw_sync_...
      [IA64] swiotlb bug fixes
      [IA64] make swiotlb use bus_to_virt/virt_to_bus
      [IA64] swiotlb cleanup
      [IA64] swiotlb abstraction (e.g. for Xen)

Kirill Korotaev:
      [IA64] alignment bug in ldscript
      [IA64] virt_to_page() can be called with NULL arg

Len Brown:
      [IA64] fix ACPI Kconfig issues

Magnus Damm:
      [IA64] kexec: Fix CONFIG_SMP=n compilation

Russ Anderson:
      [IA64-SGI] Check for TIO errors on shub2 Altix
