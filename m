From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 27 Apr 2006 23:38:39 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200604272338.k3RNcdoH020866@agluck-lia64.sc.intel.com>
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

Thanks!

-Tony

 arch/ia64/Kconfig                   |    2 
 arch/ia64/configs/sn2_defconfig     |   76 +++++++++++++++++++++---------------
 arch/ia64/ia32/binfmt_elf32.c       |    3 +
 arch/ia64/ia32/ia32_entry.S         |    2 
 arch/ia64/kernel/mca_drv.c          |   54 +++++++++++++++++--------
 arch/ia64/kernel/topology.c         |    7 ---
 arch/ia64/pci/pci.c                 |    3 -
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    8 +--
 arch/ia64/sn/kernel/xpc_partition.c |    8 ---
 arch/ia64/sn/pci/tioce_provider.c   |    6 +-
 drivers/Kconfig                     |    2 
 include/asm-ia64/acpi.h             |    5 --
 include/asm-ia64/machvec.h          |    2 
 include/asm-ia64/sn/sn2/sn_hwperf.h |    6 ++
 include/asm-ia64/sn/sn_sal.h        |   17 ++++++--
 include/asm-ia64/thread_info.h      |    2 
 include/asm-ia64/topology.h         |    5 ++
 17 files changed, 128 insertions(+), 80 deletions(-)

Brent Casavant:
      [IA64] IOC4 config option ordering

Christoph Lameter:
      [IA64] Setup an IA64 specific reclaim distance

Cliff Wickman:
      [IA64] enable dumps to capture second page of kernel stack

Jack Steiner:
      [IA64] - Fix MAX_PXM_DOMAINS for systems with > 256 nodes
      [IA64-SGI] - Fix discover of nearest cpu node to IO node
      [IA64-SGI] - Reduce overhead of reading sn_topology

Jes Sorensen:
      [IA64] update sn2 defconfig

Jesper Juhl:
      [IA64] Remove redundant NULL checks before kfree

Mike Habeck:
      [IA64-SGI] fix SGI Altix tioce_reserve_m32() bug

Russ Anderson:
      [IA64] Remove unused variable in sn_sal.h
      [IA64-SGI] SN SAL call to inject memory errors
      [IA64] Add mca recovery failure messages

Satoru Takeuchi:
      [IA64] eliminate compile time warnings
      [IA64] eliminate compile time warnings

Tony Luck:
      [IA64] wire up compat_sys_adjtimex()

diff-tree 7384c8bd90a4932517872f9807d34979a6fd29c4 (from 189979619f90fd2eb168fbb9c262569176160624)
Author: Jes Sorensen <jes@sgi.com>
Date:   Thu Apr 27 06:10:35 2006 -0400

    [IA64] update sn2 defconfig
    
    Update SN2 defconfig to latest kernel and add QLA FC drivers commonly
    found in SN2 boxes.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index a718034..f6a8853 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.16-rc5
-# Mon Feb 27 16:06:38 2006
+# Linux kernel version: 2.6.17-rc3
+# Thu Apr 27 11:48:23 2006
 #
 
 #
@@ -24,6 +24,7 @@ CONFIG_SYSCTL=y
 # CONFIG_AUDIT is not set
 # CONFIG_IKCONFIG is not set
 CONFIG_CPUSETS=y
+CONFIG_RELAY=y
 CONFIG_INITRAMFS_SOURCE=""
 CONFIG_CC_OPTIMIZE_FOR_SIZE=y
 # CONFIG_EMBEDDED is not set
@@ -38,10 +39,6 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_CC_ALIGN_FUNCTIONS=0
-CONFIG_CC_ALIGN_LABELS=0
-CONFIG_CC_ALIGN_LOOPS=0
-CONFIG_CC_ALIGN_JUMPS=0
 CONFIG_SLAB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
@@ -53,7 +50,6 @@ #
 CONFIG_MODULES=y
 CONFIG_MODULE_UNLOAD=y
 # CONFIG_MODULE_FORCE_UNLOAD is not set
-CONFIG_OBSOLETE_MODPARM=y
 # CONFIG_MODVERSIONS is not set
 # CONFIG_MODULE_SRCVERSION_ALL is not set
 CONFIG_KMOD=y
@@ -62,6 +58,7 @@ CONFIG_STOP_MACHINE=y
 #
 # Block layer
 #
+# CONFIG_BLK_DEV_IO_TRACE is not set
 
 #
 # IO Schedulers
@@ -84,8 +81,10 @@ CONFIG_64BIT=y
 CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
+CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
@@ -116,7 +115,6 @@ CONFIG_IA64_SGI_SN_XP=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS24
-CONFIG_IA64_NR_NODES%6
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y
@@ -136,6 +134,7 @@ CONFIG_ARCH_FLATMEM_ENABLE=y
 CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
+CONFIG_NODES_SHIFT=8
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
@@ -187,7 +186,6 @@ #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
-CONFIG_PCI_LEGACY_PROC=y
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -231,6 +229,7 @@ CONFIG_SYN_COOKIES=y
 # CONFIG_INET_AH is not set
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_XFRM_TUNNEL is not set
 # CONFIG_INET_TUNNEL is not set
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
@@ -238,9 +237,11 @@ # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_BIC=y
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
+# CONFIG_IPV6_ROUTER_PREF is not set
 # CONFIG_INET6_AH is not set
 # CONFIG_INET6_ESP is not set
 # CONFIG_INET6_IPCOMP is not set
+# CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
 # CONFIG_IPV6_TUNNEL is not set
 # CONFIG_NETFILTER is not set
@@ -468,9 +469,14 @@ # CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
 # CONFIG_SCSI_IPR is not set
-# CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
-# CONFIG_SCSI_QLA_FC is not set
+CONFIG_SCSI_QLA_FC=y
+CONFIG_SCSI_QLA2XXX_EMBEDDED_FIRMWARE=y
+# CONFIG_SCSI_QLA21XX is not set
+CONFIG_SCSI_QLA22XX=y
+CONFIG_SCSI_QLA2300=y
+CONFIG_SCSI_QLA2322=y
+# CONFIG_SCSI_QLA24XX is not set
 # CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
@@ -486,6 +492,7 @@ CONFIG_MD_RAID0=y
 CONFIG_MD_RAID1=y
 # CONFIG_MD_RAID10 is not set
 CONFIG_MD_RAID5=y
+# CONFIG_MD_RAID5_RESHAPE is not set
 # CONFIG_MD_RAID6 is not set
 CONFIG_MD_MULTIPATH=y
 # CONFIG_MD_FAULTY is not set
@@ -694,6 +701,7 @@ #
 # Ftape, the floppy tape device driver
 #
 CONFIG_AGP=y
+# CONFIG_AGP_VIA is not set
 CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
@@ -735,10 +743,6 @@ # Misc devices
 #
 
 #
-# Multimedia Capabilities Port drivers
-#
-
-#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -747,6 +751,7 @@ #
 # Digital Video Broadcasting Devices
 #
 # CONFIG_DVB is not set
+# CONFIG_USB_DABUSB is not set
 
 #
 # Graphics support
@@ -757,6 +762,7 @@ #
 # Console display driver support
 #
 CONFIG_VGA_CONSOLE=y
+# CONFIG_VGACON_SOFT_SCROLLBACK is not set
 CONFIG_DUMMY_CONSOLE=y
 
 #
@@ -769,6 +775,7 @@ # USB support
 #
 CONFIG_USB_ARCH_HAS_HCD=y
 CONFIG_USB_ARCH_HAS_OHCI=y
+CONFIG_USB_ARCH_HAS_EHCI=y
 CONFIG_USB=m
 # CONFIG_USB_DEBUG is not set
 
@@ -829,9 +836,7 @@ # CONFIG_USB_WACOM is not set
 # CONFIG_USB_ACECAD is not set
 # CONFIG_USB_KBTAB is not set
 # CONFIG_USB_POWERMATE is not set
-# CONFIG_USB_MTOUCH is not set
-# CONFIG_USB_ITMTOUCH is not set
-# CONFIG_USB_EGALAX is not set
+# CONFIG_USB_TOUCHSCREEN is not set
 # CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
@@ -844,15 +849,6 @@ # USB Imaging devices
 #
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_MICROTEK is not set
-
-#
-# USB Multimedia devices
-#
-# CONFIG_USB_DABUSB is not set
-
-#
-# Video4Linux support is needed for USB Multimedia device support
-#
 
 #
 # USB Network Adapters
@@ -904,16 +900,30 @@ # MMC/SD Card support
 #
 # CONFIG_MMC is not set
 
+#
+# LED devices
 #
+# CONFIG_NEW_LEDS is not set
+
+#
+# LED drivers
+#
+
+#
+# LED Triggers
+#
+
+#
 # InfiniBand support
 #
 CONFIG_INFINIBAND=m
 # CONFIG_INFINIBAND_USER_MAD is not set
 CONFIG_INFINIBAND_USER_ACCESS=m
 CONFIG_INFINIBAND_MTHCA=m
-# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
+CONFIG_INFINIBAND_MTHCA_DEBUG=y
 CONFIG_INFINIBAND_IPOIB=m
-# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
+CONFIG_INFINIBAND_IPOIB_DEBUG=y
+# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
 CONFIG_INFINIBAND_SRP=m
 
 #
@@ -921,10 +931,15 @@ # SN Devices
 #
 CONFIG_SGI_IOC4=y
 CONFIG_SGI_IOC3=y
+
+#
+# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
+#
 
 #
-# EDAC - error detection and reporting (RAS)
+# Real Time Clock
 #
+# CONFIG_RTC_CLASS is not set
 
 #
 # File systems
@@ -997,7 +1012,6 @@ CONFIG_TMPFS=y
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
-CONFIG_RELAYFS_FS=m
 # CONFIG_CONFIGFS_FS is not set
 
 #

diff-tree 189979619f90fd2eb168fbb9c262569176160624 (from cda3d4a069b915cf46e640bb6872a9d9aefeaabe)
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Thu Apr 27 10:07:08 2006 -0500

    [IA64] Add mca recovery failure messages
    
    When the mca recovery code encounters a condition that makes
    the MCA non-recoverable, print the reason it could not recover.
    This will make it easier to identify why the recovery code did
    not recover.
    
    Signed-off-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 37c88eb..ca6666b 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -62,6 +62,11 @@ typedef enum {
 	ISOLATE_NONE
 } isolate_status_t;
 
+typedef enum {
+	MCA_NOT_RECOVERED = 0,
+	MCA_RECOVERED	  = 1
+} recovery_status_t;
+
 /*
  *  This pool keeps pointers to the section part of SAL error record
  */
@@ -70,7 +75,19 @@ static struct {
 	int	     cur_idx; /* Current index of section pointer list pool */
 	int	     max_idx; /* Maximum index of section pointer list pool */
 } slidx_pool;
+
+static int
+fatal_mca(const char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	vprintk(fmt, args);
+	va_end(args);
 
+	return MCA_NOT_RECOVERED;
+}
+
 /**
  * mca_page_isolate - isolate a poisoned page in order not to use it later
  * @paddr:	poisoned memory location
@@ -424,7 +441,7 @@ recover_from_read_error(slidx_table_t *s
 
 	/* Is target address valid? */
 	if (!pbci->tv)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: target address not valid\n");
 
 	/*
 	 * cpu read or memory-mapped io read
@@ -442,7 +459,7 @@ recover_from_read_error(slidx_table_t *s
 
 	/* Is minstate valid? */
 	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: minstate not valid\n");
 	psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
 	psr2 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_xpsr);
 
@@ -476,12 +493,13 @@ recover_from_read_error(slidx_table_t *s
 			psr2->bn  = 1;
 			psr2->i  = 0;
 
-			return 1;
+			return MCA_RECOVERED;
 		}
 
 	}
 
-	return 0;
+	return fatal_mca(KERN_ALERT "MCA: kernel context not recovered,"
+			  " iip 0x%lx\n", pmsa->pmsa_iip);
 }
 
 /**
@@ -567,13 +585,13 @@ recover_from_processor_error(int platfor
 	 * The machine check is corrected.
 	 */
 	if (psp->cm = 1)
-		return 1;
+		return MCA_RECOVERED;
 
 	/*
 	 * The error was not contained.  Software must be reset.
 	 */
 	if (psp->us || psp->ci = 0)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: error not contained\n");
 
 	/*
 	 * The cache check and bus check bits have four possible states
@@ -584,20 +602,22 @@ recover_from_processor_error(int platfor
 	 *    1  1	Memory error, attempt recovery
 	 */
 	if (psp->bc = 0 || pbci = NULL)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: No bus check\n");
 
 	/*
 	 * Sorry, we cannot handle so many.
 	 */
 	if (peidx_bus_check_num(peidx) > 1)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: Too many bus checks\n");
 	/*
 	 * Well, here is only one bus error.
 	 */
-	if (pbci->ib || pbci->cc)
-		return 0;
+	if (pbci->ib)
+		return fatal_mca(KERN_ALERT "MCA: Internal Bus error\n");
+	if (pbci->cc)
+		return fatal_mca(KERN_ALERT "MCA: Cache-cache error\n");
 	if (pbci->eb && pbci->bsi > 0)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: External bus check fatal status\n");
 
 	/*
 	 * This is a local MCA and estimated as recoverble external bus error.
@@ -609,7 +629,7 @@ recover_from_processor_error(int platfor
 	/*
 	 * On account of strange SAL error record, we cannot recover.
 	 */
-	return 0;
+	return fatal_mca(KERN_ALERT "MCA: Strange SAL record\n");
 }
 
 /**
@@ -638,12 +658,10 @@ mca_try_to_recover(void *rec, struct ia6
 
 	 /* Now, OS can recover when there is one processor error section */
 	if (n_proc_err > 1)
-		return 0;
-	else if (n_proc_err = 0) {
+		return fatal_mca(KERN_ALERT "MCA: Too Many Errors\n");
+	else if (n_proc_err = 0)
 		/* Weird SAL record ... We need not to recover */
-
-		return 1;
-	}
+		return fatal_mca(KERN_ALERT "MCA: Weird SAL record\n");
 
 	/* Make index of processor error section */
 	mca_make_peidx((sal_log_processor_info_t*)
@@ -654,7 +672,7 @@ mca_try_to_recover(void *rec, struct ia6
 
 	/* Check whether MCA is global or not */
 	if (is_mca_global(&peidx, &pbci, sos))
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: global MCA\n");
 	
 	/* Try to recover a processor error */
 	return recover_from_processor_error(platform_err, &slidx, &peidx,

diff-tree cda3d4a069b915cf46e640bb6872a9d9aefeaabe (from 1df57c0c21c92a6d4fcfe5304c84151ed9beb7a2)
Author: Mike Habeck <habeck@sgi.com>
Date:   Wed Apr 26 12:05:50 2006 -0500

    [IA64-SGI] fix SGI Altix tioce_reserve_m32() bug
    
    The following patch fixes a bug in the SGI Altix tioce_reserve_m32()
    code.  The bug was that we could walking past the end of the CE ASIC
    32/40bit PMU ATE Buffer, resulting in a PIO Reply Error.
    
    Signed-off-by: Mike Habeck <habeck@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index fa073cc..8332956 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -682,9 +682,6 @@ tioce_reserve_m32(struct tioce_kernel *c
 	int ate_index, last_ate, ps;
 	struct tioce *ce_mmr;
 
-	if (!TIOCE_M32_ADDR(base))
-		return;
-
 	ce_mmr = (struct tioce *)ce_kern->ce_common->ce_pcibus.bs_base;
 	ps = ce_kern->ce_ate3240_pagesize;
 	ate_index = ATE_PAGE(base, ps);
@@ -692,6 +689,9 @@ tioce_reserve_m32(struct tioce_kernel *c
 
 	if (ate_index < 64)
 		ate_index = 64;
+
+	if (last_ate >= TIOCE_NUM_M3240_ATES)
+		last_ate = TIOCE_NUM_M3240_ATES - 1;
 
 	while (ate_index <= last_ate) {
 		u64 ate;

diff-tree 1df57c0c21c92a6d4fcfe5304c84151ed9beb7a2 (from dd4cb9f8ac9717c9db2b2afc5a82cb95a3d5dec3)
Author: Cliff Wickman <cpw@sgi.com>
Date:   Tue Apr 25 10:47:48 2006 -0500

    [IA64] enable dumps to capture second page of kernel stack
    
    In SLES10 (2.6.16) crash dumping (in my experience, LKCD) is unable to
    capture the second page of the 2-page task/stack allocation.
    This is particularly troublesome for dump analysis, as the stack traceback
    cannot be done.
      (A similar convention is probably needed throughout the kernel to make
       kernel multi-page allocations detectable for dumping)
    
    Multi-page kernel allocations are represented by the single page structure
    associated with the first page of the allocation.  The page structures
    associated with the other pages are unintialized.
    
    If the dumper is selecting only kernel pages it has no way to identify
    any but the first page of the allocation.
    
    The fix is to make the task/stack allocation a compound page.
    
    Signed-off-by: Cliff Wickman <cpw@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 56394a2..e5392c4 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -67,7 +67,7 @@ #define setup_thread_stack(p, org) \
 #define end_of_stack(p) (unsigned long *)((void *)(p) + IA64_RBS_OFFSET)
 
 #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
-#define alloc_task_struct()	((task_t *)__get_free_pages(GFP_KERNEL, KERNEL_STACK_SIZE_ORDER))
+#define alloc_task_struct()	((task_t *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
 #endif /* !__ASSEMBLY */

diff-tree dd4cb9f8ac9717c9db2b2afc5a82cb95a3d5dec3 (from f0fe253c4719faf76d40f581cdc0e8aef77273bb)
Author: Jack Steiner <steiner@sgi.com>
Date:   Sat Apr 22 09:37:19 2006 -0500

    [IA64-SGI] - Reduce overhead of reading sn_topology
    
    MPI programs using certain debug options have a long
    startup time. This was traced to a "vmalloc/vfree" in
    the code that reads /proc/sgi_sn/sn_topology. On large
    systems, vfree requires an IPI to all cpus to do TLB
    purging.
    
    Replace the vmalloc/vfree with kmalloc/kfree. Although
    the size of the structure being allocated is unknown, it
    will not not exceed 96 bytes.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 7ec65bc..739c948 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -493,7 +493,7 @@ static int sn_topology_show(struct seq_f
 		 * numalink ports
 		 */
 		sz = obj->ports * sizeof(struct sn_hwperf_port_info);
-		if ((ptdata = vmalloc(sz)) = NULL)
+		if ((ptdata = kmalloc(sz, GFP_KERNEL)) = NULL)
 			return -ENOMEM;
 		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
 				      SN_HWPERF_ENUM_PORTS, obj->id, sz,
@@ -541,7 +541,7 @@ static int sn_topology_show(struct seq_f
 				(SN_HWPERF_IS_NL3ROUTER(obj) ||
 				SN_HWPERF_IS_NL3ROUTER(p)) ?  "LLP3" : "LLP4");
 		}
-		vfree(ptdata);
+		kfree(ptdata);
 	}
 
 	return 0;

diff-tree f0fe253c4719faf76d40f581cdc0e8aef77273bb (from c1311af12c7ca176a790a911a3fb6fed1f3bb387)
Author: Jack Steiner <steiner@sgi.com>
Date:   Sat Apr 22 09:36:07 2006 -0500

    [IA64-SGI] - Fix discover of nearest cpu node to IO node
    
    Fix a bug that causes discovery of the nearest node/cpu to
    a TIO (IO node) to fail.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index d917afa..7ec65bc 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -284,6 +284,8 @@ static int sn_hwperf_get_nearest_node_ob
 	/* find nearest node with cpus and nearest memory */
 	for (router=NULL, j=0; j < op->ports; j++) {
 		dest = sn_hwperf_findobj_id(objbuf, nobj, ptdata[j].conn_id);
+		if (dest && SN_HWPERF_IS_ROUTER(dest))
+			router = dest;
 		if (!dest || SN_HWPERF_FOREIGN(dest) ||
 		    !SN_HWPERF_IS_NODE(dest) || SN_HWPERF_IS_IONODE(dest)) {
 			continue;
@@ -299,8 +301,6 @@ static int sn_hwperf_get_nearest_node_ob
 				*near_mem_node = c;
 			found_mem++;
 		}
-		if (SN_HWPERF_IS_ROUTER(dest))
-			router = dest;
 	}
 
 	if (router && (!found_cpu || !found_mem)) {
diff --git a/include/asm-ia64/sn/sn2/sn_hwperf.h b/include/asm-ia64/sn/sn2/sn_hwperf.h
index 291ef3d..e61ebac 100644
--- a/include/asm-ia64/sn/sn2/sn_hwperf.h
+++ b/include/asm-ia64/sn/sn2/sn_hwperf.h
@@ -45,8 +45,12 @@ #define sn_hwp_flags		f.b.flags
 #define SN_HWPERF_IS_NODE(x)		((x) && strstr((x)->name, "SHub"))
 #define SN_HWPERF_IS_NODE_SHUB2(x)	((x) && strstr((x)->name, "SHub 2."))
 #define SN_HWPERF_IS_IONODE(x)		((x) && strstr((x)->name, "TIO"))
-#define SN_HWPERF_IS_ROUTER(x)		((x) && strstr((x)->name, "Router"))
 #define SN_HWPERF_IS_NL3ROUTER(x)	((x) && strstr((x)->name, "NL3Router"))
+#define SN_HWPERF_IS_NL4ROUTER(x)	((x) && strstr((x)->name, "NL4Router"))
+#define SN_HWPERF_IS_OLDROUTER(x)	((x) && strstr((x)->name, "Router"))
+#define SN_HWPERF_IS_ROUTER(x)		(SN_HWPERF_IS_NL3ROUTER(x) || 		\
+					 	SN_HWPERF_IS_NL4ROUTER(x) || 	\
+					 	SN_HWPERF_IS_OLDROUTER(x))
 #define SN_HWPERF_FOREIGN(x)		((x) && !(x)->sn_hwp_this_part && !(x)->sn_hwp_is_shared)
 #define SN_HWPERF_SAME_OBJTYPE(x,y)	((SN_HWPERF_IS_NODE(x) && SN_HWPERF_IS_NODE(y)) ||\
 					(SN_HWPERF_IS_IONODE(x) && SN_HWPERF_IS_IONODE(y)) ||\

diff-tree c1311af12c7ca176a790a911a3fb6fed1f3bb387 (from e5ecc192dfc5e0b325dd8c99ce4c755714c9acbf)
Author: Brent Casavant <bcasavan@sgi.com>
Date:   Thu Apr 20 15:38:16 2006 -0500

    [IA64] IOC4 config option ordering
    
    SERIAL_SGI_IOC4 and BLK_DEV_SGIIOC4 depend upon SGI_IOC4, and
    SERIAL_SGI_IOC3 depends upon SGI_IOC3.  Currently the definitions
    are out of order in the config sequence.
    
    Fix by including drivers/sn/Kconfig immediately after SGI_SN,
    upon which SGI_IOC4 and SGI_IOC3 depend.
    
    Signed-off-by: Brent Casavant <bcasavan@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 9f40eef..0f3076a 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -413,6 +413,8 @@ config IA64_PALINFO
 config SGI_SN
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
 
+source "drivers/sn/Kconfig"
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 5c91d6a..aeb5ab2 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -68,8 +68,6 @@ source "drivers/leds/Kconfig"
 
 source "drivers/infiniband/Kconfig"
 
-source "drivers/sn/Kconfig"
-
 source "drivers/edac/Kconfig"
 
 source "drivers/rtc/Kconfig"

diff-tree e5ecc192dfc5e0b325dd8c99ce4c755714c9acbf (from a72391e42f0a13116995045b3d492d660f96697d)
Author: Christoph Lameter <clameter@sgi.com>
Date:   Thu Apr 13 18:23:53 2006 -0700

    [IA64] Setup an IA64 specific reclaim distance
    
    RECLAIM_DISTANCE is checked on bootup against the SLIT table distances.
    Zone reclaim is important for system that have higher latencies but not for
    systems that have multiple nodes on one motherboard and therefore low latencies.
    
    We found that on motherboard latencies are typically 1 to 1.4 of local memory
    access speed whereas multinode systems which benefit from zone reclaim have
    usually more than 1.5 times the latency of a local access.
    
    Set the reclaim distance for IA64 to 1.5 times.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
index 3ee19df..616b5ed 100644
--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -23,6 +23,11 @@ #ifdef CONFIG_NUMA
 #define PENALTY_FOR_NODE_WITH_CPUS 255
 
 /*
+ * Distance above which we begin to use zone reclaim
+ */
+#define RECLAIM_DISTANCE 15
+
+/*
  * Returns the number of the node containing CPU 'cpu'
  */
 #define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])

diff-tree a72391e42f0a13116995045b3d492d660f96697d (from ee6d4b6ef8df79893d6d4a653b16c99bdb6d2784)
Author: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date:   Thu Apr 20 18:49:48 2006 +0900

    [IA64] eliminate compile time warnings
    
    This patch removes following compile time warnings:
    
    drivers/pci/pci-sysfs.c: In function `pci_read_legacy_io':
    drivers/pci/pci-sysfs.c:257: warning: implicit declaration of function `ia64_pci_legacy_read'
    drivers/pci/pci-sysfs.c: In function `pci_write_legacy_io':
    drivers/pci/pci-sysfs.c:280: warning: implicit declaration of function `ia64_pci_legacy_write'
    
    It also fixes wrong definition of ia64_pci_legacy_write (type of `bus' is not
    `pci_dev', but `pci_bus').
    
    Signed-Off-By: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 9ba32b2..ab829a2 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -31,7 +31,6 @@ #include <asm/smp.h>
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
-
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
@@ -707,7 +706,7 @@ int ia64_pci_legacy_read(struct pci_bus 
  *
  * Simply writes @size bytes of @val to @port.
  */
-int ia64_pci_legacy_write(struct pci_dev *bus, u16 port, u32 val, u8 size)
+int ia64_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 {
 	int ret = size;
 
diff --git a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
index c3e4ed8..a9c995a 100644
--- a/include/asm-ia64/machvec.h
+++ b/include/asm-ia64/machvec.h
@@ -347,9 +347,11 @@ # define platform_pci_get_legacy_mem	ia6
 #endif
 #ifndef platform_pci_legacy_read
 # define platform_pci_legacy_read	ia64_pci_legacy_read
+extern int ia64_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size);
 #endif
 #ifndef platform_pci_legacy_write
 # define platform_pci_legacy_write	ia64_pci_legacy_write
+extern int ia64_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size);
 #endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb

diff-tree ee6d4b6ef8df79893d6d4a653b16c99bdb6d2784 (from 86db2f4239e2556cd37b853c2307aa9d43041458)
Author: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date:   Thu Apr 20 18:49:41 2006 +0900

    [IA64] eliminate compile time warnings
    
    This is a trivial patch to remove following compile time warning:
    
    arch/ia64/ia32/../../../fs/binfmt_elf.c:508: warning: 'randomize_stack_top' defined but not used
    
    Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
index 4e7a6a1..da03c06 100644
--- a/arch/ia64/ia32/binfmt_elf32.c
+++ b/arch/ia64/ia32/binfmt_elf32.c
@@ -35,6 +35,9 @@ extern void ia64_elf32_init (struct pt_r
 
 static void elf32_set_personality (void);
 
+static unsigned long __attribute ((unused))
+randomize_stack_top(unsigned long stack_top);
+
 #define setup_arg_pages(bprm,tos,exec)		ia32_setup_arg_pages(bprm,exec)
 #define elf_map				elf32_map
 

diff-tree 86db2f4239e2556cd37b853c2307aa9d43041458 (from 0d9adec525b87d8ab7e64efeabffb5b3f293056e)
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Thu Apr 20 17:05:43 2006 -0700

    [IA64-SGI] SN SAL call to inject memory errors
    
    The SGI Altix SAL provides an interface for modifying
    the ECC on memory to create memory errors.  The SAL call
    can be used to inject memory errors for testing MCA recovery
    code.
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
index 7ddce80..51aca02 100644
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -85,6 +85,7 @@ #define SN_SAL_IOIF_GET_PCI_TOPOLOGY		  
 
 #define  SN_SAL_GET_PROM_FEATURE_SET		   0x02000065
 #define  SN_SAL_SET_OS_FEATURE_SET		   0x02000066
+#define  SN_SAL_INJECT_ERROR			   0x02000067
 
 /*
  * Service-specific constants
@@ -1138,4 +1139,16 @@ ia64_sn_set_os_feature(int feature)
 	return rv.status;
 }
 
+static inline int
+sn_inject_error(u64 paddr, u64 *data, u64 *ecc)
+{
+	struct ia64_sal_retval ret_stuff;
+	unsigned long irq_flags;
+
+	local_irq_save(irq_flags);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_INJECT_ERROR, paddr, (u64)data,
+				(u64)ecc, 0, 0, 0, 0);
+	local_irq_restore(irq_flags);
+	return ret_stuff.status;
+}
 #endif /* _ASM_IA64_SN_SN_SAL_H */

diff-tree 0d9adec525b87d8ab7e64efeabffb5b3f293056e (from 308a878210cde6ab19df9f392c24db53ad6f56bf)
Author: Jack Steiner <steiner@sgi.com>
Date:   Tue Apr 18 15:00:45 2006 -0500

    [IA64] - Fix MAX_PXM_DOMAINS for systems with > 256 nodes
    
    Correctly size the PXM-related arrays for systems that have more than
    256 nodes.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
index d734585..09a5dd0 100644
--- a/include/asm-ia64/acpi.h
+++ b/include/asm-ia64/acpi.h
@@ -110,9 +110,8 @@ extern void prefill_possible_map(void);
 extern int additional_cpus;
 
 #ifdef CONFIG_ACPI_NUMA
-/* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
-#ifdef CONFIG_IA64_NR_NODES
-#define MAX_PXM_DOMAINS CONFIG_IA64_NR_NODES
+#if MAX_NUMNODES > 256
+#define MAX_PXM_DOMAINS MAX_NUMNODES
 #else
 #define MAX_PXM_DOMAINS (256)
 #endif

diff-tree 308a878210cde6ab19df9f392c24db53ad6f56bf (from cbf283c048798ada7e062892b21de85fb5727243)
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Tue Apr 18 11:26:34 2006 -0500

    [IA64] Remove unused variable in sn_sal.h
    
    cnodeid was being set but not used.  The dead code was
    left over from a previous version that grabbed a per node lock.
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
index bf4cc86..7ddce80 100644
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -8,7 +8,7 @@ #define _ASM_IA64_SN_SN_SAL_H
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -705,10 +705,8 @@ static inline int
 sn_change_memprotect(u64 paddr, u64 len, u64 perms, u64 *nasid_array)
 {
 	struct ia64_sal_retval ret_stuff;
-	int cnodeid;
 	unsigned long irq_flags;
 
-	cnodeid = nasid_to_cnodeid(get_node_number(paddr));
 	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
 				(u64)nasid_array, perms, 0, 0, 0);

diff-tree cbf283c048798ada7e062892b21de85fb5727243 (from c6180deb1da5d087341fb5a3c1a15e61492dcd6b)
Author: Jesper Juhl <jesper.juhl@gmail.com>
Date:   Thu Apr 20 10:11:09 2006 -0700

    [IA64] Remove redundant NULL checks before kfree
    
    Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index b47476d..e9b628b 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -305,13 +305,10 @@ static struct kobj_type cache_ktype_perc
 
 static void __cpuinit cpu_cache_sysfs_exit(unsigned int cpu)
 {
-	if (all_cpu_cache_info[cpu].cache_leaves) {
-		kfree(all_cpu_cache_info[cpu].cache_leaves);
-		all_cpu_cache_info[cpu].cache_leaves = NULL;
-	}
+	kfree(all_cpu_cache_info[cpu].cache_leaves);
+	all_cpu_cache_info[cpu].cache_leaves = NULL;
 	all_cpu_cache_info[cpu].num_cache_leaves = 0;
 	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
-
 	return;
 }
 
diff --git a/arch/ia64/sn/kernel/xpc_partition.c b/arch/ia64/sn/kernel/xpc_partition.c
index 9421142..2a89cfc 100644
--- a/arch/ia64/sn/kernel/xpc_partition.c
+++ b/arch/ia64/sn/kernel/xpc_partition.c
@@ -136,9 +136,7 @@ xpc_get_rsvd_page_pa(int nasid)
 		}
 
 		if (L1_CACHE_ALIGN(len) > buf_len) {
-			if (buf_base != NULL) {
-				kfree(buf_base);
-			}
+			kfree(buf_base);
 			buf_len = L1_CACHE_ALIGN(len);
 			buf = (u64) xpc_kmalloc_cacheline_aligned(buf_len,
 							GFP_KERNEL, &buf_base);
@@ -159,9 +157,7 @@ xpc_get_rsvd_page_pa(int nasid)
 		}
 	}
 
-	if (buf_base != NULL) {
-		kfree(buf_base);
-	}
+	kfree(buf_base);
 
 	if (status != SALRET_OK) {
 		rp_pa = 0;

diff-tree c6180deb1da5d087341fb5a3c1a15e61492dcd6b (from 402a26f0c040077ed6f941eefac5a6971f0d5f40)
Author: Luck, Tony <tony.luck@intel.com>
Date:   Tue Apr 18 21:14:22 2006 -0700

    [IA64] wire up compat_sys_adjtimex()
    
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/ia32/ia32_entry.S b/arch/ia64/ia32/ia32_entry.S
index 95fe044..a32cd59 100644
--- a/arch/ia64/ia32/ia32_entry.S
+++ b/arch/ia64/ia32/ia32_entry.S
@@ -334,7 +334,7 @@ ia32_syscall_table:
 	data8 sys_setdomainname
 	data8 sys32_newuname
 	data8 sys32_modify_ldt
-	data8 sys_ni_syscall	/* adjtimex */
+	data8 compat_sys_adjtimex
 	data8 sys32_mprotect	  /* 125 */
 	data8 compat_sys_sigprocmask
 	data8 sys_ni_syscall	/* create_module */
