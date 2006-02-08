From: JANAK DESAI <janak@us.ibm.com>
Date: Wed, 08 Feb 2006 23:14:41 +0000
Subject: [PATCH] registration for new system call unshare
Message-Id: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[PATCH] unshare system call: system call registration for ia64

Registers system call for the ia64 architecture.

This patch applies on top of Ken's patch (that added *at calls),
reserves space for ppoll and pselect, and adds unshare at system
call number 1296.

Signed-off-by: Janak Desai <janak@us.ibm.com>

---

 arch/ia64/kernel/entry.S  |    3 +++
 include/asm-ia64/unistd.h |    3 +++
 2 files changed, 6 insertions(+)

diff -Naurp 2.6.16-rc2-git6+ken/arch/ia64/kernel/entry.S 2.6.16-rc2-git6+ia64/arch/ia64/kernel/entry.S
--- 2.6.16-rc2-git6+ken/arch/ia64/kernel/entry.S	2006-02-08 22:36:31.000000000 +0000
+++ 2.6.16-rc2-git6+ia64/arch/ia64/kernel/entry.S	2006-02-08 21:43:30.000000000 +0000
@@ -1614,5 +1614,8 @@ sys_call_table:
 	data8 sys_readlinkat
 	data8 sys_fchmodat
 	data8 sys_faccessat
+	data8 sys_ni_syscall			// reserved for pselect
+	data8 sys_ni_syscall			// 1295 reserved for ppoll
+	data8 sys_unshare
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff -Naurp 2.6.16-rc2-git6+ken/include/asm-ia64/unistd.h 2.6.16-rc2-git6+ia64/include/asm-ia64/unistd.h
--- 2.6.16-rc2-git6+ken/include/asm-ia64/unistd.h	2006-02-08 22:36:32.000000000 +0000
+++ 2.6.16-rc2-git6+ia64/include/asm-ia64/unistd.h	2006-02-08 21:48:32.000000000 +0000
@@ -283,6 +283,9 @@
 #define __NR_readlinkat			1291
 #define __NR_fchmodat			1292
 #define __NR_faccessat			1293
+#define __NR_ni_syscall			1294
+#define __NR_ni_syscall			1295
+#define __NR_unshare			1296
 
 #ifdef __KERNEL__
 


