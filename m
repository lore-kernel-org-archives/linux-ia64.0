From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 07:50:16 +0000
Subject: bk pull (initial sync with 2.5.72)
Message-Id: <marc-linux-ia64-105592269615698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 arch/ia64/sn/io/alenlist.c                   |  899 ---
 arch/ia64/sn/io/drivers/hubdev.c             |  100 
 arch/ia64/sn/io/drivers/pciba.c              |  941 ---
 arch/ia64/sn/io/eeprom.c                     | 1454 -----
 arch/ia64/sn/io/efi-rtc.c                    |  185 
 arch/ia64/sn/io/hcl.c                        | 1515 -----
 arch/ia64/sn/io/hcl_util.c                   |  200 
 arch/ia64/sn/io/hubdev.c                     |  132 
 arch/ia64/sn/io/hubspc.c                     |  251 
 arch/ia64/sn/io/hwgdfs/Makefile              |   12 
 arch/ia64/sn/io/hwgdfs/hcl.c                 |  955 ---
 arch/ia64/sn/io/hwgdfs/hcl_util.c            |  200 
 arch/ia64/sn/io/hwgdfs/invent_stub.c         |  146 
 arch/ia64/sn/io/hwgdfs/labelcl.c             |  653 --
 arch/ia64/sn/io/hwgfs/hwgfs.h                |   23 
 arch/ia64/sn/io/ifconfig_net.c               |  298 -
 arch/ia64/sn/io/invent.c                     |  224 
 arch/ia64/sn/io/ioconfig_bus.c               |  402 -
 arch/ia64/sn/io/klconflib.c                  | 1042 ---
 arch/ia64/sn/io/klgraph.c                    |  804 --
 arch/ia64/sn/io/klgraph_hack.c               |  341 -
 arch/ia64/sn/io/l1.c                         | 3056 ----------
 arch/ia64/sn/io/l1_command.c                 | 1378 ----
 arch/ia64/sn/io/labelcl.c                    |  654 --
 arch/ia64/sn/io/ml_SN_init.c                 |  235 
 arch/ia64/sn/io/ml_iograph.c                 | 1570 -----
 arch/ia64/sn/io/module.c                     |  312 -
 arch/ia64/sn/io/pci.c                        |  294 -
 arch/ia64/sn/io/pci_bus_cvlink.c             |  737 --
 arch/ia64/sn/io/pci_dma.c                    |  700 --
 arch/ia64/sn/io/pciba.c                      |  950 ---
 arch/ia64/sn/io/pciio.c                      | 1507 -----
 arch/ia64/sn/io/sgi_io_init.c                |  308 -
 arch/ia64/sn/io/sn1/hub_intr.c               |  307 -
 arch/ia64/sn/io/sn1/hubcounters.c            |  283 
 arch/ia64/sn/io/sn1/huberror.c               |  228 
 arch/ia64/sn/io/sn1/ip37.c                   |   47 
 arch/ia64/sn/io/sn1/mem_refcnt.c             |  220 
 arch/ia64/sn/io/sn1/ml_SN_intr.c             | 1154 ----
 arch/ia64/sn/io/sn1/pcibr.c                  | 7704 ---------------------------
 arch/ia64/sn/io/sn2/pci_bus_cvlink.c         |  719 --
 arch/ia64/sn/io/sn2/pcibr/pcibr_idbg.c       |  147 
 arch/ia64/sn/io/sn2/sgi_io_init.c            |  226 
 arch/ia64/sn/io/stubs.c                      |  140 
 arch/ia64/sn/io/xbow.c                       | 1325 ----
 arch/ia64/sn/io/xtalk.c                      | 1024 ---
 arch/ia64/sn/kernel/iomv.c                   |  115 
 arch/ia64/sn/kernel/llsc4.c                  | 1044 ---
 arch/ia64/sn/kernel/llsc4.h                  |  107 
 arch/ia64/sn/kernel/misctest.c               |  371 -
 arch/ia64/sn/kernel/sn1/Makefile             |   45 
 arch/ia64/sn/kernel/sn1/cache.c              |   81 
 arch/ia64/sn/kernel/sn1/error.c              |  187 
 arch/ia64/sn/kernel/sn1/iomv.c               |   65 
 arch/ia64/sn/kernel/sn1/sn1_smp.c            |  476 -
 arch/ia64/sn/kernel/sn1/synergy.c            |  533 -
 arch/ia64/sn/kernel/sn2/iomv.c               |   71 
 arch/ia64/sn/kernel/sn_asm.S                 |  107 
 arch/ia64/tools/Makefile                     |   51 
 arch/ia64/tools/print_offsets.awk            |   72 
 arch/ia64/tools/print_offsets.c              |  224 
 include/asm-ia64/sn/bte_copy.h               |  385 -
 include/asm-ia64/sn/eeprom.h                 |  384 -
 include/asm-ia64/sn/gda.h                    |  109 
 include/asm-ia64/sn/hack.h                   |   69 
 include/asm-ia64/sn/hires_clock.h            |   52 
 include/asm-ia64/sn/idle.h                   |   57 
 include/asm-ia64/sn/intr_public.h            |   19 
 include/asm-ia64/sn/mca.h                    |  128 
 include/asm-ia64/sn/nic.h                    |  129 
 include/asm-ia64/sn/pci/pciba.h              |  121 
 include/asm-ia64/sn/pio_flush.h              |   65 
 include/asm-ia64/sn/sn1/addrs.h              |  275 
 include/asm-ia64/sn/sn1/arch.h               |   89 
 include/asm-ia64/sn/sn1/bedrock.h            |   74 
 include/asm-ia64/sn/sn1/hubdev.h             |   21 
 include/asm-ia64/sn/sn1/hubio.h              | 5016 -----------------
 include/asm-ia64/sn/sn1/hubio_next.h         |  762 --
 include/asm-ia64/sn/sn1/hublb.h              | 1607 -----
 include/asm-ia64/sn/sn1/hublb_next.h         |  109 
 include/asm-ia64/sn/sn1/hubmd.h              | 2476 --------
 include/asm-ia64/sn/sn1/hubmd_next.h         |  812 --
 include/asm-ia64/sn/sn1/hubni.h              | 1781 ------
 include/asm-ia64/sn/sn1/hubni_next.h         |  174 
 include/asm-ia64/sn/sn1/hubpi.h              | 4263 --------------
 include/asm-ia64/sn/sn1/hubpi_next.h         |  331 -
 include/asm-ia64/sn/sn1/hubspc.h             |   24 
 include/asm-ia64/sn/sn1/hubstat.h            |   56 
 include/asm-ia64/sn/sn1/hubxb.h              | 1288 ----
 include/asm-ia64/sn/sn1/hubxb_next.h         |   32 
 include/asm-ia64/sn/sn1/hwcntrs.h            |   96 
 include/asm-ia64/sn/sn1/intr.h               |  237 
 include/asm-ia64/sn/sn1/intr_public.h        |   53 
 include/asm-ia64/sn/sn1/ip27config.h         |  657 --
 include/asm-ia64/sn/sn1/mem_refcnt.h         |   25 
 include/asm-ia64/sn/sn1/mmzone_sn1.h         |  149 
 include/asm-ia64/sn/sn1/slotnum.h            |   87 
 include/asm-ia64/sn/sn1/sn_private.h         |  292 -
 include/asm-ia64/sn/sn1/synergy.h            |  184 
 include/asm-ia64/sn/sn2/mmzone_sn2.h         |  165 
 include/asm-ia64/sn/sn_pio_sync.h            |   53 
 include/asm-ia64/sn/snconfig.h               |   18 
 timer.c                                      |   85 
 arch/ia64/Kconfig                            |   68 
 arch/ia64/Makefile                           |   49 
 arch/ia64/boot/bootloader.c                  |    7 
 arch/ia64/hp/common/sba_iommu.c              |   18 
 arch/ia64/hp/sim/Kconfig                     |    6 
 arch/ia64/hp/sim/Makefile                    |    3 
 arch/ia64/hp/sim/hpsim_setup.c               |   11 
 arch/ia64/hp/sim/simserial.c                 |    3 
 arch/ia64/ia32/binfmt_elf32.c                |    3 
 arch/ia64/ia32/ia32_entry.S                  |   16 
 arch/ia64/ia32/ia32_ioctl.c                  |  205 
 arch/ia64/ia32/ia32_ldt.c                    |    3 
 arch/ia64/ia32/ia32_signal.c                 |   37 
 arch/ia64/ia32/ia32_support.c                |   30 
 arch/ia64/ia32/ia32_traps.c                  |    3 
 arch/ia64/ia32/ia32priv.h                    |  477 +
 arch/ia64/ia32/sys_ia32.c                    |   98 
 arch/ia64/kernel/Makefile                    |   72 
 arch/ia64/kernel/acpi-ext.c                  |    1 
 arch/ia64/kernel/acpi.c                      |   25 
 arch/ia64/kernel/asm-offsets.c               |  189 
 arch/ia64/kernel/efi_stub.S                  |    4 
 arch/ia64/kernel/entry.S                     |  858 +--
 arch/ia64/kernel/entry.h                     |    6 
 arch/ia64/kernel/fsys.S                      |  757 +-
 arch/ia64/kernel/gate-data.S                 |    3 
 arch/ia64/kernel/gate.S                      |  151 
 arch/ia64/kernel/gate.lds.S                  |  149 
 arch/ia64/kernel/head.S                      |  149 
 arch/ia64/kernel/ia64_ksyms.c                |   70 
 arch/ia64/kernel/init_task.c                 |    2 
 arch/ia64/kernel/irq.c                       |  119 
 arch/ia64/kernel/ivt.S                       |  817 +-
 arch/ia64/kernel/mca.c                       |   58 
 arch/ia64/kernel/mca_asm.S                   |   18 
 arch/ia64/kernel/minstate.h                  |  491 -
 arch/ia64/kernel/module.c                    |   55 
 arch/ia64/kernel/pal.S                       |   10 
 arch/ia64/kernel/patch.c                     |  312 -
 arch/ia64/kernel/perfmon.c                   | 7425 ++++++++++++++++----------
 arch/ia64/kernel/perfmon_default_smpl.c      |  309 +
 arch/ia64/kernel/perfmon_generic.h           |   25 
 arch/ia64/kernel/perfmon_itanium.h           |   41 
 arch/ia64/kernel/perfmon_mckinley.h          |  109 
 arch/ia64/kernel/process.c                   |  132 
 arch/ia64/kernel/ptrace.c                    |  222 
 arch/ia64/kernel/setup.c                     |  250 
 arch/ia64/kernel/signal.c                    |  180 
 arch/ia64/kernel/smpboot.c                   |    9 
 arch/ia64/kernel/sys_ia64.c                  |    4 
 arch/ia64/kernel/time.c                      |  138 
 arch/ia64/kernel/traps.c                     |   29 
 arch/ia64/kernel/unaligned.c                 |    3 
 arch/ia64/kernel/unwind.c                    |  341 -
 arch/ia64/lib/Makefile                       |   12 
 arch/ia64/lib/idiv64.S                       |   35 
 arch/ia64/lib/memcpy_mck.S                   |    6 
 arch/ia64/lib/xor.S                          |  184 
 arch/ia64/mm/discontig.c                     |    8 
 arch/ia64/mm/fault.c                         |   37 
 arch/ia64/mm/hugetlbpage.c                   |    4 
 arch/ia64/mm/init.c                          |  212 
 arch/ia64/mm/tlb.c                           |   64 
 arch/ia64/scripts/check-gas                  |    7 
 arch/ia64/scripts/check-segrel.S             |    4 
 arch/ia64/scripts/check-segrel.lds           |   11 
 arch/ia64/scripts/toolchain-flags            |   22 
 arch/ia64/sn/Makefile                        |    2 
 arch/ia64/sn/fakeprom/README                 |    2 
 arch/ia64/sn/fakeprom/fpmem.c                |   52 
 arch/ia64/sn/fakeprom/fpmem.h                |   33 
 arch/ia64/sn/fakeprom/fpromasm.S             |   18 
 arch/ia64/sn/fakeprom/fw-emu.c               |   56 
 arch/ia64/sn/fakeprom/klgraph_init.c         |  330 -
 arch/ia64/sn/fakeprom/main.c                 |   18 
 arch/ia64/sn/fakeprom/make_textsym           |    7 
 arch/ia64/sn/io/Makefile                     |   35 
 arch/ia64/sn/io/ate_utils.c                  |    3 
 arch/ia64/sn/io/cdl.c                        |  140 
 arch/ia64/sn/io/drivers/Makefile             |   18 
 arch/ia64/sn/io/drivers/hubdev.c             |  100 
 arch/ia64/sn/io/drivers/ifconfig_net.c       |  300 +
 arch/ia64/sn/io/drivers/ioconfig_bus.c       |  403 +
 arch/ia64/sn/io/drivers/pciba.c              |  941 +++
 arch/ia64/sn/io/hwgdfs/Makefile              |   12 
 arch/ia64/sn/io/hwgdfs/hcl.c                 |  955 +++
 arch/ia64/sn/io/hwgdfs/hcl_util.c            |  200 
 arch/ia64/sn/io/hwgdfs/invent_stub.c         |  146 
 arch/ia64/sn/io/hwgdfs/labelcl.c             |  653 ++
 arch/ia64/sn/io/hwgfs/Makefile               |   13 
 arch/ia64/sn/io/hwgfs/hcl.c                  |  940 +++
 arch/ia64/sn/io/hwgfs/hcl_util.c             |  200 
 arch/ia64/sn/io/hwgfs/hwgfs.h                |   23 
 arch/ia64/sn/io/hwgfs/interface.c            |  353 +
 arch/ia64/sn/io/hwgfs/invent_stub.c          |  148 
 arch/ia64/sn/io/hwgfs/labelcl.c              |  657 ++
 arch/ia64/sn/io/hwgfs/ramfs.c                |  233 
 arch/ia64/sn/io/io.c                         |  198 
 arch/ia64/sn/io/machvec/Makefile             |   12 
 arch/ia64/sn/io/machvec/iomv.c               |   71 
 arch/ia64/sn/io/machvec/pci.c                |  467 +
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c     |  930 +++
 arch/ia64/sn/io/machvec/pci_dma.c            |  705 ++
 arch/ia64/sn/io/platform_init/Makefile       |   12 
 arch/ia64/sn/io/platform_init/irix_io_init.c |   90 
 arch/ia64/sn/io/platform_init/sgi_io_init.c  |  109 
 arch/ia64/sn/io/sgi_if.c                     |   39 
 arch/ia64/sn/io/sgi_io_sim.c                 |   77 
 arch/ia64/sn/io/sn2/Makefile                 |    7 
 arch/ia64/sn/io/sn2/bte_error.c              |  322 -
 arch/ia64/sn/io/sn2/kdba_io.c                |   76 
 arch/ia64/sn/io/sn2/klconflib.c              |  273 
 arch/ia64/sn/io/sn2/klgraph.c                |   74 
 arch/ia64/sn/io/sn2/l1.c                     |   87 
 arch/ia64/sn/io/sn2/l1_command.c             |  104 
 arch/ia64/sn/io/sn2/ml_SN_init.c             |   26 
 arch/ia64/sn/io/sn2/ml_SN_intr.c             |   95 
 arch/ia64/sn/io/sn2/ml_iograph.c             |  443 -
 arch/ia64/sn/io/sn2/module.c                 |    1 
 arch/ia64/sn/io/sn2/pcibr/Makefile           |   16 
 arch/ia64/sn/io/sn2/pcibr/pcibr_ate.c        |   95 
 arch/ia64/sn/io/sn2/pcibr/pcibr_config.c     |  196 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c        | 1319 +---
 arch/ia64/sn/io/sn2/pcibr/pcibr_error.c      |  445 -
 arch/ia64/sn/io/sn2/pcibr/pcibr_hints.c      |   35 
 arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c       |  187 
 arch/ia64/sn/io/sn2/pcibr/pcibr_rrb.c        |  192 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c       |  457 -
 arch/ia64/sn/io/sn2/pciio.c                  |  444 -
 arch/ia64/sn/io/sn2/pic.c                    |   57 
 arch/ia64/sn/io/sn2/shub.c                   |  269 
 arch/ia64/sn/io/sn2/shub_intr.c              |   33 
 arch/ia64/sn/io/sn2/shuberror.c              |  306 -
 arch/ia64/sn/io/sn2/shubio.c                 |   34 
 arch/ia64/sn/io/sn2/xbow.c                   |  389 -
 arch/ia64/sn/io/sn2/xtalk.c                  |  281 
 arch/ia64/sn/io/xswitch.c                    |   71 
 arch/ia64/sn/kernel/Makefile                 |    8 
 arch/ia64/sn/kernel/bte.c                    |  319 -
 arch/ia64/sn/kernel/idle.c                   |   36 
 arch/ia64/sn/kernel/irq.c                    |  326 -
 arch/ia64/sn/kernel/machvec.c                |   31 
 arch/ia64/sn/kernel/mca.c                    |  298 -
 arch/ia64/sn/kernel/probe.c                  |    2 
 arch/ia64/sn/kernel/setup.c                  |  285 
 arch/ia64/sn/kernel/sn2/Makefile             |    5 
 arch/ia64/sn/kernel/sn2/cache.c              |    5 
 arch/ia64/sn/kernel/sn2/io.c                 |    9 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c      |  361 +
 arch/ia64/sn/kernel/sn2/sn2_smp.c            |  331 -
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c         |   52 
 arch/ia64/sn/kernel/sn2/timer.c              |  162 
 arch/ia64/sn/kernel/sn_ksyms.c               |   45 
 arch/ia64/sn/kernel/sv.c                     |    2 
 arch/ia64/tools/print_offsets.c              |   30 
 arch/ia64/vmlinux.lds.S                      |   74 
 include/asm-ia64/a.out.h                     |    5 
 include/asm-ia64/asmmacro.h                  |   40 
 include/asm-ia64/compat.h                    |    7 
 include/asm-ia64/elf.h                       |  149 
 include/asm-ia64/ia32.h                      |  473 -
 include/asm-ia64/io.h                        |   19 
 include/asm-ia64/ioctl32.h                   |    1 
 include/asm-ia64/kregs.h                     |    2 
 include/asm-ia64/machvec.h                   |    2 
 include/asm-ia64/mca.h                       |    2 
 include/asm-ia64/mca_asm.h                   |    2 
 include/asm-ia64/nodedata.h                  |    1 
 include/asm-ia64/page.h                      |    7 
 include/asm-ia64/patch.h                     |   27 
 include/asm-ia64/pci.h                       |   16 
 include/asm-ia64/perfmon.h                   |  271 
 include/asm-ia64/perfmon_default_smpl.h      |   81 
 include/asm-ia64/pgalloc.h                   |   25 
 include/asm-ia64/pgtable.h                   |   50 
 include/asm-ia64/processor.h                 |  126 
 include/asm-ia64/ptrace.h                    |   63 
 include/asm-ia64/ptrace_offsets.h            |   85 
 include/asm-ia64/resource.h                  |    4 
 include/asm-ia64/sal.h                       |   19 
 include/asm-ia64/sigcontext.h                |    2 
 include/asm-ia64/siginfo.h                   |   24 
 include/asm-ia64/sn/addrs.h                  |  100 
 include/asm-ia64/sn/alenlist.h               |    2 
 include/asm-ia64/sn/arc/hinv.h               |    4 
 include/asm-ia64/sn/arc/types.h              |    2 
 include/asm-ia64/sn/arch.h                   |   13 
 include/asm-ia64/sn/ate_utils.h              |    2 
 include/asm-ia64/sn/bte.h                    |  142 
 include/asm-ia64/sn/cdl.h                    |  176 
 include/asm-ia64/sn/clksupport.h             |   26 
 include/asm-ia64/sn/dmamap.h                 |    5 
 include/asm-ia64/sn/driver.h                 |    6 
 include/asm-ia64/sn/fetchop.h                |   42 
 include/asm-ia64/sn/geo.h                    |    8 
 include/asm-ia64/sn/hcl.h                    |   87 
 include/asm-ia64/sn/hcl_util.h               |   14 
 include/asm-ia64/sn/hwgfs.h                  |   39 
 include/asm-ia64/sn/ifconfig_net.h           |    2 
 include/asm-ia64/sn/intr.h                   |   11 
 include/asm-ia64/sn/invent.h                 |   19 
 include/asm-ia64/sn/io.h                     |   19 
 include/asm-ia64/sn/ioc3.h                   |    2 
 include/asm-ia64/sn/ioc4.h                   |  801 ++
 include/asm-ia64/sn/ioerror.h                |    4 
 include/asm-ia64/sn/ioerror_handling.h       |   35 
 include/asm-ia64/sn/iograph.h                |   10 
 include/asm-ia64/sn/klclock.h                |    2 
 include/asm-ia64/sn/klconfig.h               |  102 
 include/asm-ia64/sn/kldir.h                  |    2 
 include/asm-ia64/sn/ksys/elsc.h              |   78 
 include/asm-ia64/sn/ksys/l1.h                |  228 
 include/asm-ia64/sn/labelcl.h                |   22 
 include/asm-ia64/sn/leds.h                   |   25 
 include/asm-ia64/sn/mmtimer_private.h        |    2 
 include/asm-ia64/sn/module.h                 |  130 
 include/asm-ia64/sn/nag.h                    |    2 
 include/asm-ia64/sn/nodepda.h                |   85 
 include/asm-ia64/sn/pci/bridge.h             |  345 -
 include/asm-ia64/sn/pci/pci_bus_cvlink.h     |    7 
 include/asm-ia64/sn/pci/pci_defs.h           |  111 
 include/asm-ia64/sn/pci/pciba.h              |    2 
 include/asm-ia64/sn/pci/pcibr.h              |  104 
 include/asm-ia64/sn/pci/pcibr_private.h      |   80 
 include/asm-ia64/sn/pci/pciio.h              |  141 
 include/asm-ia64/sn/pci/pciio_private.h      |   12 
 include/asm-ia64/sn/pda.h                    |   35 
 include/asm-ia64/sn/pio.h                    |   58 
 include/asm-ia64/sn/prio.h                   |    2 
 include/asm-ia64/sn/router.h                 |   17 
 include/asm-ia64/sn/sgi.h                    |   81 
 include/asm-ia64/sn/simulator.h              |    2 
 include/asm-ia64/sn/slotnum.h                |   11 
 include/asm-ia64/sn/sn2/addrs.h              |    4 
 include/asm-ia64/sn/sn2/arch.h               |    3 
 include/asm-ia64/sn/sn2/intr.h               |    8 
 include/asm-ia64/sn/sn2/io.h                 |   10 
 include/asm-ia64/sn/sn2/shub.h               |    2 
 include/asm-ia64/sn/sn2/shub_md.h            |    2 
 include/asm-ia64/sn/sn2/shub_mmr.h           |    8 
 include/asm-ia64/sn/sn2/shub_mmr_t.h         |    2 
 include/asm-ia64/sn/sn2/shubio.h             |  149 
 include/asm-ia64/sn/sn2/slotnum.h            |    2 
 include/asm-ia64/sn/sn2/sn_private.h         |   21 
 include/asm-ia64/sn/sn_cpuid.h               |   92 
 include/asm-ia64/sn/sn_fru.h                 |    3 
 include/asm-ia64/sn/sn_private.h             |    6 
 include/asm-ia64/sn/sn_sal.h                 |  269 
 include/asm-ia64/sn/sndrv.h                  |   32 
 include/asm-ia64/sn/sv.h                     |    2 
 include/asm-ia64/sn/systeminfo.h             |    2 
 include/asm-ia64/sn/types.h                  |    9 
 include/asm-ia64/sn/uart16550.h              |    2 
 include/asm-ia64/sn/vector.h                 |   46 
 include/asm-ia64/sn/xtalk/xbow.h             |    9 
 include/asm-ia64/sn/xtalk/xbow_info.h        |    8 
 include/asm-ia64/sn/xtalk/xswitch.h          |   21 
 include/asm-ia64/sn/xtalk/xtalk.h            |   69 
 include/asm-ia64/sn/xtalk/xtalk_private.h    |   12 
 include/asm-ia64/sn/xtalk/xtalkaddrs.h       |    3 
 include/asm-ia64/sn/xtalk/xwidget.h          |   32 
 include/asm-ia64/spinlock.h                  |    5 
 include/asm-ia64/system.h                    |   14 
 include/asm-ia64/thread_info.h               |   23 
 include/asm-ia64/timex.h                     |   10 
 include/asm-ia64/tlb.h                       |    4 
 include/asm-ia64/topology.h                  |    2 
 include/asm-ia64/unistd.h                    |   42 
 include/asm-ia64/unwind.h                    |    5 
 include/asm-ia64/ustack.h                    |   18 
 include/asm-ia64/xor.h                       |  260 
 timer.c                                      |   85 
 375 files changed, 24762 insertions(+), 77246 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/06/18 1.1331)
   ia64: Initial sync with 2.5.72.

<davidm@tiger.hpl.hp.com> (03/06/17 1.1330)
   ia64: Sync with 2.5.71.

<davidm@tiger.hpl.hp.com> (03/06/16 1.1063.9.104)
   ia64: Make brl-branches to ia64_spinlock_contention work from modules.
   	Since these branches use a special calling-convention, we don't
   	want to go through the PLT stubs normally used for cross-module
   	calls.  Also fix a 1-bit bug in the plt_reloc() function which
   	got triggered now that the core code lives below the module
   	code (due to the virtual mapping of the core).

<arun.sharma@intel.com> (03/06/16 1.1063.9.103)
   [PATCH] ia64: work around race conditions in ia32 support code
   
   This is an old problem, first reported in December 2001. 
   The test case is a multithreaded application doing a large number of 
   malloc()/free().
   
   When running on a 16k page size kernel, the current algorithm creates
   a temporary page, copies data to that page, does a new mmap and copies
   back subpages from the temporary page. This leaves a window of opportunity
   open for another thread to unmap or change the data in such a way that
   the new page has stale data.
   
   A patch was proposed which tries to do away with copying if the old page
   was writable.  The patch was rejected because it could corrupt data in
   the MAP_SHARED case.
   
   https://external-lists.vasoftware.com/archives/linux-ia64/2001-December/002549.html
   https://external-lists.vasoftware.com/archives/linux-ia64/2001-December/002550.html
   
   Since we found that most of the apps which ran into this problem were
   dealing with pages where the old data and new data are both anonymous,
   I reworked the above patch in such a way that we don't optimize for
   the MAP_SHARED case. Infact, the only case that we optimize is the case
   where the old and new mapping are both anonymous.

<davidm@tiger.hpl.hp.com> (03/06/14 1.1063.9.102)
   ia64: Still more gate DSO tuning.  Turns out a linker bug prevented
   	us from building the gate DSO in a way that makes it fit in
   	<= 1 page. If a fixed linker is available, we do it in this
   	space-saving way now. Otherwise, we'll do it the old way
   	(the gate DSO will then take up about 18KB instead of just
   	~3KB).  Thanks to Roland McGrath for making this all work.

<eranian@hpl.hp.com> (03/06/13 1.1063.9.101)
   [PATCH] ia64: minor perfmon fixes
   
   - remove extra include of asm/perfmon.h
   - fix a bug if PFM_LOAD_CONTEXT by which it would not return an
     error if the task already had a context attached.

<davidm@tiger.hpl.hp.com> (03/06/13 1.1063.9.100)
   pgtable.h:
     ia64: Rename FIXADDR_{START,TOP} to FIXADDR_USER_{START,END}.

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.99)
   Export some more symbols to get tg3.c to build as a module.

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.98)
   ia64: Fine-tune the gate DSO support a bit.

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.97)
   ia64: Minor cleanups: export more symbols, remove uncessary stop bits.

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.96)
   patch.c:
     ia64: don't forget to establish coherence after vtop patching

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.95)
   ia64: Build the gate page(s) as an ELF DSO.
         Remove CONFIG_FSYS option (it's the default now).
         Consolidate the various instruction patching routines into
         a single file (patch.c).

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.94)
   ia64: Two small fixes: fix Makefiles so "make clean" removes
   	.offsets.h.stamp.  Remove unused variable in acpi-ext code.

<davidm@tiger.hpl.hp.com> (03/06/12 1.1063.9.93)
   ia64: Split ia32-only definitions into separate ia32int.h header file.
         This avoids polluting ia64 code with definitions that are correct for
         ia32 only (for example, the ELF-related definitions would otherwise
         collide with ia64 ELF definitions).

<eranian@hpl.hp.com> (03/06/10 1.1063.9.92)
   [PATCH] ia64: fix NULL pointer dereferences in perfmon
   
   This patch fixes some NULL pointer
   problems in perfmon.
   
    - fixes NULL pointer derefence in perfmon_mckinley.h when context is not
      loaded
    - fixes typo in pfm_write_pmcs()

<peter@chubb.wattle.id.au> (03/06/10 1.1063.9.91)
   [PATCH] ia64: Define ia64_max_iommu_merge_mask unconditionally
   
   Define ia64_max_iommu_merge_mask even without CONFIG_PCI,
   so that the simulator can link.

<peter@chubb.wattle.id.au> (03/06/10 1.1063.9.90)
   [PATCH] ia64: Include lib/Kconfig for HPSIM
   
   I found the attached patch necessary to allow compressed file
   systems to be used under the simulator.  lib/Kconfig is needed to
   configure in the zlib routines.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.89)
   ia64: Add back lost change for PCI_DMA_BUS_IS_PHYS.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.88)
   ia64: No early printk for GENERIC.
   
   Here is a patch to the ia64 Kconfig file that disables the
   EARLY_PRINTK menu option if a GENERIC kernel is selected.
   
   As we discussed last week, EARLY_PRINTK doesn't work for
   GENERIC kernels because readb/readl are machvecs.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.87)
   ia64: Andrew changed his mind about the location of force_successful_syscall_return(),
   	so move it back to ptrace.h.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.86)
   ia64: Get rid of pci_dma_bus_is_phys in favor of ia64_max_iommu_merge_mask.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.85)
   smpboot.c, acpi.c:
     ia64: NR_CPUS and number of CPUs
   
   While building a kernel for our 4-way Lion box, I made the
   mistake of setting NR_CPUS to 4.  Little did I know that the
   Lion ACPI tables always list 8 CPUs (with only the first N
   enabled), and so the resulting kernel overflowed the
   smp_boot_data.cpu_phys_id array, crashed and burned.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.84)
   handle_fpu_swa() doesn't scale well if multiple CPUs need concurrent
   fp assist.  The problem lies with concurrent, potentially frequent
   updates of fpu_swa_count, which serves as the throttle for doing the
   printk().  A frenzy of concurrent updates will produce a frenzy of
   cacheline ping-ponging.
   
   The fix is simple:
   
   Only increment fpu_swa_count when the printk() is about to happen,
   which limits the increment to no more than four times every five
   seconds.

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.83)
   perfmon_generic.h, perfmon.c, Makefile:
     ia64: no perfmon 2.5 fix

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.82)
   mca.h, mca_asm.S, mca.c:
     ia64: cleaning up the INIT code

<davidm@tiger.hpl.hp.com> (03/06/10 1.1063.9.81)
   ia64: Make kernel work better on machines with I/O MMU hardware.
   	In particular, this fixes a panic() in the IDE code which
   	triggered on machines with IDE disks and memory above
   	4GB.

<davidm@tiger.hpl.hp.com> (03/06/06 1.1063.9.80)
   ia64: Move RGN_MAP_LIMIT from pgtableh to page.h and use that in ustack.h so we
   	can escape include-hell.

<eranian@hpl.hp.com> (03/06/06 1.1063.9.79)
   [PATCH] ia64: switch to perfmon2
   
   This patch contains a major rewrite of the perfmon subsystem to
   bring it to version 2.0. This version is NOT compatible with the
   existing perfmon-1.x version which was in 2.5 and still is in 2.4
   kernels. This new codebase brings a lot of new features including
   the ability to attach to already running tasks, the ability the
   follow clone2, the ability to write your own sampling buffer format
   via kernel modules. It is also much more robust than its 1.x
   counter-part. This version supports the Itanium, McKinley and
   Madison PMUs. This is beta quality code and extensions to the
   interface are planned.

<mort@wildopensource.com> (03/06/05 1.1063.9.78)
   [PATCH] ia64: max user stack size of main thread configurable via RLIMIT_STACK
   
   Make the size of the user stack based on the stack rlimit.
   The stack hard stack size now defaults to 2GB, but can be increased
    with ulimit up to 1/2 of the max mappable space in a region.
   For 16k pages, this makes the max stack size 8TB.

<mort@wildopensource.com> (03/06/05 1.1063.9.77)
   [PATCH] ia64: compile fix for HP Sim serial/console
   
   I was getting annoyed at having to mess around with the HP Simulator
   stuff when trying to compile generic kernels.  Here's the fix that I
   came up with.  It basically makes the HP Sim console another config
   option that depends on the HP sim serial code.
   
   It also sticks a couple of run-time checks in the init functions to only
   setup and run the code on hpsim machines.

<mort@wildopensource.com> (03/06/05 1.1063.9.76)
   [PATCH] ia64: runtime platform detection for 2.5
   
   This is a 2.5 version of the patch that I juggled around a couple of
   weeks ago.  It's just a simple macro that allows one to check if the
   kernel is running on a specific ia64 platform.

<davidm@tiger.hpl.hp.com> (03/06/05 1.1063.9.75)
   ia64: Remove no longer needed show_trace_task().

<davidm@tiger.hpl.hp.com> (03/06/04 1.1063.9.74)
   ia64: Misc small fixe: adjust for 2-argument version of show_stack(), remove
   	left-over bits from the old task-creation/destruction hacks.  Fix typo
   	in comment for pgprot_noncached().

<davidm@tiger.hpl.hp.com> (03/06/04 1.1063.9.73)
   ia64: Move force_successful_syscall_return() from ptrace.h to unistd.h.

<davidm@tiger.hpl.hp.com> (03/06/04 1.1063.9.72)
   ia64: Make task allocation/freeing compatible with the improved generic kernel
   	infrastructure.

<davidm@tiger.hpl.hp.com> (03/06/03 1.1063.9.71)
   ia64: Fix unwinder bug which caused it to allocate more memory than strictly
   	necessary.

<tony.luck@intel.com> (03/06/02 1.1063.9.70)
   [PATCH] ia64: fix SAVE_RESET so OS INIT handler works again
   
   The syscall optimization patches broke the OS INIT handler because
   SAVE_RESET was addressing relative to r12, which contains the virtual
   address of the stack pointer.  Fixed by addressing relative to r2/r3
   instead.

<fenghua.yu@intel.com> (03/06/02 1.1063.9.69)
   [PATCH] ia64: performance-tweak syscall exit path some more
   
   Please find the attached patch that:
   
   1. Moves user stack flag memory access before srlz.i;
   
   2. Moves mov b6=r22 as late as possible. 
   
   3. Changes (pSys) to (pLvSys) in skip_rbs_switch: section. IA32 syscall
   set pSys=1 but pLvSys=0. It's not necessary to clear bank1 r16-r19 registers
   for IA32 syscall.
   
   The number for leave_syscall is 268 cycles with this patch. The number
   is 295 cycles w/o this patch. It was 245 cycles with the original kee patched
   kernel. The 23 cycles come from restoring b6 operation which didn't exist in
   the orignal kee patch.

<kaos@ocs.com.au> (03/05/30 1.1063.9.68)
   [PATCH] ia64: fix unwinder to call get_scratch_regs() only when really needed
   
   Only call get_scratch_regs() when pt is really needed.  The extraneous
   calls to get_scratch_regs() can otherwise pick up the wrong address for pt.
   For example, calling unw_access_ar(&info, UNW_AR_BSPSTORE,...) before pt_regs
   had been reached could trigger this bug.

<venkatesh.pallipadi@intel.com> (03/05/30 1.1063.9.67)
   [PATCH] ia64: IA-32 emulation patch: ptrace get_FPREGS bug fix
   
   A bug-fix in IA-32 emulation ptrace code. The bug originally got
   introduced with the addition of FPXREGS support in ptrace.
   
   The bug is in ptrace get/set FPREGS routine. gdb by default will not use
   FPREGS routines when FPXREGS routines are supported.  So we may not see
   this bug during normal gdb operations. But, if gdb (or any other app)
   directly tries to get/set FPREGS (probably an old version of gdb), it
   will end with an segmentation fault due to this bug.
   
   Attached patch fixes the issue. The patch is taken against 2.5.69. But
   it applies to 2.4 tree as well.

<eranian@hpl.hp.com> (03/05/30 1.1063.9.66)
   [PATCH] ia64: two small fixes (perfmon & GENERIC build)
   
   the first patch  moves some definitions
   out of perfmon.c to perfmon.h (similar to what is in 2.4). 
   
   The second patch contains a fix for the generic built. I did 
   it that way to avoid other problems such as SIMSCSI depends
   on SCSI. so simply hardcoding this in the MAkefile could cause
   other problems. Anyway, SIMSCI is not defaulting to y when
   HP_SIM is defined so it is not so different.

<kochi@hpc.bs1.fc.nec.co.jp> (03/05/30 1.1063.9.65)
   [PATCH] ia64: Discontigmem bank fix
   
   Attached is a patch for interleaved discontigmem banks.
   
   When memory banks are interleaved between nodes,
   bank ids can be overwritten by other nodes.

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.64)
   ia64: Based on patch by Rohit Seth: Use "hint @pause" in more places.

<alext@fc.hp.com> (03/05/30 1.1063.9.63)
   [PATCH] ia64: small patch for arch/ia64/lib/Makefile for xor.o
   
   I was building 2.5 and noticed that if you have raid5 configured as
   a module, then the arch/ia64/lib/xor.S would not get built (gets a
   make error since c file not there).
   
   Attached patch fixes that so xor.S gets built if raid5 is built-in
   or a module.

<tony.luck@intel.com> (03/05/30 1.1063.9.62)
   [PATCH] ia64: provide a more generic vtop patching infrastructure
   
   We need sometimes to load the physical address of a kernel
   object.  Often we can convert the virtual address to physical
   at execution time, but sometimes (either for performance reasons
   or during error recovery) we cannot to this.  Patch the marked
   bundles to load the physical address.

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.61)
   ia64: Patch by Tony Luck: The INIT path was broken by the virtually mapped
   	kernel patch.  This patch makes it work again.  The MCA path is
   	similarly broken.  Patch will follow later.

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.60)
   .del-print_offsets.awk~ce325580e04f9929:
     Delete: arch/ia64/tools/print_offsets.awk
   .del-Makefile~90bde6a95198c56c:
     Delete: arch/ia64/tools/Makefile

<peter@chubb.wattle.id.au> (03/05/30 1.1063.9.59)
   [PATCH] ia64: use generic build infrastructure for generating offsets.h
   
   Delete references to arch/ia64/tools; use standard sed script to generate
   offsets.h.
   
   This gets the dependencies right for offsets.h

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.58)
   ia64: Finish the fsyscall support (finally!).  Now fsyscall stubs will
   	run faster than break-based syscall stubs, even if there is
   	no light-weight syscall handler.
   	Adds a new boot command-line option "nolwsys" which can be used
   	to turn off light-weight system call handlers.  Good for
   	performance measurement and (potentially) for debugging.

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.57)
   ia64: Small formatting fixes.

<davidm@tiger.hpl.hp.com> (03/05/30 1.1063.9.56)
   ia64: Fix typo introduced on May 28 which had the effect of asynchronous
   	signals corrupting r14.
   

<davidm@tiger.hpl.hp.com> (03/05/29 1.1063.9.55)
   ia64: Minor fixes: remove obsolete ia64_ret_from_execve_syscall() and
   	fix bit rot in signal debug printk.

<davidm@tiger.hpl.hp.com> (03/05/29 1.1063.9.54)
   ia64: Implement a first cut of a streamlined fsys_fallback_syscall.
   	Instead of using break, this one bubbles down into the kernel
   	directly.  This code works, but isn't performance optimal yet.

<davidm@tiger.hpl.hp.com> (03/05/28 1.1063.9.53)
   ia64: Make fsyscalls work again.  They broke because the streamlined syscall path
   	didn't preserve b6 and r11 anymore.  Unfortunately, preserving them costs
   	a few cycles (~5 cycles in the cached case).  The uncached case is hopefully
   	mostly unaffected because the number of cache-lines touched is the same
   	(without preserving b6 and r11, the entry-patch _almost_ got away with
   	touching a single 128-byte cacheline, but not quite, because r8 also
   	had to be initialized).

<davidm@tiger.hpl.hp.com> (03/05/28 1.1063.9.52)
   ia64: In start_thread(), remove the clearing of the scratch registers which are
   	now cleared by the syscall exit path.

<davidm@tiger.hpl.hp.com> (03/05/28 1.1063.9.51)
   ia64: Reformat .mem.offset directives.  Affects many lines, but they're all
   	whitespace changes only.

<davidm@tiger.hpl.hp.com> (03/05/28 1.1063.9.50)
   ia64: Lots of formatting fixes for the optimized syscall paths.
   	Fix setting of current->thread.on_ustack flag in optimized syscall exit path.
   	Tune break_fault for syscall execution.
   	Break ia32_execve: the ia64_execve() hack that was there is too ugly for
   	words; surely we can do better...

<jbarnes@sgi.com> (03/05/23 1.1063.9.49)
   [PATCH] ia64: more SN2 cleanups
   
   Here's another sn2 update.  It includes a bunch of misc. bits:
     o a bunch of cleanup from hch
     o addition of DMA routine wrappers
     o update of other PCI routines
     o topology.h prototype addition.

<mort@wildopensource.com> (03/05/23 1.1063.9.48)
   [PATCH] ia64: Change mmu_gathers into per-cpu data
   

<rohit.seth@intel.com> (03/05/22 1.1063.9.47)
   [PATCH] ia64: fix syscall optimization path so CONFIG_PREEMPT works again
   
   This should get the CONFIG_PREEMPT to work again.  We were trashing
   r20 by accident.

<davidm@tiger.hpl.hp.com> (03/05/22 1.1063.9.46)
   ia64: Patch by Arun Sharma: In the absence of the patch, this system call
   fails:
   
   shmctl(shmid, IPC_STAT, &shmid_ds) 
   
   The patch corrects the definition of the ipc_perm32 structure.

<arun.sharma@intel.com> (03/05/22 1.1063.9.45)
   [PATCH] ia64: fix IA-32 version of shmctl()
   
   This one is similar to msgctl. We should be calling sys_shmctl with
   struct shmid64_ds.
   
   In the absence of this patch:
   
   shmctl(shmid, IPC_SET, &shmid_ds)
   
   will fail.

<arun.sharma@intel.com> (03/05/22 1.1063.9.44)
   [PATCH] ia64: fix IA-32 emulation of msgctl()
   
   IA-32 programs executing:
   
   msgctl(id, IPC_SET, &buf)
   
   currently fail with EPERM due to this bug.

<asit.k.mallick@intel.com> (03/05/22 1.1063.9.43)
   [PATCH] ia64: three more fph fixes (all UP-related)
   

<davidm@tiger.hpl.hp.com> (03/05/21 1.1063.9.42)
   ia64: Restructure pt_regs and optimize syscall path.
   
   Patch by Rohit Seth, Fengua Yu, and Arun Sharma:
   
   Please find attached a patch for kernel entry exit optimization. This is
   based on 2.5.69 kernel.
   
   The main items covered by this patch are:
   1) Support for 16 bytes instructions as per SDM2.1 (CSD/SSD in pt_regs)
   2) f10-f11 are added as additional scratch registers for kernel's use.
   3) Re-arrange pt_regs to access less cache lines in system call. Reduce
   scratch register saving/restoring in system call path.
   4) A few instruction reorg in low-level code.

<davidm@tiger.hpl.hp.com> (03/05/21 1.1063.9.41)
   ia64: Fix unwinder so core-dumps work again.  Without this patch, most scratch-regs
   	came out wrong.

<davidm@tiger.hpl.hp.com> (03/05/21 1.1063.9.40)
   ia64: Make hugetlb support compile again.

<davidm@tiger.hpl.hp.com> (03/05/19 1.1063.9.39)
   ia64: Remove unnecesary include of <asm/offsets.h>.

<davidm@tiger.hpl.hp.com> (03/05/19 1.1063.9.38)
   ia64: More time-interpolation cleanups; correct SN2 interpolator.

<davidm@tiger.hpl.hp.com> (03/05/19 1.1063.9.37)
   ia64: Update for new time_interpolator infrastructure.

<jbarnes@sgi.com> (03/05/19 1.1063.9.36)
   [PATCH] ia64: SN cleanups
   
   Some patches from hch@infradead.org cleaning up sn2 code a bit,
   including the removal of some unnecessary files.

<davidm@tiger.hpl.hp.com> (03/05/16 1.1063.9.35)
   ia64: Fix UP build: ia64_spinlock_contention() is for SMP only.

<jbarnes@sgi.com> (03/05/16 1.1063.9.34)
   [PATCH] ia64: SGI SN update
   

<davidm@tiger.hpl.hp.com> (03/05/16 1.1063.9.33)
   ia64: Make Ski bootloader work with virtually-mapped kernel.

<tony.luck@intel.com> (03/05/16 1.1063.9.32)
   [PATCH] ia64: put kernel into virtually mapped area
   
   This patch moves the kernel text and data into region 5 (0xa00...) by using
   a translation register to pin the entire area (i.e., no TLB faults).
   The 1st-order goal is to be able to boot a kernel even when there is
   no usable memory in the 64-128MB range.  It is also a step towards enabling
   text-replication on NUMA.

<davidm@tiger.hpl.hp.com> (03/05/15 1.1063.9.31)
   ia64: Re-enable -frename-registers for McKinley.

<davidm@tiger.hpl.hp.com> (03/05/15 1.1063.9.30)
   ia64: Fix obsolete call to ia64_set_fpu_owner() (affected UP only).

<arun.sharma@intel.com> (03/05/15 1.1063.9.29)
   [PATCH] ia64: make ia32 ioctl()s work again
   

<eranian@hpl.hp.com> (03/05/15 1.1063.9.28)
   [PATCH] ia64: perfmon fix
   
   This patch allows users to set the PMC to their default value, even
   though the value might conflict with the type of monitoring
   session. This is fine because default values ensure the monitor is not
   active.

<davidm@wailua.hpl.hp.com> (03/05/14 1.1063.9.27)
   ia64: Fix more merge errors.  Correct SN2 callbacks to also invoke the generic ia64
         callbacks so last_nsec_offset gets updated, too.

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.26)
   ia64: Fix Makefile typo and retain -frename-registers for Itanium.

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.25)
   ia64: Desupport GCC 2.96 and everything older.

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.24)
   ia64: Fix typo in do_settimeofday().

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.23)
   Check in new SN2 file from Jes' gettimeoffset() patch.

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.22)
   ia64: Fix various minor merge errors and build errors.  Fix page-fault handler
   	so it handles not-present translations for region 5 (patch by John Marvin).

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.21)
   ia64: Fix SMP fph-handling.  Patch by Asit Mallick with some additional
         changes by yours truly.

<schwab@suse.de> (03/05/14 1.1063.9.20)
   [PATCH] ia64: fix ia32 sched_{s,g}etaffinity()
   

<davidm@tiger.hpl.hp.com> (03/05/14 1.1063.9.19)
   ia64: Patch by Arun Sharma: Undo bad sys32_select() fix: The biggest value of n below
   is INT_MAX and the value of size for n = INT_MAX is 268435456. So I don't think
   there'll be an overflow.

<jes@wildopensource.com> (03/05/14 1.1063.9.18)
   [PATCH] cpu_idle() cleanup
   

<jes@wildopensource.com> (03/05/14 1.1063.9.17)
   [PATCH] ia64: gettimeoffset hooks
   
   Make it possible to plug in alternate time-offset sources, such as external
   (e.g., chipset) timers or High-Performance Event Timer (HPET) etc. This
   is needed on platforms where the cycle-counters on different CPUs may
   drift apart from each other.
   This patch contains the ia64-specific portion only.

<davidm@tiger.hpl.hp.com> (03/05/13 1.1063.9.16)
   ia64: Move ia64 ELF relocations to ia64-specific elf.h.

<davidm@tiger.hpl.hp.com> (03/05/13 1.1063.9.15)
   ia64: Couple of minor NEW_LOCK spinlock fixes.  Put RAID5 xor routines only into
   	kernel if CONFIG_MD_RAID5 is declared.

<davidm@tiger.hpl.hp.com> (03/05/13 1.1063.9.14)
   ia64: Fix ptrace() RNaT accessors.

<davidm@wailua.hpl.hp.com> (03/05/13 1.1063.9.13)
   ia64: Allow 4GB TLB purges by default.  Reported by Rohit Seth.

<davidm@wailua.hpl.hp.com> (03/05/12 1.1063.9.12)
   ia64: Clean up purge-page-size-from-PAL patch a bit.

<rohit.seth@intel.com> (03/05/12 1.1063.9.11)
   [PATCH] ia64: patch to use >256MB purges
   
   Attached is the updated patch that takes the supported purge page size
   bits from PAL call.

<asit.k.mallick@intel.com> (03/05/12 1.1063.9.10)
   [PATCH] ia64: replace RAID xor routine into an assembly file
   

<Walter.Harms@Informatik.Uni-Oldenburg.DE> (03/05/12 1.1063.9.9)
   [PATCH] ia64: improve kernel_thread() cleanliness
   
   This is a fix to kernel_thread(). I dont claim to fix any real problem
   its just a fix to return pid_t. This is part of a series of fixes for
   the linux kernel 2.4.20 to make proper use of pid_t.

<rohit.seth@intel.com> (03/05/12 1.1063.9.8)
   [PATCH] ia64: small update for hugetlb
   
   Please find attached a small update that syncs up the definition and
   usage of check_valid_hugepage_range across different arch dependent and
   independent files.

