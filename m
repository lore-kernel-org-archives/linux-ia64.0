From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Aug 2008 21:50:43 +0000
Subject: [git pull] ia64 change (include/asm-ia64 -> arch/ia64/include/asm)
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3082ABD3A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

        git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 {include/asm-ia64 => arch/ia64/include/asm}/Kbuild |    0
 .../asm-ia64 => arch/ia64/include/asm}/a.out.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/acpi-ext.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/acpi.h |    2 --
 {include/asm-ia64 => arch/ia64/include/asm}/agp.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/asmmacro.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/atomic.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/auxvec.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/bitops.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/break.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/bug.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/bugs.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/byteorder.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/cache.h     |    0
 .../ia64/include/asm}/cacheflush.h                 |    0
 .../asm-ia64 => arch/ia64/include/asm}/checksum.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/compat.h    |    0
 {include/asm-ia64 => arch/ia64/include/asm}/cpu.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/cputime.h   |    3 +--
 .../asm-ia64 => arch/ia64/include/asm}/current.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/cyclone.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/delay.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/device.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/div64.h     |    0
 .../ia64/include/asm}/dma-mapping.h                |    0
 {include/asm-ia64 => arch/ia64/include/asm}/dma.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/dmi.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/elf.h  |    0
 .../ia64/include/asm}/emergency-restart.h          |    0
 .../asm-ia64 => arch/ia64/include/asm}/errno.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/esi.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/fb.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/fcntl.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/fpswa.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/fpu.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/futex.h     |    0
 .../ia64/include/asm}/gcc_intrin.h                 |    0
 .../asm-ia64 => arch/ia64/include/asm}/hardirq.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/hpsim.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/hugetlb.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/hw_irq.h    |    0
 {include/asm-ia64 => arch/ia64/include/asm}/ia32.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/ia64regs.h  |    0
 .../ia64/include/asm}/intel_intrin.h               |    0
 .../ia64/include/asm}/intrinsics.h                 |    0
 {include/asm-ia64 => arch/ia64/include/asm}/io.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/ioctl.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/ioctls.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/iosapic.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/ipcbuf.h    |    0
 {include/asm-ia64 => arch/ia64/include/asm}/irq.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/irq_regs.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/kdebug.h    |    2 --
 .../asm-ia64 => arch/ia64/include/asm}/kexec.h     |    0
 .../ia64/include/asm}/kmap_types.h                 |    0
 .../asm-ia64 => arch/ia64/include/asm}/kprobes.h   |    1 -
 .../asm-ia64 => arch/ia64/include/asm}/kregs.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/kvm.h  |    2 +-
 .../asm-ia64 => arch/ia64/include/asm}/kvm_host.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/kvm_para.h  |    2 --
 .../ia64/include/asm}/libata-portmap.h             |    0
 .../asm-ia64 => arch/ia64/include/asm}/linkage.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/local.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/machvec.h   |    2 +-
 .../ia64/include/asm}/machvec_dig.h                |    0
 .../ia64/include/asm}/machvec_hpsim.h              |    0
 .../ia64/include/asm}/machvec_hpzx1.h              |    0
 .../ia64/include/asm}/machvec_hpzx1_swiotlb.h      |    0
 .../ia64/include/asm}/machvec_init.h               |    0
 .../ia64/include/asm}/machvec_sn2.h                |    0
 .../ia64/include/asm}/machvec_uv.h                 |    0
 .../ia64/include/asm}/mc146818rtc.h                |    0
 {include/asm-ia64 => arch/ia64/include/asm}/mca.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/mca_asm.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/meminit.h   |    0
 {include/asm-ia64 => arch/ia64/include/asm}/mman.h |    0
 {include/asm-ia64 => arch/ia64/include/asm}/mmu.h  |    0
 .../ia64/include/asm}/mmu_context.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/mmzone.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/module.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/msgbuf.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/mutex.h     |    0
 .../ia64/include/asm}/native/inst.h                |    2 +-
 .../ia64/include/asm}/native/irq.h                 |    4 +---
 .../asm-ia64 => arch/ia64/include/asm}/nodedata.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/numa.h |    0
 {include/asm-ia64 => arch/ia64/include/asm}/page.h |    0
 {include/asm-ia64 => arch/ia64/include/asm}/pal.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/param.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/paravirt.h  |    2 --
 .../ia64/include/asm}/paravirt_privop.h            |    2 --
 .../asm-ia64 => arch/ia64/include/asm}/parport.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/patch.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/pci.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/percpu.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/perfmon.h   |    0
 .../ia64/include/asm}/perfmon_default_smpl.h       |    0
 .../asm-ia64 => arch/ia64/include/asm}/pgalloc.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/pgtable.h   |    0
 {include/asm-ia64 => arch/ia64/include/asm}/poll.h |    0
 .../ia64/include/asm}/posix_types.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/processor.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/ptrace.h    |    0
 .../ia64/include/asm}/ptrace_offsets.h             |    0
 .../asm-ia64 => arch/ia64/include/asm}/resource.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/rse.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/rwsem.h     |    2 +-
 {include/asm-ia64 => arch/ia64/include/asm}/sal.h  |    0
 .../ia64/include/asm}/scatterlist.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/sections.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/segment.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sembuf.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/serial.h    |    2 --
 .../asm-ia64 => arch/ia64/include/asm}/setup.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/shmbuf.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/shmparam.h  |    0
 .../ia64/include/asm}/sigcontext.h                 |    0
 .../asm-ia64 => arch/ia64/include/asm}/siginfo.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/signal.h    |    0
 {include/asm-ia64 => arch/ia64/include/asm}/smp.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/acpi.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/addrs.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/arch.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/bte.h    |    0
 .../ia64/include/asm}/sn/clksupport.h              |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/geo.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/intr.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/io.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/ioc3.h   |    0
 .../ia64/include/asm}/sn/klconfig.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/l1.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/leds.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/module.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/mspec.h  |    0
 .../ia64/include/asm}/sn/nodepda.h                 |    0
 .../ia64/include/asm}/sn/pcibr_provider.h          |    0
 .../ia64/include/asm}/sn/pcibus_provider_defs.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/pcidev.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/pda.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/pic.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/rw_mmr.h |    0
 .../ia64/include/asm}/sn/shub_mmr.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/shubio.h |    0
 .../ia64/include/asm}/sn/simulator.h               |    0
 .../ia64/include/asm}/sn/sn2/sn_hwperf.h           |    0
 .../ia64/include/asm}/sn/sn_cpuid.h                |    0
 .../ia64/include/asm}/sn/sn_feature_sets.h         |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/sn_sal.h |    2 +-
 .../asm-ia64 => arch/ia64/include/asm}/sn/tioca.h  |    0
 .../ia64/include/asm}/sn/tioca_provider.h          |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/tioce.h  |    0
 .../ia64/include/asm}/sn/tioce_provider.h          |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/tiocp.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/tiocx.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/sn/types.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/socket.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/sockios.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/sparsemem.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/spinlock.h  |    0
 .../ia64/include/asm}/spinlock_types.h             |    0
 {include/asm-ia64 => arch/ia64/include/asm}/stat.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/statfs.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/string.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/suspend.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/system.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/termbits.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/termios.h   |    0
 .../ia64/include/asm}/thread_info.h                |    0
 .../asm-ia64 => arch/ia64/include/asm}/timex.h     |    0
 {include/asm-ia64 => arch/ia64/include/asm}/tlb.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/tlbflush.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/topology.h  |    2 --
 .../asm-ia64 => arch/ia64/include/asm}/types.h     |    0
 .../asm-ia64 => arch/ia64/include/asm}/uaccess.h   |    0
 .../asm-ia64 => arch/ia64/include/asm}/ucontext.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/unaligned.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/uncached.h  |    0
 .../asm-ia64 => arch/ia64/include/asm}/unistd.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/unwind.h    |    0
 {include/asm-ia64 => arch/ia64/include/asm}/user.h |    0
 .../asm-ia64 => arch/ia64/include/asm}/ustack.h    |    0
 .../asm-ia64 => arch/ia64/include/asm}/uv/uv_hub.h |    0
 .../ia64/include/asm}/uv/uv_mmrs.h                 |    0
 {include/asm-ia64 => arch/ia64/include/asm}/vga.h  |    0
 {include/asm-ia64 => arch/ia64/include/asm}/xor.h  |    2 --
 arch/ia64/kernel/asm-offsets.c                     |   10 +++++-----
 arch/ia64/kernel/head.S                            |    2 +-
 arch/ia64/kernel/iosapic.c                         |    2 +-
 arch/ia64/kernel/jprobes.S                         |    2 +-
 arch/ia64/kernel/nr-irqs.c                         |    2 +-
 arch/ia64/kernel/setup.c                           |    2 +-
 arch/ia64/sn/kernel/iomv.c                         |    2 +-
 192 files changed, 18 insertions(+), 38 deletions(-)
 rename {include/asm-ia64 => arch/ia64/include/asm}/Kbuild (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/a.out.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/acpi-ext.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/acpi.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/agp.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/asmmacro.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/atomic.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/auxvec.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/bitops.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/break.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/bug.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/bugs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/byteorder.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/cache.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/cacheflush.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/checksum.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/compat.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/cpu.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/cputime.h (97%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/current.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/cyclone.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/delay.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/device.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/div64.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/dma-mapping.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/dma.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/dmi.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/elf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/emergency-restart.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/errno.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/esi.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/fb.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/fcntl.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/fpswa.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/fpu.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/futex.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/gcc_intrin.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/hardirq.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/hpsim.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/hugetlb.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/hw_irq.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ia32.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ia64regs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/intel_intrin.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/intrinsics.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/io.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ioctl.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ioctls.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/iosapic.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ipcbuf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/irq.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/irq_regs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kdebug.h (98%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kexec.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kmap_types.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kprobes.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kregs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kvm.h (98%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kvm_host.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/kvm_para.h (97%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/libata-portmap.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/linkage.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/local.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_dig.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_hpsim.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_hpzx1.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_hpzx1_swiotlb.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_init.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_sn2.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/machvec_uv.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mc146818rtc.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mca.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mca_asm.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/meminit.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mman.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mmu.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mmu_context.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mmzone.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/module.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/msgbuf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/mutex.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/native/inst.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/native/irq.h (93%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/nodedata.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/numa.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/page.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/pal.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/param.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/paravirt.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/paravirt_privop.h (98%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/parport.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/patch.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/pci.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/percpu.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/perfmon.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/perfmon_default_smpl.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/pgalloc.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/pgtable.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/poll.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/posix_types.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/processor.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ptrace.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ptrace_offsets.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/resource.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/rse.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/rwsem.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sal.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/scatterlist.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sections.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/segment.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sembuf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/serial.h (93%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/setup.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/shmbuf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/shmparam.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sigcontext.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/siginfo.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/signal.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/smp.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/acpi.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/addrs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/arch.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/bte.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/clksupport.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/geo.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/intr.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/io.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/ioc3.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/klconfig.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/l1.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/leds.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/module.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/mspec.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/nodepda.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/pcibr_provider.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/pcibus_provider_defs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/pcidev.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/pda.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/pic.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/rw_mmr.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/shub_mmr.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/shubio.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/simulator.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/sn2/sn_hwperf.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/sn_cpuid.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/sn_feature_sets.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/sn_sal.h (99%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tioca.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tioca_provider.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tioce.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tioce_provider.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tiocp.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/tiocx.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sn/types.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/socket.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sockios.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/sparsemem.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/spinlock.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/spinlock_types.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/stat.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/statfs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/string.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/suspend.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/system.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/termbits.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/termios.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/thread_info.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/timex.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/tlb.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/tlbflush.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/topology.h (98%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/types.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/uaccess.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ucontext.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/unaligned.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/uncached.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/unistd.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/unwind.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/user.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/ustack.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/uv/uv_hub.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/uv/uv_mmrs.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/vga.h (100%)
 rename {include/asm-ia64 => arch/ia64/include/asm}/xor.h (97%)

Tony Luck (1):
      [IA64] Move include/asm-ia64 to arch/ia64/include/asm



