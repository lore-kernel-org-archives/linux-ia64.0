From: Nathan Scott <nathans@sgi.com>
Date: Fri, 01 Feb 2002 05:55:59 +0000
Subject: [Linux-ia64] [PATCH] 2.5.3 extended attribute syscalls
Message-Id: <marc-linux-ia64-105590698805976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello David,

Here's a patch to hook the 2.5.3 filesystem extended attribute
system calls into the IA64 syscall table.

cheers.

-- 
Nathan


diff -Naur linux-2.5.3/arch/ia64/kernel/entry.S ia64-linux-2.5.3/arch/ia64/kernel/entry.S
--- linux-2.5.3/arch/ia64/kernel/entry.S	Tue Jan 29 10:14:22 2002
+++ ia64-linux-2.5.3/arch/ia64/kernel/entry.S	Fri Feb  1 16:24:59 2002
@@ -1130,18 +1130,18 @@
 	data8 sys_getdents64
 	data8 sys_getunwind			// 1215
 	data8 sys_readahead
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall			// 1220
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall			// 1225
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
+	data8 sys_setxattr
+	data8 sys_lsetxattr
+	data8 sys_fsetxattr
+	data8 sys_getxattr			// 1220
+	data8 sys_lgetxattr
+	data8 sys_fgetxattr
+	data8 sys_listxattr
+	data8 sys_llistxattr
+	data8 sys_flistxattr			// 1225
+	data8 sys_removexattr
+	data8 sys_lremovexattr
+	data8 sys_fremovexattr
 	data8 ia64_ni_syscall
 	data8 ia64_ni_syscall			// 1230
 	data8 ia64_ni_syscall
diff -Naur linux-2.5.3/include/asm-ia64/unistd.h ia64-linux-2.5.3/include/asm-ia64/unistd.h
--- linux-2.5.3/include/asm-ia64/unistd.h	Sat Nov 10 09:26:17 2001
+++ ia64-linux-2.5.3/include/asm-ia64/unistd.h	Fri Feb  1 16:27:13 2002
@@ -206,6 +206,18 @@
 #define __NR_getdents64			1214
 #define __NR_getunwind			1215
 #define __NR_readahead			1216
+#define __NR_setxattr			1217
+#define __NR_lsetxattr			1218
+#define __NR_fsetxattr			1219
+#define __NR_getxattr			1220
+#define __NR_lgetxattr			1221
+#define __NR_fgetxattr			1222
+#define __NR_listxattr			1223
+#define __NR_llistxattr			1224
+#define __NR_flistxattr			1225
+#define __NR_removexattr		1226
+#define __NR_lremovexattr		1227
+#define __NR_fremovexattr		1228
 
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
 

