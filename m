From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 26 Dec 2002 21:27:29 +0000
Subject: [Linux-ia64] IA-32 emulation issues
Message-Id: <marc-linux-ia64-105590709805630@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I ran some IA-32 test suites last week that uncovered a bunch of issues
in the IA-32 emulation layer that I wanted to report here. 

a) semctl doesn't check for bad cmd

--- sys_ia32.c	Wed Jun  5 15:39:54 2002
+++ sys_ia32.c.new	Thu Dec 19 17:27:50 2002
@@ -2166,6 +2166,9 @@
 	else
 		fourth.__pad = (void *)A(pad);
 	switch (third) {
+	      default:
+		err = -EINVAL;
+		break;
 	      case IPC_INFO:
 	      case IPC_RMID:
 	      case IPC_SET:

b) getdents64 - the system call succeeds, but glibc sets EOVERFLOW. We
   may want to think about getting rid of "struct linux32_dirent" at
   some point.

History from glibc sources:

/* The getdents64 syscall was introduced in 2.4.0-test7.  We test for
   2.4.1 for the earliest version we know the syscall is available.  */
#if __LINUX_KERNEL_VERSION >= 132097
# define __ASSUME_GETDENTS64_SYSCALL    1
#endif

c) readv and iov_len 

Single UNIX spec says that readv should return:

[EINVAL]
The sum of the iov_len values in the iov array overflowed an ssize_t.

The following (untested) patch should fix it. There may be a case for
moving this check into userland.

--- linux/fs/read_write.c	Mon Dec 16 01:06:56 2002
+++ linux/fs/read_write.c.new	Thu Dec 19 16:41:33 2002
@@ -26,6 +26,7 @@
 #include <linux/uio.h>
 #include <linux/smp_lock.h>
 #include <linux/dnotify.h>
+#include <linux/personality.h>
 
 #include <asm/uaccess.h>
 
@@ -268,7 +269,10 @@
 		   
 		   FIXME: put in a proper limits.h for each platform */
 #if BITS_PER_LONG=64
-		if (tot_len > 0x7FFFFFFFFFFFFFFFUL)
+		if ((current->personality & PER_LINUX32) 
+                    && (tot_len > 0x7FFFFFFFUL))
+		    goto out;
+		else if (tot_len > 0x7FFFFFFFFFFFFFFFUL)
 #else
 		if (tot_len > 0x7FFFFFFFUL)
 #endif		


d) msgctl(id, IPC_STAT, &buf) does't behave as expected

This seems to be related to linux/ipc.h:

#if defined(__ia64__) || defined(__hppa__)
  /* On IA-64 and PA-RISC, we always use the "64-bit version" of the IPC structures.  */ 
# define ipc_parse_version(cmd)	IPC_64
#else
int ipc_parse_version (int *cmd);
#endif

However, sys_ia32.c:msgctl32 does a version check against IPC_64 to
figure out whether to use struct msqid_ds or msqid64_ds. I think it
should always be using msqid64_ds, given the above comment.

	-Arun


