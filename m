From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 04 Aug 2004 22:05:43 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01CB238A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-base-2.6

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                           |    8 
 arch/ia64/configs/generic_defconfig         |  657
+++++++++++++++-------------
 arch/ia64/hp/common/sba_iommu.c             |   10 
 arch/ia64/kernel/acpi.c                     |   12 
 arch/ia64/kernel/cyclone.c                  |    3 
 arch/ia64/kernel/mca.c                      |   74 +--
 arch/ia64/kernel/setup.c                    |    7 
 arch/ia64/kernel/smpboot.c                  |    2 
 arch/ia64/sn/io/platform_init/sgi_io_init.c |    6 
 arch/ia64/sn/kernel/irq.c                   |    2 
 include/asm-ia64/cyclone.h                  |    4 
 include/asm-ia64/machvec.h                  |    4 
 include/asm-ia64/numnodes.h                 |    3 
 13 files changed, 445 insertions(+), 347 deletions(-)

through these ChangeSets:

<jbarnes@sgi.com> (04/08/04 1.1840)
   generic_defconfig update.  I just ran 'make oldconfig' against the
existing
   one and turned on a few new options (some of which Altix needs).
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<[alex.williamson@hp.com> (04/08/04 1.1839)
   Using CONFIG_IA64_HP_ZX1 on an sx1000 system setup w/ multiple NUMA
   nodes (configured for cell local memory) currently crashes because
   MAX_NUMNODES defaults to 1.  The patch below sets up things to make
this
   work.
   
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/08/04 1.1838)
   Provide comand line keyword "nomca" to turn off mca processing in
kernel.
   Initial patch by Jesse Barnes, fixed by Ken Chen, rescued from
   obscurity by Sourav Sen.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<seto.hidetoshi@jp.fujitsu.com> (04/08/04 1.1837)
   Set up CMC/CPE polling *before* enabling CMCI/CPEI interrupts to
avoid
   situation where a flood of errors prevents boot.
   
   Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/03 1.1836)
   sgi_io_init.c:
     Mark per_hub_init as __init and remove an unnecessary extern
declaration of it
     in sgi_io_init.c.  This has the effect of killing a warning in the
compile of
     that file.
   
     Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjorn.helgaas@hp.com> (04/08/03 1.1835)
   sba_iommu.c:
     REO/Grande defect AR2305 can cause TLB fetch timeouts if entries
     are purged while in use.  Round up IOVA allocations to power-of-two
     boundaries to prevent this.  This is originally due to Alex
Williamson.
   
     Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjorn.helgaas@hp.com> (04/08/03 1.1834)
   cyclone.h, cyclone.c, acpi.c, Kconfig:
     Make cyclone_setup() take no args, rather than an ignored "char *"
     and return void.  Fix typos and whitespace.
   
     Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjorn.helgaas@hp.com> (04/08/03 1.1833)
   machvec.h:
   irq.c:
     Fix IRQ type in platform irq_to_vector functions.  Should be
     "unsigned int", but some places were "u8".
   
     Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

