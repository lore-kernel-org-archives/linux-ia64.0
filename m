From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 28 Feb 2006 19:03:45 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200602281903.k1SJ3jn3013459@agluck-lia64.sc.intel.com>
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

This will update the files shown below.  I didn't include the diffs for the
refresh of the config files.  Most of the rest are 1-2 line bugfixes and
cleanups ... the only new thing is the ia64-specific sysctl change by Jes
to end the long raging disagreement about the kernel printing warnings when
user applications access unaligned objects in memory (default is to still
print them, but this provides an option to turn the warnings off).

Thanks!

-Tony

 Documentation/kernel-parameters.txt   |    2 
 arch/ia64/configs/bigsur_defconfig    |  161 +++++++++-----
 arch/ia64/configs/gensparse_defconfig |  161 ++++++++++----
 arch/ia64/configs/sim_defconfig       |  371 +++++++++++++++++++++++++---------
 arch/ia64/configs/sn2_defconfig       |   58 +++--
 arch/ia64/configs/tiger_defconfig     |   57 +++--
 arch/ia64/configs/zx1_defconfig       |  192 +++++++++++------
 arch/ia64/defconfig                   |  177 +++++++++++-----
 arch/ia64/kernel/fsys.S               |    7 
 arch/ia64/kernel/ivt.S                |    1 
 arch/ia64/kernel/unaligned.c          |   33 ++-
 arch/ia64/pci/pci.c                   |    2 
 arch/ia64/sn/kernel/io_init.c         |    1 
 drivers/sn/Kconfig                    |    4 
 include/asm-ia64/sn/arch.h            |    3 
 include/linux/sysctl.h                |    1 
 kernel/sysctl.c                       |   14 +
 17 files changed, 880 insertions(+), 365 deletions(-)

Christoph Hellwig:
      [IA64-SGI] revert export sn_pcidev_info_get

Horms:
      [IA64] Document the "nomca" boot parameter

Jack Steiner:
      [IA64-SGI] Make number of TIO nodes configurable

Jes Sorensen:
      [IA64] show "SN Devices" menu only if CONFIG_SGI_SN
      [IA64] sysctl option to silence unaligned trap warnings

Ken Chen:
      [IA64] cleanup in fsys.S

Matthew Wilcox:
      [IA64] Fix pcibios_setup

Tony Luck:
      [IA64] die_if_kernel() can return
      [IA64] refresh default config files

Zhang, Yanmin:
      [IA64] Delete a redundant instruction in unaligned_access

diff-tree d2b176ed878d4d5fcc0bd35656dfd373f3702af9 (from c8c1635faa7c97329111ce32b927d37306521822)
Author: Jes Sorensen <jes@sgi.com>
Date:   Tue Feb 28 09:42:23 2006 -0800

    [IA64] sysctl option to silence unaligned trap warnings
    
    Allow sysadmin to disable all warnings about userland apps
    making unaligned accesses by using:
     # echo 1 > /proc/sys/kernel/ignore-unaligned-usertrap
    Rather than having to use prctl on a process by process basis.
    
    Default behaivour leaves the warnings enabled.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 1129138..1e35755 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -53,6 +53,15 @@ dump (const char *str, void *vp, size_t 
 #define SIGN_EXT9		0xffffffffffffff00ul
 
 /*
+ *  sysctl settable hook which tells the kernel whether to honor the
+ *  IA64_THREAD_UAC_NOPRINT prctl.  Because this is user settable, we want
+ *  to allow the super user to enable/disable this for security reasons
+ *  (i.e. don't allow attacker to fill up logs with unaligned accesses).
+ */
+int no_unaligned_warning;
+static int noprint_warning;
+
+/*
  * For M-unit:
  *
  *  opcode |   m  |   x6    |
@@ -1324,8 +1333,9 @@ ia64_handle_unaligned (unsigned long ifa
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) != 0)
 			goto force_sigbus;
 
-		if (!(current->thread.flags & IA64_THREAD_UAC_NOPRINT)
-		    && within_logging_rate_limit())
+		if (!no_unaligned_warning &&
+		    !(current->thread.flags & IA64_THREAD_UAC_NOPRINT) &&
+		    within_logging_rate_limit())
 		{
 			char buf[200];	/* comm[] is at most 16 bytes... */
 			size_t len;
@@ -1340,7 +1350,22 @@ ia64_handle_unaligned (unsigned long ifa
 			if (user_mode(regs))
 				tty_write_message(current->signal->tty, buf);
 			buf[len-1] = '\0';	/* drop '\r' */
-			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %s */
+			/* watch for command names containing %s */
+			printk(KERN_WARNING "%s", buf);
+		} else {
+			if (no_unaligned_warning && !noprint_warning) {
+				noprint_warning = 1;
+				printk(KERN_WARNING "%s(%d) encountered an "
+				       "unaligned exception which required\n"
+				       "kernel assistance, which degrades "
+				       "the performance of the application.\n"
+				       "Unaligned exception warnings have "
+				       "been disabled by the system "
+				       "administrator\n"
+				       "echo 0 > /proc/sys/kernel/ignore-"
+				       "unaligned-usertrap to re-enable\n",
+				       current->comm, current->pid);
+			}
 		}
 	} else {
 		if (within_logging_rate_limit())
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 0e92bf7..bac61db 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -147,6 +147,7 @@ enum
 	KERN_SETUID_DUMPABLEi, /* int: behaviour of dumps for setuid core */
 	KERN_SPIN_RETRYp,	/* int: number of spinlock retries */
 	KERN_ACPI_VIDEO_FLAGSq, /* int: flags for setting up video after ACPI sleep */
+	KERN_IA64_UNALIGNEDr, /* int: ia64 unaligned userland trap enable */
 };
 
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c05a2b7..acf6c15 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -124,6 +124,10 @@ extern int sysctl_hz_timer;
 extern int acct_parm[];
 #endif
 
+#ifdef CONFIG_IA64
+extern int no_unaligned_warning;
+#endif
+
 static int parse_table(int __user *, int, void __user *, size_t __user *, void __user *, size_t,
 		       ctl_table *, void **);
 static int proc_doutsstring(ctl_table *table, int write, struct file *filp,
@@ -666,6 +670,16 @@ static ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_IA64
+	{
+		.ctl_name	= KERN_IA64_UNALIGNED,
+		.procname	= "ignore-unaligned-usertrap",
+		.data		= &no_unaligned_warning,
+		.maxlen		= sizeof (int),
+	 	.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 

diff-tree c8c1635faa7c97329111ce32b927d37306521822 (from 9fe26a74f1e355dd707f09f9e5e9f035bcc6bae2)
Author: Ken Chen <kenneth.w.chen@intel.com>
Date:   Tue Feb 28 08:53:32 2006 -0800

    [IA64] cleanup in fsys.S
    
    beautify coding style for zeroing end of fsyscall_table entries.
    Remove misleading __NR_syscall_last and add more comments.
    Drop (now unneeded) "guard against failure to increase NR_syscalls"
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index ac6055c..7a05b1c 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -878,8 +878,7 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
-	#define __NR_syscall_last	1255
 
-	.space 8*(NR_syscalls + 1024 - __NR_syscall_last), 0
-
-	.org fsyscall_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
+	// fill in zeros for the remaining entries
+	.zero:
+	.space fsyscall_table + 8*NR_syscalls - .zero, 0

diff-tree e963701a761aede31c9c1bfc74cf8e0ec671f0f4 (from eb0911e27e8c6778d6c8ec95b7dd60c002d923c3)
Author: Tony Luck <tony.luck@intel.com>
Date:   Mon Feb 27 16:18:58 2006 -0800

    [IA64] die_if_kernel() can return
    
    arch/ia64/kernel/unaligned.c erroneously marked die_if_kernel()
    with a "noreturn" attribute ... which is silly (it returns whenever
    the argument regs say that the fault happened in user mode, as one
    might expect given the "if_kernel" part of its name!).  Thanks to
    Alan and Gareth for pointing this out.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index f9e0ae9..1129138 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -24,7 +24,7 @@
 #include <asm/uaccess.h>
 #include <asm/unaligned.h>
 
-extern void die_if_kernel(char *str, struct pt_regs *regs, long err) __attribute__ ((noreturn));
+extern void die_if_kernel(char *str, struct pt_regs *regs, long err);
 
 #undef DEBUG_UNALIGNED_TRAP
 

diff-tree eb0911e27e8c6778d6c8ec95b7dd60c002d923c3 (from ac311ac2b7caca000b1501fd24136bdca30e2a51)
Author: Christoph Hellwig <hch@infradead.org>
Date:   Tue Feb 21 10:48:41 2006 +0000

    [IA64-SGI] revert export sn_pcidev_info_get
    
    Christoph Hellwig <hch@infradead.org> pointed that there are no
    in-tree uses of this.  So revert 9c65cb9be62ac4993a5b392304b82e4f04f010fd
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 3edef0d..dfb3f29 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -716,4 +716,3 @@ EXPORT_SYMBOL(sn_pci_unfixup_slot);
 EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
-EXPORT_SYMBOL(sn_pcidev_info_get);

diff-tree ac311ac2b7caca000b1501fd24136bdca30e2a51 (from 18810d1ebac89232d8f218a318ed9ff7ef198e96)
Author: Matthew Wilcox <matthew@wil.cx>
Date:   Fri Feb 24 12:46:23 2006 -0700

    [IA64] Fix pcibios_setup
    
    pcibios_setup() should return NULL if it handled a parameter.  Since ia64
    handles no parameters, it should return the string that was passed in,
    not NULL.  This brings ia64 into line with all other architectures that
    handle no parameters.
    
    Signed-off-by: Matthew Wilcox <matthew@wil.cx>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 0b30ca0..9ba32b2 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -579,7 +579,7 @@ pcibios_align_resource (void *data, stru
 char * __init
 pcibios_setup (char *str)
 {
-	return NULL;
+	return str;
 }
 
 int

diff-tree 18810d1ebac89232d8f218a318ed9ff7ef198e96 (from 312f1f0141627a58bf72c55f0e7bc5d6f118a372)
Author: Jack Steiner <steiner@sgi.com>
Date:   Thu Feb 23 13:16:44 2006 -0600

    [IA64-SGI] Make number of TIO nodes configurable
    
    Make the limit for the number of TIO nodes a function of the number
    of C/M nodes in the system instead of a hardcoded constant.  The
    number of TIO nodes should be the same as the number of C/M nodes.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
index 91c31be..16adc93 100644
--- a/include/asm-ia64/sn/arch.h
+++ b/include/asm-ia64/sn/arch.h
@@ -31,7 +31,8 @@
  * 	to ACPI3.0, this limit will be removed. The notion of "compact nodes"
  * 	should be deleted and TIOs should be included in MAX_NUMNODES.
  */
-#define MAX_COMPACT_NODES	512
+#define MAX_TIO_NODES		MAX_NUMNODES
+#define MAX_COMPACT_NODES	(MAX_NUMNODES + MAX_TIO_NODES)
 
 /*
  * Maximum number of nodes in all partitions and in all coherency domains.

diff-tree 312f1f0141627a58bf72c55f0e7bc5d6f118a372 (from 5d1a88af826b03edaac4d2bd2f25af56a54f26e6)
Author: Horms <horms@verge.net.au>
Date:   Wed Feb 22 09:57:55 2006 +0900

    [IA64] Document the "nomca" boot parameter
    
    "nomca" can be used to disable machine check handling
    
    Signed-Off-By: Horms <horms@verge.net.au>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b874771..7520539 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1034,6 +1034,8 @@ running once the system is up.
 
 	nomce		[IA-32] Machine Check Exception
 
+	nomca		[IA-64] Disable machine check abort handling
+
 	noresidual	[PPC] Don't use residual data on PReP machines.
 
 	noresume	[SWSUSP] Disables resume and restores original swap

diff-tree 5d1a88af826b03edaac4d2bd2f25af56a54f26e6 (from 50e300dead8dadf32e930ebd80d9810d631aa1a0)
Author: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date:   Fri Feb 17 12:23:09 2006 +0800

    [IA64] Delete a redundant instruction in unaligned_access
    
    unaligned_access does fetch cr.ipsr, then calls
    dispatch_unaligned_handler, but dispatch_unaligned_handler fetches
    cr.ipsr again, so delete the first one.
    
    Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 301f2e9..9f80569 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -1362,7 +1362,6 @@ END(debug_vector)
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
 ENTRY(unaligned_access)
 	DBG_FAULT(30)
-	mov r16=cr.ipsr
 	mov r31=pr		// prepare to save predicates
 	;;
 	br.sptk.many dispatch_unaligned_handler

diff-tree 50e300dead8dadf32e930ebd80d9810d631aa1a0 (from e95a9ec1bb66e07b138861c743192f06e7b3e4de)
Author: Jes Sorensen <jes@sgi.com>
Date:   Fri Feb 17 10:25:39 2006 -0500

    [IA64] show "SN Devices" menu only if CONFIG_SGI_SN
    
    Adrian> On architectures like i386, the "Multimedia Capabilities Port
    Adrian> drivers" menu is visible, but it can't be visited since it
    Adrian> contains nothing usable for CONFIG_SGI_SN=n.
    
    Jes> Thats only a third of the patch, if you want to do that, you should
    Jes> remove the redundant SGI_SN checks below.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/drivers/sn/Kconfig b/drivers/sn/Kconfig
index d95265b..a347316 100644
--- a/drivers/sn/Kconfig
+++ b/drivers/sn/Kconfig
@@ -3,10 +3,11 @@
 #
 
 menu "SN Devices"
+	depends on SGI_SN
 
 config SGI_IOC4
 	tristate "SGI IOC4 Base IO support"
-	depends on (IA64_GENERIC || IA64_SGI_SN2) && MMTIMER
+	depends on MMTIMER
 	default m
 	---help---
 	This option enables basic support for the SGI IOC4-based Base IO
@@ -19,7 +20,6 @@ config SGI_IOC4
 
 config SGI_IOC3
 	tristate "SGI IOC3 Base IO support"
-	depends on (IA64_GENERIC || IA64_SGI_SN2)
 	default m
 	---help---
 	This option enables basic support for the SGI IOC3-based Base IO
