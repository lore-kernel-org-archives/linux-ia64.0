From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 10 Sep 2003 22:26:48 +0000
Subject: [PATCH] 2.4 force_successful_syscall()
Message-Id: <marc-linux-ia64-106323341214232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a 2.4 backport of this change to 2.5:

    http://linux.bkbits.net:8080/linux-2.5/cset@1.1046.238.7?nav=index.html

Alpha, ppc, and sparc64 define force_successful_syscall_return() in 2.5,
but since it's not obvious to me how to do it correctly in 2.4, I left
them unchanged.

Bjorn

=== drivers/char/mem.c 1.17 vs edited ==--- 1.17/drivers/char/mem.c	Tue Jan 28 09:18:51 2003
+++ edited/drivers/char/mem.c	Wed Sep 10 18:05:05 2003
@@ -21,6 +21,7 @@
 #include <linux/raw.h>
 #include <linux/tty.h>
 #include <linux/capability.h>
+#include <linux/ptrace.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -503,16 +504,23 @@
  */
 static loff_t memory_lseek(struct file * file, loff_t offset, int orig)
 {
+	loff_t ret;
+
 	switch (orig) {
 		case 0:
 			file->f_pos = offset;
-			return file->f_pos;
+			ret = file->f_pos;
+			force_successful_syscall_return();
+			break;
 		case 1:
 			file->f_pos += offset;
-			return file->f_pos;
+			ret = file->f_pos;
+			force_successful_syscall_return();
+			break;
 		default:
-			return -EINVAL;
+			ret = -EINVAL;
 	}
+	return ret;
 }
 
 static int open_port(struct inode * inode, struct file * filp)
=== fs/fcntl.c 1.8 vs edited ==--- 1.8/fs/fcntl.c	Tue Aug  6 08:41:51 2002
+++ edited/fs/fcntl.c	Wed Sep 10 18:08:50 2003
@@ -11,6 +11,7 @@
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/iobuf.h>
+#include <linux/ptrace.h>
 
 #include <asm/poll.h>
 #include <asm/siginfo.h>
@@ -293,6 +294,7 @@
 			 * to fix this will be in libc.
 			 */
 			err = filp->f_owner.pid;
+			force_successful_syscall_return();
 			break;
 		case F_SETOWN:
 			lock_kernel();
=== fs/proc/base.c 1.14 vs edited ==--- 1.14/fs/proc/base.c	Mon Jul 14 14:10:30 2003
+++ edited/fs/proc/base.c	Wed Sep 10 18:10:34 2003
@@ -473,7 +473,24 @@
 }
 #endif
 
+static loff_t mem_lseek(struct file * file, loff_t offset, int orig)
+{
+	switch (orig) {
+	case 0:
+		file->f_pos = offset;
+		break;
+	case 1:
+		file->f_pos += offset;
+		break;
+	default:
+		return -EINVAL;
+	}
+	force_successful_syscall_return();
+	return file->f_pos;
+}
+
 static struct file_operations proc_mem_operations = {
+	llseek:		mem_lseek,
 	read:		mem_read,
 	write:		mem_write,
 	open:		mem_open,
=== include/asm-ia64/ptrace.h 1.6 vs edited ==--- 1.6/include/asm-ia64/ptrace.h	Wed Jul 30 07:33:09 2003
+++ edited/include/asm-ia64/ptrace.h	Wed Sep 10 18:00:03 2003
@@ -248,11 +248,10 @@
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
-static inline void
-force_successful_syscall_return (void)
-{
-	ia64_task_regs(current)->r8 = 0;
-}
+#define force_successful_syscall_return()		\
+	do {						\
+		ia64_task_regs(current)->r8 = 0;	\
+	} while (0)
 
 #endif /* !__KERNEL__ */
 
=== include/linux/ptrace.h 1.1 vs edited ==--- 1.1/include/linux/ptrace.h	Tue Feb  5 10:39:40 2002
+++ edited/include/linux/ptrace.h	Wed Sep 10 18:12:08 2003
@@ -23,4 +23,21 @@
 
 #include <asm/ptrace.h>
 
+#ifdef __KERNEL__
+
+#ifndef force_successful_syscall_return
+/*
+ * System call handlers that, upon successful completion, need to return a
+ * negative value should call force_successful_syscall_return() right before
+ * returning.  On architectures where the syscall convention provides for a
+ * separate error flag (e.g., alpha, ia64, ppc{,64}, sparc{,64}, possibly
+ * others), this macro can be used to ensure that the error flag will not get
+ * set.  On architectures which do not support a separate error flag, the macro
+ * is a no-op and the spurious error condition needs to be filtered out by some
+ * other means (e.g., in user-level, by passing an extra argument to the
+ * syscall handler, or something along those lines).
+ */
+#define force_successful_syscall_return() do { } while (0)
+#endif
+
 #endif

