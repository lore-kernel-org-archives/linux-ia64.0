From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 20 Oct 2004 00:15:20 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200410200015.i9K0FKw29051@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.10

This will update the files shown below.  This is a big re-organization
of the SGI I/O code.

Thanks!

-Tony

 arch/ia64/sn/io/Makefile                        |   13 
 arch/ia64/sn/io/cdl.c                           |   79 
 arch/ia64/sn/io/drivers/Makefile                |   10 
 arch/ia64/sn/io/drivers/ioconfig_bus.c          |  382 
 arch/ia64/sn/io/hwgfs/Makefile                  |   10 
 arch/ia64/sn/io/hwgfs/hcl.c                     |  702 
 arch/ia64/sn/io/hwgfs/hcl_util.c                |  175 
 arch/ia64/sn/io/hwgfs/interface.c               |  325 
 arch/ia64/sn/io/hwgfs/labelcl.c                 |  656 
 arch/ia64/sn/io/hwgfs/ramfs.c                   |  208 
 arch/ia64/sn/io/io.c                            |  739 
 arch/ia64/sn/io/machvec/Makefile                |   10 
 arch/ia64/sn/io/machvec/iomv.c                  |   76 
 arch/ia64/sn/io/machvec/pci.c                   |   52 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c        |  922 
 arch/ia64/sn/io/machvec/pci_dma.c               |  677 
 arch/ia64/sn/io/platform_init/Makefile          |   10 
 arch/ia64/sn/io/platform_init/sgi_io_init.c     |  174 
 arch/ia64/sn/io/sn2/Makefile                    |   14 
 arch/ia64/sn/io/sn2/bte_error.c                 |  217 
 arch/ia64/sn/io/sn2/geo_op.c                    |  311 
 arch/ia64/sn/io/sn2/klconflib.c                 |  572 
 arch/ia64/sn/io/sn2/klgraph.c                   |  577 
 arch/ia64/sn/io/sn2/l1_command.c                |  131 
 arch/ia64/sn/io/sn2/ml_SN_init.c                |  109 
 arch/ia64/sn/io/sn2/ml_SN_intr.c                |  320 
 arch/ia64/sn/io/sn2/ml_iograph.c                |  770 
 arch/ia64/sn/io/sn2/module.c                    |  236 
 arch/ia64/sn/io/sn2/pcibr/Makefile              |   16 
 arch/ia64/sn/io/sn2/pcibr/pcibr_ate.c           |  178 
 arch/ia64/sn/io/sn2/pcibr/pcibr_config.c        |  195 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c           | 2662 --
 arch/ia64/sn/io/sn2/pcibr/pcibr_error.c         | 1873 -
 arch/ia64/sn/io/sn2/pcibr/pcibr_hints.c         |  175 
 arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c          |  700 
 arch/ia64/sn/io/sn2/pcibr/pcibr_reg.c           |  879 
 arch/ia64/sn/io/sn2/pcibr/pcibr_rrb.c           |  887 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c          | 1842 -
 arch/ia64/sn/io/sn2/pciio.c                     | 1004 
 arch/ia64/sn/io/sn2/pic.c                       |  835 
 arch/ia64/sn/io/sn2/shub.c                      |  246 
 arch/ia64/sn/io/sn2/shub_intr.c                 |  259 
 arch/ia64/sn/io/sn2/shuberror.c                 |  822 
 arch/ia64/sn/io/sn2/shubio.c                    |  490 
 arch/ia64/sn/io/sn2/xbow.c                      | 1020 
 arch/ia64/sn/io/sn2/xtalk.c                     |  927 
 arch/ia64/sn/io/snia_if.c                       |  108 
 arch/ia64/sn/io/xswitch.c                       |  168 
 arch/ia64/sn/kernel/probe.c                     |   58 
 include/asm-ia64/sn/cdl.h                       |   42 
 include/asm-ia64/sn/dmamap.h                    |   50 
 include/asm-ia64/sn/driver.h                    |   91 
 include/asm-ia64/sn/hcl.h                       |  107 
 include/asm-ia64/sn/hcl_util.h                  |   21 
 include/asm-ia64/sn/hwgfs.h                     |   36 
 include/asm-ia64/sn/ifconfig_net.h              |   32 
 include/asm-ia64/sn/io.h                        |   65 
 include/asm-ia64/sn/ioc4.h                      |   20 
 include/asm-ia64/sn/ioconfig_bus.h              |   27 
 include/asm-ia64/sn/ioerror.h                   |  193 
 include/asm-ia64/sn/ioerror_handling.h          |  159 
 include/asm-ia64/sn/iograph.h                   |  137 
 include/asm-ia64/sn/klconfig.h                  |  702 
 include/asm-ia64/sn/kldir.h                     |  363 
 include/asm-ia64/sn/ksys/elsc.h                 |   39 
 include/asm-ia64/sn/ksys/l1.h                   |  141 
 include/asm-ia64/sn/labelcl.h                   |   76 
 include/asm-ia64/sn/module.h                    |  194 
 include/asm-ia64/sn/pci/bridge.h                | 1895 -
 include/asm-ia64/sn/pci/pci_bus_cvlink.h        |   70 
 include/asm-ia64/sn/pci/pci_defs.h              |  414 
 include/asm-ia64/sn/pci/pcibr.h                 |  535 
 include/asm-ia64/sn/pci/pcibr_private.h         |  811 
 include/asm-ia64/sn/pci/pciio.h                 |  746 
 include/asm-ia64/sn/pci/pciio_private.h         |  145 
 include/asm-ia64/sn/pci/pic.h                   |  451 
 include/asm-ia64/sn/pio.h                       |   99 
 include/asm-ia64/sn/prio.h                      |   38 
 include/asm-ia64/sn/sgi.h                       |   83 
 include/asm-ia64/sn/slotnum.h                   |   16 
 include/asm-ia64/sn/sn2/addrs.h                 |  169 
 include/asm-ia64/sn/sn2/arch.h                  |   61 
 include/asm-ia64/sn/sn2/geo.h                   |  108 
 include/asm-ia64/sn/sn2/intr.h                  |   31 
 include/asm-ia64/sn/sn2/io.h                    |  239 
 include/asm-ia64/sn/sn2/shub.h                  |   36 
 include/asm-ia64/sn/sn2/shub_md.h               |  275 
 include/asm-ia64/sn/sn2/shub_mmr.h              |31597 ------------------------
 include/asm-ia64/sn/sn2/shub_mmr_t.h            |14829 -----------
 include/asm-ia64/sn/sn2/shubio.h                | 3609 --
 include/asm-ia64/sn/sn2/slotnum.h               |   41 
 include/asm-ia64/sn/sn2/sn_private.h            |  245 
 include/asm-ia64/sn/sn_private.h                |   13 
 include/asm-ia64/sn/vector.h                    |   75 
 include/asm-ia64/sn/xtalk/xbow.h                |  675 
 include/asm-ia64/sn/xtalk/xbow_info.h           |   21 
 include/asm-ia64/sn/xtalk/xswitch.h             |   56 
 include/asm-ia64/sn/xtalk/xtalk.h               |  360 
 include/asm-ia64/sn/xtalk/xtalk_private.h       |   79 
 include/asm-ia64/sn/xtalk/xtalkaddrs.h          |  106 
 include/asm-ia64/sn/xtalk/xwidget.h             |  240 
 arch/ia64/pci/pci.c                             |    2 
 arch/ia64/sn/Makefile                           |    8 
 arch/ia64/sn/include/ioerror.h                  |   81 
 arch/ia64/sn/include/pci/pcibr_provider.h       |  149 
 arch/ia64/sn/include/pci/pcibus_provider_defs.h |   43 
 arch/ia64/sn/include/pci/pcidev.h               |   51 
 arch/ia64/sn/include/pci/pic.h                  |  261 
 arch/ia64/sn/include/pci/tiocp.h                |  256 
 arch/ia64/sn/include/shub.h                     |   39 
 arch/ia64/sn/include/shubio.h                   | 3476 ++
 arch/ia64/sn/include/tio.h                      |   37 
 arch/ia64/sn/include/xtalk/hubdev.h             |   67 
 arch/ia64/sn/include/xtalk/xbow.h               |  291 
 arch/ia64/sn/include/xtalk/xwidgetdev.h         |   70 
 arch/ia64/sn/kernel/Makefile                    |    3 
 arch/ia64/sn/kernel/bte.c                       |  128 
 arch/ia64/sn/kernel/bte_error.c                 |  188 
 arch/ia64/sn/kernel/huberror.c                  |  205 
 arch/ia64/sn/kernel/io_init.c                   |  470 
 arch/ia64/sn/kernel/iomv.c                      |   79 
 arch/ia64/sn/kernel/irq.c                       |  538 
 arch/ia64/sn/kernel/klconflib.c                 |  108 
 arch/ia64/sn/kernel/mca.c                       |   35 
 arch/ia64/sn/kernel/setup.c                     |  346 
 arch/ia64/sn/kernel/sn2/io.c                    |   60 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c         |   70 
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S          |    4 
 arch/ia64/sn/kernel/sn2/sn2_smp.c               |  116 
 arch/ia64/sn/kernel/sn2/sn_hwperf.c             |   92 
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c            |    1 
 arch/ia64/sn/kernel/sn2/timer.c                 |    6 
 arch/ia64/sn/kernel/sn2/timer_interrupt.c       |   15 
 arch/ia64/sn/pci/Makefile                       |   10 
 arch/ia64/sn/pci/pci_dma.c                      |  476 
 arch/ia64/sn/pci/pcibr/Makefile                 |   11 
 arch/ia64/sn/pci/pcibr/pcibr_ate.c              |  188 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c              |  375 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c         |  170 
 arch/ia64/sn/pci/pcibr/pcibr_reg.c              |  282 
 drivers/char/mmtimer.c                          |    1 
 drivers/char/snsc.c                             |   25 
 drivers/ide/pci/sgiioc4.c                       |   23 
 drivers/scsi/qla1280.c                          |   32 
 drivers/serial/sn_console.c                     |  214 
 include/asm-ia64/machvec_sn2.h                  |    2 
 include/asm-ia64/pci.h                          |    2 
 include/asm-ia64/sn/addrs.h                     |  313 
 include/asm-ia64/sn/arch.h                      |   20 
 include/asm-ia64/sn/bte.h                       |    4 
 include/asm-ia64/sn/clksupport.h                |   30 
 include/asm-ia64/sn/fetchop.h                   |    2 
 include/asm-ia64/sn/geo.h                       |  139 
 include/asm-ia64/sn/intr.h                      |   41 
 include/asm-ia64/sn/io.h                        |  265 
 include/asm-ia64/sn/klconfig.h                  |  272 
 include/asm-ia64/sn/l1.h                        |   36 
 include/asm-ia64/sn/leds.h                      |    8 
 include/asm-ia64/sn/module.h                    |  127 
 include/asm-ia64/sn/nodepda.h                   |   61 
 include/asm-ia64/sn/pda.h                       |    5 
 include/asm-ia64/sn/router.h                    |   51 
 include/asm-ia64/sn/rw_mmr.h                    |    2 
 include/asm-ia64/sn/shub_mmr.h                  |31596 +++++++++++++++++++++++
 include/asm-ia64/sn/simulator.h                 |    8 
 include/asm-ia64/sn/sn_cpuid.h                  |    7 
 include/asm-ia64/sn/sn_fru.h                    |    2 
 include/asm-ia64/sn/sn_sal.h                    |   74 
 include/asm-ia64/sn/sndrv.h                     |   14 
 169 files changed, 40920 insertions(+), 85747 deletions(-)

through these ChangeSets:

<pfg@sgi.com> (04/10/19 1.2176)
   [IA64-SGI] Fixes calling arg1 for bte_crb_error_handler()
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<holt@sgi.com> (04/10/19 1.2175)
   [IA64-SGI] Distribute useage of BTE interfaces.
   
   During peak utilization periods, the first interface on a node has
   an inordinately large amount of contention.  This is due to all
   cpus starting their scan for an interface at 0.  This patch distributes
   that based upon the slice the requesting cpu is attached to.
    
   Signed-off-by: Robin Holt
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<holt@sgi.com> (04/10/19 1.2174)
   [IA64-SGI] Correct BTE notification timeouts on SN2.
   
   The SN2 Block Transfer Engine occassionally fails to send a notification
   that it has completed a transfer to the kernel.  This patch adds a
   timeout mechanism which will detect the failure, reset the interface,
   and then retry the transfer.
    
   Signed-off-by: Robin Holt
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/19 1.2173)
   [IA64-SGI] BUG_ON test was backwards
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<holt@sgi.com> (04/10/19 1.2172)
   [IA64-SGI] Double spin_unlock in bte.c
   
   If all bte interfaces are in use, the current code will leave the
   bte pointer set when exiting from the loop trying to locate an
   interface to use.  This results in two processes using the same
   interface and both trying to free the same one.  With a
   premptible kernel, this results in the preempt count getting
   off.
    
   Signed-off-by: Robin Holt <holt@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2171)
   [IA64-SGI] make pci_root_ops non static
   
   add extern for pci_root_ops
   delete our version of the pci_root_ops code
   make pci_root_ops non static
   
   Ack-by: Matthew Wilcox
   Ack-by: Jesse Barnes
   Ack-by: Grant Grundler
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2170)
   [IA64-SGI] Fix a possible memory leak.
   
   Fix a possible memory leak.  Change the name of the 'new_sn_irq_info'
   variable to 'tmp_sn_irq_info' since we're not really allocating a new
   kernel sn_irq_info, we just getting new target information from the
   PROM and replacing it in the kernel's sn_irq_info for the given irq
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2169)
   [IA64-SGI] Redundant BUG check
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2168)
   [IA64-SGI] Fix issue with gemini TIO systems
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2167)
   [IA64] qla1280.c Mod for Altix I/O add code.
   
   Changes inside CONFIG_IA64_GENERIC CONFIG_IA64_SGI_SN2
   Need to include sn/io.h for generic builds (sn_+pci_set_vchan def)
   Remove rrb alloc - now done in PROM
   Remove endian setting - now done in PROM
   Change arg 2 for sn_pci_set_vchan()
   
   Acked-by: Jes Sorenson
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2166)
   [IA64-SGI] Add in Altix I/O code
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/11 1.2165)
   [IA64-SGI] Remove Altix I/O code (ready for re-org).
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

