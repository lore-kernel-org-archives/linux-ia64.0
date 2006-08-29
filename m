From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Aug 2006 17:39:42 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200608291739.k7THdgBa010717@agluck-lia64.sc.intel.com>
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

 arch/ia64/Kconfig                   |    4 ++--
 arch/ia64/kernel/topology.c         |    6 ++----
 arch/ia64/sn/kernel/xpc_channel.c   |    4 ++--
 arch/ia64/sn/kernel/xpc_main.c      |   28 ++++++++++++++++------------
 arch/ia64/sn/kernel/xpc_partition.c |   24 ++++++++----------------
 include/asm-ia64/sn/sn_sal.h        |    6 ------
 include/asm-ia64/sn/xp.h            |   22 ++++++++++++++++++----
 include/asm-ia64/sn/xpc.h           |    4 +++-
 8 files changed, 51 insertions(+), 47 deletions(-)

Christoph Lameter:
      [IA64] Increase default nodes shift to 10, nr_cpus to 1024

Dean Nelson:
      [IA64-SGI] Silent data corruption caused by XPC V2.

Paul Jackson:
      [IA64] panic if topology_init kzalloc fails

Russ Anderson:
      [IA64] remove redundant local_irq_save() calls from sn_sal.h

== Full git whatchanged -p output showing diffs =
commit c57d68caeed7bc335e6d35c951a9abae733a580b
Author: Christoph Lameter <clameter@sgi.com>
Date:   Tue Aug 22 19:43:27 2006 -0700

    [IA64] Increase default nodes shift to 10, nr_cpus to 1024
    
    Change both the NODES_SHIFT and the NR_CPUS so that even big machines
    can boot all nodes and processors with a generic kernel.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 47de9ee..674de89 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -258,7 +258,7 @@ config NR_CPUS
 	int "Maximum number of CPUs (2-1024)"
 	range 2 1024
 	depends on SMP
-	default "64"
+	default "1024"
 	help
 	  You should set this to the number of CPUs in your system, but
 	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
@@ -354,7 +354,7 @@ config NUMA
 config NODES_SHIFT
 	int "Max num nodes shift(3-10)"
 	range 3 10
-	default "8"
+	default "10"
 	depends on NEED_MULTIPLE_NODES
 	help
 	  This option specifies the maximum number of nodes in your SSI system.

commit 986e12fa74c837d7fe5bdfe80666e2e2d46711bd
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Thu Aug 24 11:08:52 2006 -0500

    [IA64] remove redundant local_irq_save() calls from sn_sal.h
    
    sn_change_memprotect() does a local_irq_save() then calls
    ia64_sal_oemcall_nolock() which calls SAL_CALL_NOLOCK()
    which also does a local_irq_save().
    
    This patch removes the redundant local_irq_save() and local_irq_restore()
    calls in sn_change_memprotect() and sn_inject_error().
    
    Signed-off-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
index bd4452b..ba826b3 100644
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -706,12 +706,9 @@ static inline int
 sn_change_memprotect(u64 paddr, u64 len, u64 perms, u64 *nasid_array)
 {
 	struct ia64_sal_retval ret_stuff;
-	unsigned long irq_flags;
 
-	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
 				(u64)nasid_array, perms, 0, 0, 0);
-	local_irq_restore(irq_flags);
 	return ret_stuff.status;
 }
 #define SN_MEMPROT_ACCESS_CLASS_0		0x14a080
@@ -1143,12 +1140,9 @@ static inline int
 sn_inject_error(u64 paddr, u64 *data, u64 *ecc)
 {
 	struct ia64_sal_retval ret_stuff;
-	unsigned long irq_flags;
 
-	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_INJECT_ERROR, paddr, (u64)data,
 				(u64)ecc, 0, 0, 0, 0);
-	local_irq_restore(irq_flags);
 	return ret_stuff.status;
 }
 

commit a813213d73bb29d6986c3e93669a9cd5f7984364
Author: Paul Jackson <pj@sgi.com>
Date:   Mon Aug 14 22:45:49 2006 -0700

    [IA64] panic if topology_init kzalloc fails
    
    There really is no sense trying to continue if the kzalloc of sysfs_cpus[]
    fails in ia64 topology_init.  The code calling into here doesn't check
    errors very well, and one ends up with a nonobvious boot failure that
    wastes peoples time debugging.
    
    See for example the lkml thread at:
      http://lkml.org/lkml/2006/3/2/215
    
    Since the system is totally dead when this kzalloc fails, not having yet
    even booted, might as well announce one's death boldly and plainly.
    
    Signed-off-by: Paul Jackson <pj@sgi.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index d24fa39..f648c61 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -67,10 +67,8 @@ #ifdef CONFIG_NUMA
 #endif
 
 	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
-	if (!sysfs_cpus) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!sysfs_cpus)
+		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 
 	for_each_present_cpu(i) {
 		if((err = arch_register_cpu(i)))

commit 7682a4c624e0011b5f3e8dd3021dc54961260d97
Author: Dean Nelson <dcn@sgi.com>
Date:   Tue Aug 8 15:03:29 2006 -0500

    [IA64-SGI] Silent data corruption caused by XPC V2.
    
    Jack Steiner identified a problem where XPC can cause a silent
    data corruption.  On module load, the placement may cause the
    xpc_remote_copy_buffer to span two physical pages.  DMA transfers are
    done to the start virtual address translated to physical.
    
    This patch changes the buffer from a statically allocated buffer to a
    kmalloc'd buffer.  Dean Nelson reviewed this before posting.  I have
    tested it in the configuration that was showing the memory corruption
    and verified it works.  I also added a BUG_ON statement to help catch
    this if a similar situation is encountered.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index c2f69f7..1f35408 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -279,8 +279,8 @@ xpc_pull_remote_cachelines(struct xpc_pa
 		return part->reason;
 	}
 
-	bte_ret = xp_bte_copy((u64) src, (u64) ia64_tpa((u64) dst),
-				(u64) cnt, (BTE_NORMAL | BTE_WACQUIRE), NULL);
+	bte_ret = xp_bte_copy((u64) src, (u64) dst, (u64) cnt,
+					(BTE_NORMAL | BTE_WACQUIRE), NULL);
 	if (bte_ret = BTE_SUCCESS) {
 		return xpcSuccess;
 	}
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index 5e8e59e..4d026f9 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -1052,6 +1052,8 @@ xpc_do_exit(enum xpc_retval reason)
 	if (xpc_sysctl) {
 		unregister_sysctl_table(xpc_sysctl);
 	}
+
+	kfree(xpc_remote_copy_buffer_base);
 }
 
 
@@ -1212,24 +1214,20 @@ xpc_init(void)
 	partid_t partid;
 	struct xpc_partition *part;
 	pid_t pid;
+	size_t buf_size;
 
 
 	if (!ia64_platform_is("sn2")) {
 		return -ENODEV;
 	}
 
-	/*
-	 * xpc_remote_copy_buffer is used as a temporary buffer for bte_copy'ng
-	 * various portions of a partition's reserved page. Its size is based
-	 * on the size of the reserved page header and part_nasids mask. So we
-	 * need to ensure that the other items will fit as well.
-	 */
-	if (XPC_RP_VARS_SIZE > XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES) {
-		dev_err(xpc_part, "xpc_remote_copy_buffer is not big enough\n");
-		return -EPERM;
-	}
-	DBUG_ON((u64) xpc_remote_copy_buffer !-				L1_CACHE_ALIGN((u64) xpc_remote_copy_buffer));
+
+	buf_size = max(XPC_RP_VARS_SIZE,
+				XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
+	xpc_remote_copy_buffer = xpc_kmalloc_cacheline_aligned(buf_size,
+				     GFP_KERNEL, &xpc_remote_copy_buffer_base);
+	if (xpc_remote_copy_buffer = NULL)
+		return -ENOMEM;
 
 	snprintf(xpc_part->bus_id, BUS_ID_SIZE, "part");
 	snprintf(xpc_chan->bus_id, BUS_ID_SIZE, "chan");
@@ -1293,6 +1291,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1311,6 +1311,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1362,6 +1364,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
diff --git a/arch/ia64/sn/kernel/xpc_partition.c b/arch/ia64/sn/kernel/xpc_partition.c
index 2a89cfc..57c723f 100644
--- a/arch/ia64/sn/kernel/xpc_partition.c
+++ b/arch/ia64/sn/kernel/xpc_partition.c
@@ -71,19 +71,15 @@ struct xpc_partition xpc_partitions[XP_M
  * Generic buffer used to store a local copy of portions of a remote
  * partition's reserved page (either its header and part_nasids mask,
  * or its vars).
- *
- * xpc_discovery runs only once and is a seperate thread that is
- * very likely going to be processing in parallel with receiving
- * interrupts.
  */
-char ____cacheline_aligned xpc_remote_copy_buffer[XPC_RP_HEADER_SIZE +
-							XP_NASID_MASK_BYTES];
+char *xpc_remote_copy_buffer;
+void *xpc_remote_copy_buffer_base;
 
 
 /*
  * Guarantee that the kmalloc'd memory is cacheline aligned.
  */
-static void *
+void *
 xpc_kmalloc_cacheline_aligned(size_t size, gfp_t flags, void **base)
 {
 	/* see if kmalloc will give us cachline aligned memory by default */
@@ -148,7 +144,7 @@ xpc_get_rsvd_page_pa(int nasid)
 			}
 		}
 
-		bte_res = xp_bte_copy(rp_pa, ia64_tpa(buf), buf_len,
+		bte_res = xp_bte_copy(rp_pa, buf, buf_len,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bte_res != BTE_SUCCESS) {
 			dev_dbg(xpc_part, "xp_bte_copy failed %i\n", bte_res);
@@ -447,7 +443,7 @@ xpc_check_remote_hb(void)
 
 		/* pull the remote_hb cache line */
 		bres = xp_bte_copy(part->remote_vars_pa,
-					ia64_tpa((u64) remote_vars),
+					(u64) remote_vars,
 					XPC_RP_VARS_SIZE,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bres != BTE_SUCCESS) {
@@ -498,8 +494,7 @@ xpc_get_remote_rp(int nasid, u64 *discov
 
 
 	/* pull over the reserved page header and part_nasids mask */
-
-	bres = xp_bte_copy(*remote_rp_pa, ia64_tpa((u64) remote_rp),
+	bres = xp_bte_copy(*remote_rp_pa, (u64) remote_rp,
 				XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
@@ -554,11 +549,8 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 		return xpcVarsNotSet;
 	}
 
-
 	/* pull over the cross partition variables */
-
-	bres = xp_bte_copy(remote_vars_pa, ia64_tpa((u64) remote_vars),
-				XPC_RP_VARS_SIZE,
+	bres = xp_bte_copy(remote_vars_pa, (u64) remote_vars, XPC_RP_VARS_SIZE,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
@@ -1239,7 +1231,7 @@ xpc_initiate_partid_to_nasids(partid_t p
 
 	part_nasid_pa = (u64) XPC_RP_PART_NASIDS(part->remote_rp_pa);
 
-	bte_res = xp_bte_copy(part_nasid_pa, ia64_tpa((u64) nasid_mask),
+	bte_res = xp_bte_copy(part_nasid_pa, (u64) nasid_mask,
 			xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 
 	return xpc_map_bte_errors(bte_res);
diff --git a/include/asm-ia64/sn/xp.h b/include/asm-ia64/sn/xp.h
index 9bd2f9b..6f807e0 100644
--- a/include/asm-ia64/sn/xp.h
+++ b/include/asm-ia64/sn/xp.h
@@ -60,23 +60,37 @@ #define XP_NASID_MASK_WORDS	((XP_MAX_PHY
  * the bte_copy() once in the hope that the failure was due to a temporary
  * aberration (i.e., the link going down temporarily).
  *
- * See bte_copy for definition of the input parameters.
+ * 	src - physical address of the source of the transfer.
+ *	vdst - virtual address of the destination of the transfer.
+ *	len - number of bytes to transfer from source to destination.
+ *	mode - see bte_copy() for definition.
+ *	notification - see bte_copy() for definition.
  *
  * Note: xp_bte_copy() should never be called while holding a spinlock.
  */
 static inline bte_result_t
-xp_bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
+xp_bte_copy(u64 src, u64 vdst, u64 len, u64 mode, void *notification)
 {
 	bte_result_t ret;
+	u64 pdst = ia64_tpa(vdst);
 
 
-	ret = bte_copy(src, dest, len, mode, notification);
+	/*
+	 * Ensure that the physically mapped memory is contiguous.
+	 *
+	 * We do this by ensuring that the memory is from region 7 only.
+	 * If the need should arise to use memory from one of the other
+	 * regions, then modify the BUG_ON() statement to ensure that the
+	 * memory from that region is always physically contiguous.
+	 */
+	BUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL);
 
+	ret = bte_copy(src, pdst, len, mode, notification);
 	if (ret != BTE_SUCCESS) {
 		if (!in_interrupt()) {
 			cond_resched();
 		}
-		ret = bte_copy(src, dest, len, mode, notification);
+		ret = bte_copy(src, pdst, len, mode, notification);
 	}
 
 	return ret;
diff --git a/include/asm-ia64/sn/xpc.h b/include/asm-ia64/sn/xpc.h
index b72af59..35e1386 100644
--- a/include/asm-ia64/sn/xpc.h
+++ b/include/asm-ia64/sn/xpc.h
@@ -683,7 +683,9 @@ extern struct xpc_vars *xpc_vars;
 extern struct xpc_rsvd_page *xpc_rsvd_page;
 extern struct xpc_vars_part *xpc_vars_part;
 extern struct xpc_partition xpc_partitions[XP_MAX_PARTITIONS + 1];
-extern char xpc_remote_copy_buffer[];
+extern char *xpc_remote_copy_buffer;
+extern void *xpc_remote_copy_buffer_base;
+extern void *xpc_kmalloc_cacheline_aligned(size_t, gfp_t, void **);
 extern struct xpc_rsvd_page *xpc_rsvd_page_init(void);
 extern void xpc_allow_IPI_ops(void);
 extern void xpc_restrict_IPI_ops(void);
