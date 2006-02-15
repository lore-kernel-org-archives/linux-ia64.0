From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 15 Feb 2006 14:33:59 +0000
Subject: missing entries in fsys.S
Message-Id: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Tony,

It appears that Linus's 2.6 git tree is missing some entryies in fsys.S.
I don't know abot your particular GIT tree. In any case, here is a patch
to fix this.

signed-off-by: <eranian@hpl.hp.com>

changelog:
	- add new system calls to fastsyscall table in fsys.S

-- 

-Stephane

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fsys.diff"

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -878,7 +878,50 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
-	#define __NR_syscall_last	1255
+	data8 0				// sys_clock_getres	// 1255
+	data8 0				// sys_clock_nanosleep
+	data8 0				// sys_fstatfs64
+	data8 0				// sys_statfs64
+	data8 0				// sys_mbind
+	data8 0				// sys_get_mempolicy	// 1260
+	data8 0				// sys_set_mempolicy
+	data8 0				// sys_mq_open
+	data8 0				// sys_mq_unlink
+	data8 0				// sys_mq_timedsend
+	data8 0				// sys_mq_timedreceive	// 1265
+	data8 0				// sys_mq_notify
+	data8 0				// sys_mq_getsetattr
+	data8 0				// sys_ni_syscall	// reserved for kexec_load
+	data8 0				// sys_ni_syscall	// reserved for vserver
+	data8 0				// sys_waitid		// 1270
+	data8 0				// sys_add_key
+	data8 0				// sys_request_key
+	data8 0				// sys_keyctl
+	data8 0				// sys_ioprio_set
+	data8 0				// sys_ioprio_get	// 1275
+	data8 0				// sys_ni_syscall
+	data8 0				// sys_inotify_init
+	data8 0				// sys_inotify_add_watch
+	data8 0				// sys_inotify_rm_watch
+	data8 0 			// sys_migrate_pages	// 1280
+	data8 0				// sys_openat
+	data8 0				// sys_mkdirat
+	data8 0				// sys_mknodat
+	data8 0				// sys_fchownat
+	data8 0				// sys_futimesat	// 1285
+	data8 0				// sys_newfstatat
+	data8 0				// sys_unlinkat
+	data8 0				// sys_renameat
+	data8 0				// sys_linkat
+	data8 0				// sys_symlinkat	// 1290
+	data8 0				// sys_readlinkat
+	data8 0				// sys_fchmodat
+	data8 0				// sys_faccessat
+	data8 0				// sys_ni_syscall	// reserved for pselect
+	data8 0				// sys_ni_syscall	// 1295 reserved for ppoll
+	data8 0				// sys_unshare
+
+	#define __NR_syscall_last	1297
 
 	.space 8*(NR_syscalls + 1024 - __NR_syscall_last), 0
 

--ZGiS0Q5IWpPtfppv--
