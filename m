From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Feb 2006 00:56:51 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200602100056.k1A0upvK008724@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

New syscalls for ia64, plus four miscellaneous bug fixes.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/ia32/ia32_signal.c  |    1 +
 arch/ia64/kernel/entry.S      |   16 ++++++++++++++++
 arch/ia64/kernel/fsys.S       |   29 +++--------------------------
 arch/ia64/kernel/mca_drv.c    |    3 +++
 arch/ia64/sn/kernel/io_init.c |    8 ++++----
 arch/ia64/sn/kernel/irq.c     |    4 +++-
 include/asm-ia64/unistd.h     |   17 ++++++++++++++++-
 7 files changed, 46 insertions(+), 32 deletions(-)

Chen, Kenneth W:
      [IA64] add syscall entry for *at()

Hidetoshi Seto:
      [IA64] mca_drv: Add minstate validation

Janak Desai:
      [IA64] unshare system call registration for ia64

Prarit Bhargava:
      [IA64-SGI] Hotplug driver related fix in the SN ia64 code.
      [IA64-SGI] Small cleanup for misuse of list_for_each to list_for_each_safe.

Tony Luck:
      [IA64] sys32_signal() forgets to initialize ->sa_mask


diff-tree a94746461765dae41fb82e4dac027d14af4d80d8 (from 1ff0be1534839dabec85f6d16dc36734f4e158bf)
Author: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date:   Thu Feb 9 14:42:55 2006 -0800

    [IA64] mca_drv: Add minstate validation
    
    MCA driver can cause panic if kernel gets a state info with no minstate.
    This patch adds minstate validation before handling it.
    
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 3492e32..8fd93af 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -437,6 +437,9 @@ recover_from_read_error(slidx_table_t *s
 	 *    the process not have any locks of kernel.
 	 */
 
+	/* Is minstate valid? */
+	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
+		return 0;
 	psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
 
 	/*

diff-tree 1ff0be1534839dabec85f6d16dc36734f4e158bf (from b6bb761897d3b0225fa9d61fc4782b02bab9a6e1)
Author: Tony Luck <tony.luck@intel.com>
Date:   Thu Feb 9 14:41:41 2006 -0800

    [IA64] sys32_signal() forgets to initialize ->sa_mask
    
    Pointed out by Oleg Nesterov <oleg@tv-sign.ru>, who in turn
    got the hint from Linus.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/ia32/ia32_signal.c b/arch/ia64/ia32/ia32_signal.c
index 5856510..b3355a9 100644
--- a/arch/ia64/ia32/ia32_signal.c
+++ b/arch/ia64/ia32/ia32_signal.c
@@ -515,6 +515,7 @@ sys32_signal (int sig, unsigned int hand
 
 	sigact_set_handler(&new_sa, handler, 0);
 	new_sa.sa.sa_flags = SA_ONESHOT | SA_NOMASK;
+	sigemptyset(&new_sa.sa.sa_mask);
 
 	ret = do_sigaction(sig, &new_sa, &old_sa);
 

diff-tree b6bb761897d3b0225fa9d61fc4782b02bab9a6e1 (from 8b34ff427d6f3b0a1207829350b9db16376f88c5)
Author: Prarit Bhargava <prarit@sgi.com>
Date:   Thu Feb 9 14:14:52 2006 -0800

    [IA64-SGI] Small cleanup for misuse of list_for_each to list_for_each_safe.
    
    Patch was suggested by Kenneth W. Chen here
    
    Signed-off-by: Prarit Bhargava <prarit@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 2e4e56b..3437c23 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -617,17 +617,15 @@ void sn_bus_store_sysdata(struct pci_dev
 void sn_bus_free_sysdata(void)
 {
 	struct sysdata_el *element;
-	struct list_head *list;
+	struct list_head *list, *safe;
 
-sn_sysdata_free_start:
-	list_for_each(list, &sn_sysdata_list) {
+	list_for_each_safe(list, safe, &sn_sysdata_list) {
 		element = list_entry(list, struct sysdata_el, entry);
 		list_del(&element->entry);
 		list_del(&(((struct pcidev_info *)
 			     (element->sysdata))->pdi_list));
 		kfree(element->sysdata);
 		kfree(element);
-		goto sn_sysdata_free_start;
 	}
 	return;
 }

diff-tree 8b34ff427d6f3b0a1207829350b9db16376f88c5 (from 0bdd340c092b0936f78a54bdbd3927463ed4fca3)
Author: Prarit Bhargava <prarit@sgi.com>
Date:   Thu Feb 9 14:12:24 2006 -0800

    [IA64-SGI] Hotplug driver related fix in the SN ia64 code.
    
    Remove an erroneous kfree, and unlink the pcidev_info struct from the
    pcidev_info list prior to free'ing the pcidev_info struct.
    
    Signed-off-by: Prarit Bhargava <prarit@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index d7e4d79..2e4e56b 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -623,6 +623,8 @@ sn_sysdata_free_start:
 	list_for_each(list, &sn_sysdata_list) {
 		element = list_entry(list, struct sysdata_el, entry);
 		list_del(&element->entry);
+		list_del(&(((struct pcidev_info *)
+			     (element->sysdata))->pdi_list));
 		kfree(element->sysdata);
 		kfree(element);
 		goto sn_sysdata_free_start;
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 74d87d9..c373113 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -299,7 +299,9 @@ void sn_irq_unfixup(struct pci_dev *pci_
 		return;
 
 	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
-	if (!sn_irq_info || !sn_irq_info->irq_irq) {
+	if (!sn_irq_info)
+		return;
+	if (!sn_irq_info->irq_irq) {
 		kfree(sn_irq_info);
 		return;
 	}

diff-tree 9621a4ef8a29d11118f44def053931bcafb0dfc2 (from 9ed2ad8648eb974ee670045d41b5a51b763e3aa1)
Author: Janak Desai <janak@us.ibm.com>
Date:   Wed Feb 8 15:43:38 2006 -0800

    [IA64] unshare system call registration for ia64
    
    Registers system call for the ia64 architecture.
    
    Reserves space for ppoll and pselect, and adds unshare at system
    call number 1296.
    
    Signed-off-by: Janak Desai <janak@us.ibm.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 6b88de8..27b222c 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1614,5 +1614,8 @@ sys_call_table:
 	data8 sys_readlinkat
 	data8 sys_fchmodat
 	data8 sys_faccessat
+	data8 sys_ni_syscall			// reserved for pselect
+	data8 sys_ni_syscall			// 1295 reserved for ppoll
+	data8 sys_unshare
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
index a151eb1..019956c 100644
--- a/include/asm-ia64/unistd.h
+++ b/include/asm-ia64/unistd.h
@@ -283,12 +283,14 @@
 #define __NR_readlinkat			1291
 #define __NR_fchmodat			1292
 #define __NR_faccessat			1293
+/* 1294, 1295 reserved for pselect/ppoll */
+#define __NR_unshare			1296
 
 #ifdef __KERNEL__
 
 #include <linux/config.h>
 
-#define NR_syscalls			270 /* length of syscall table */
+#define NR_syscalls			273 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 

diff-tree 9ed2ad8648eb974ee670045d41b5a51b763e3aa1 (from e3f749c4af69c4344d89f11e2293e3790eb4eaca)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Tue Jan 31 14:26:25 2006 -0800

    [IA64] add syscall entry for *at()
    
    Wire up the ia64 syscalls for *at() functions.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 7a6ffd6..6b88de8 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1601,5 +1601,18 @@ sys_call_table:
 	data8 sys_inotify_add_watch
 	data8 sys_inotify_rm_watch
 	data8 sys_migrate_pages			// 1280
+	data8 sys_openat
+	data8 sys_mkdirat
+	data8 sys_mknodat
+	data8 sys_fchownat
+	data8 sys_futimesat			// 1285
+	data8 sys_newfstatat
+	data8 sys_unlinkat
+	data8 sys_renameat
+	data8 sys_linkat
+	data8 sys_symlinkat			// 1290
+	data8 sys_readlinkat
+	data8 sys_fchmodat
+	data8 sys_faccessat
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index ce42391..ac6055c 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -878,31 +878,8 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
-	data8 0				// clock_getres		// 1255
-	data8 0				// clock_nanosleep
-	data8 0				// fstatfs64
-	data8 0				// statfs64
-	data8 0
-	data8 0							// 1260
-	data8 0
-	data8 0				// mq_open
-	data8 0				// mq_unlink
-	data8 0				// mq_timedsend
-	data8 0				// mq_timedreceive	// 1265
-	data8 0				// mq_notify
-	data8 0				// mq_getsetattr
-	data8 0				// kexec_load
-	data8 0
-	data8 0							// 1270
-	data8 0
-	data8 0
-	data8 0
-	data8 0
-	data8 0							// 1275
-	data8 0
-	data8 0
-	data8 0
-	data8 0
-	data8 0							// 1280
+	#define __NR_syscall_last	1255
+
+	.space 8*(NR_syscalls + 1024 - __NR_syscall_last), 0
 
 	.org fsyscall_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
index 962f9bd..a151eb1 100644
--- a/include/asm-ia64/unistd.h
+++ b/include/asm-ia64/unistd.h
@@ -270,6 +270,19 @@
 #define __NR_inotify_add_watch		1278
 #define __NR_inotify_rm_watch		1279
 #define __NR_migrate_pages		1280
+#define __NR_openat			1281
+#define __NR_mkdirat			1282
+#define __NR_mknodat			1283
+#define __NR_fchownat			1284
+#define __NR_futimesat			1285
+#define __NR_newfstatat			1286
+#define __NR_unlinkat			1287
+#define __NR_renameat			1288
+#define __NR_linkat			1289
+#define __NR_symlinkat			1290
+#define __NR_readlinkat			1291
+#define __NR_fchmodat			1292
+#define __NR_faccessat			1293
 
 #ifdef __KERNEL__
 
