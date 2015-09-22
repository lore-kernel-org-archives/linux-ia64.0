From: =?UTF-8?q?=C3=89meric=20MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 22 Sep 2015 21:58:48 +0000
Subject: [PATCH] ia64: Wire up kcmp syscall
Message-Id: <1442959128-7639-1-git-send-email-emeric.maschino@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Hi,

systemd > 218 fails to compile on ia64 with:

     error: ‘__NR_kcmp’ undeclared [1].

I've been told that this is because the kcmp syscall hasn't been wired up
for the ia64 arch [2].

The proposed patch thus wire up the kcmp syscall for the ia64 arch.

     Émeric

[1] https://bugs.gentoo.org/show_bug.cgi?idV0492
[2] https://bugs.gentoo.org/show_bug.cgi?idV0492#c17

Signed-off-by: Émeric MASCHINO <emeric.maschino@gmail.com>
---
diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 99c96a5..db73390 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -11,7 +11,7 @@
 
 
 
-#define NR_syscalls			321 /* length of syscall table */
+#define NR_syscalls			322 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index 98e94e1..9038726 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -334,5 +334,6 @@
 #define __NR_execveat			1342
 #define __NR_userfaultfd		1343
 #define __NR_membarrier			1344
+#define __NR_kcmp			1345
 
 #endif /* _UAPI_ASM_IA64_UNISTD_H */
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 37cc7a6..dcd97f8 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1770,5 +1770,6 @@ sys_call_table:
 	data8 sys_execveat
 	data8 sys_userfaultfd
 	data8 sys_membarrier
+	data8 sys_kcmp				// 1345
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
