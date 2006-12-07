From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Dec 2006 23:13:17 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200612072313.kB7NDH7s012257@agluck-lia64.sc.intel.com>
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

Biggest part of this is the kexec/kdump changes (which include a teeny generic
change to add an icache flush option to kernel/kexec.c).

Thanks!

-Tony

 arch/ia64/Kconfig                       |   23 ++
 arch/ia64/hp/common/sba_iommu.c         |   10 
 arch/ia64/hp/sim/simserial.c            |    3 
 arch/ia64/kernel/Makefile               |    1 
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |   11 -
 arch/ia64/kernel/crash.c                |  245 +++++++++++++++++++++++
 arch/ia64/kernel/efi.c                  |   71 ++++++
 arch/ia64/kernel/entry.S                |    2 
 arch/ia64/kernel/ia64_ksyms.c           |    1 
 arch/ia64/kernel/iosapic.c              |   21 ++
 arch/ia64/kernel/kprobes.c              |    2 
 arch/ia64/kernel/machine_kexec.c        |  133 ++++++++++++
 arch/ia64/kernel/mca.c                  |    5 
 arch/ia64/kernel/palinfo.c              |   22 +-
 arch/ia64/kernel/perfmon.c              |    3 
 arch/ia64/kernel/perfmon_montecito.h    |   12 -
 arch/ia64/kernel/relocate_kernel.S      |  334 ++++++++++++++++++++++++++++++++
 arch/ia64/kernel/setup.c                |   38 +++
 arch/ia64/kernel/smp.c                  |   28 ++
 arch/ia64/lib/ip_fast_csum.S            |   58 +++++
 arch/ia64/pci/pci.c                     |    3 
 arch/ia64/sn/kernel/irq.c               |   18 +
 arch/ia64/sn/kernel/msi_sn.c            |    4 
 arch/ia64/sn/kernel/setup.c             |    8 
 include/asm-ia64/checksum.h             |    6 
 include/asm-ia64/kexec.h                |   47 ++++
 include/asm-ia64/machvec.h              |    5 
 include/asm-ia64/machvec_sn2.h          |    2 
 include/asm-ia64/meminit.h              |    3 
 include/asm-ia64/page.h                 |   11 -
 include/asm-ia64/pal.h                  |   64 +++++-
 include/asm-ia64/sn/sn_sal.h            |    9 
 include/linux/kexec.h                   |    5 
 kernel/kexec.c                          |    1 
 34 files changed, 1146 insertions(+), 63 deletions(-)

Chen, Kenneth W:
      [IA64] implement csum_ipv6_magic for ia64.
      [IA64] tidy up return value of ip_fast_csum

Christoph Lameter:
      [IA64] resolve name clash by renaming is_available_memory()

John Keller:
      [IA64] SN: Correctly update smp_affinty mask

Matthew Wilcox:
      [IA64] sparse cleanups
      [IA64] Fix DISCONTIGMEM without VIRTUAL_MEM_MAP

Russ Anderson:
      [IA64] Add dp bit to cache and bus check structs
      [IA64] Add se bit to Processor State Parameter structure
      [IA64] Update processor_info features
      [IA64] More Itanium PAL spec updates

Tony Luck:
      [IA64] Need export for csum_ipv6_magic

Venkatesh Pallipadi:
      Add support for type argument in PAL_GET_PSTATE

Yan Burman:
      [IA64] replace kmalloc+memset with kzalloc

Zou Nan hai:
      [IA64] IA64 Kexec/kdump
