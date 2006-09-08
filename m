From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Sep 2006 19:11:12 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200609081911.k88JBCan011197@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/entry.S    |    4 ++--
 arch/ia64/kernel/head.S     |    5 +++++
 arch/ia64/kernel/perfmon.c  |    4 +++-
 arch/ia64/sn/kernel/setup.c |    2 +-
 include/asm-ia64/unistd.h   |    3 +--
 5 files changed, 12 insertions(+), 6 deletions(-)

Andreas Schwab:
      [IA64] Unwire set/get_robust_list

Jack Steiner:
      [IA64] Save register stack contents on cpu start
      [IA64] SN fix for cpu hotplug/kexec

Stephane Eranian:
      [IA64] correct file descriptor reference counting in perfmon

--- full git whatchanged -p output follows ---

commit 38f5745c5a90641079fd5b48600ae63f7ab6edcd
Author: Jack Steiner <steiner@sgi.com>
Date:   Thu Aug 31 11:35:57 2006 -0500

    [IA64] SN fix for cpu hotplug/kexec
    
    The sn_cpu_init() is required for cpu initialization on SN platforms.
    Change __init to __cpuinit so that the function is not freed with init code/data.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index c119e8b..5f2dcba 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -565,7 +565,7 @@ static void __init sn_init_pdas(char **c
  * Also sets up a few fields in the nodepda.  Also known as
  * platform_cpu_init() by the ia64 machvec code.
  */
-void __init sn_cpu_init(void)
+void __cpuinit sn_cpu_init(void)
 {
 	int cpuid;
 	int cpuphyid;

commit 1c7d67073e2d196597f541351bc9b109c8a93528
Author: Jack Steiner <steiner@sgi.com>
Date:   Thu Aug 31 11:34:47 2006 -0500

    [IA64] Save register stack contents on cpu start
    
    The SN PROM uses the register stack in the slave loop. The contents
    must be preserved for the OS to return to the slave loop via offlining
    a cpu or for kexec. A 'flushrs" is needed to force the stack to be written
    to memory prior to changing bspstore.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 29236f0..44d540e 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -197,6 +197,11 @@ start_ap:
 	;;
 	srlz.i
 	;;
+ {
+	flushrs				// must be first insn in group
+	srlz.i
+ }
+	;;
 	/*
 	 * Save the region registers, predicate before they get clobbered
 	 */

commit 2636255488484e04d6d54303d2b0ec30f7ef7e02
Author: Andreas Schwab <schwab@suse.de>
Date:   Mon Sep 4 21:56:09 2006 +0200

    [IA64] Unwire set/get_robust_list
    
    The syscalls set/get_robust_list must not be wired up until
    futex_atomic_cmpxchg_inatomic is implemented.  Otherwise the kernel will
    hang in handle_futex_death.
    
    Signed-off-by: Andreas Schwab <schwab@suse.de>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 12701cf..fef0657 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1605,8 +1605,8 @@ sys_call_table:
 	data8 sys_ni_syscall			// 1295 reserved for ppoll
 	data8 sys_unshare
 	data8 sys_splice
-	data8 sys_set_robust_list
-	data8 sys_get_robust_list
+	data8 sys_ni_syscall			// reserved for set_robust_list
+	data8 sys_ni_syscall			// reserved for get_robust_list
 	data8 sys_sync_file_range		// 1300
 	data8 sys_tee
 	data8 sys_vmsplice
diff --git a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
index bb0eb72..f581662 100644
--- a/include/asm-ia64/unistd.h
+++ b/include/asm-ia64/unistd.h
@@ -286,8 +286,7 @@ #define __NR_faccessat			1293
 /* 1294, 1295 reserved for pselect/ppoll */
 #define __NR_unshare			1296
 #define __NR_splice			1297
-#define __NR_set_robust_list		1298
-#define __NR_get_robust_list		1299
+/* 1298, 1299 reserved for set_robust_list/get_robust_list */
 #define __NR_sync_file_range		1300
 #define __NR_tee			1301
 #define __NR_vmsplice			1302

commit b8444d00762703e1b6146fce12ce2684885f8bf6
Author: Stephane Eranian <eranian@hpl.hp.com>
Date:   Fri Aug 25 14:00:19 2006 -0700

    [IA64] correct file descriptor reference counting in perfmon
    
    Fix a bug in sys_perfmonctl() whereby it was not correctly
    decrementing the file descriptor reference count.
    
    Signed-off-by: stephane eranian <eranian@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index c7ccd6e..84a7e52 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4936,13 +4936,15 @@ abort_locked:
 	if (likely(ctx)) {
 		DPRINT(("context unlocked\n"));
 		UNPROTECT_CTX(ctx, flags);
-		fput(file);
 	}
 
 	/* copy argument back to user, if needed */
 	if (call_made && PFM_CMD_RW_ARG(cmd) && copy_to_user(arg, args_k, base_sz*count)) ret = -EFAULT;
 
 error_args:
+	if (file)
+		fput(file);
+
 	kfree(args_k);
 
 	DPRINT(("cmd=%s ret=%ld\n", PFM_CMD_NAME(cmd), ret));
