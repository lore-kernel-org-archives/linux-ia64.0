From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 08:48:28 +0000
Subject: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The bottom of kernel rbs stack is the memory used to spill user
dirty stack register partition when entering the kernel.  This
space is heavily used on every kernel entry and exit. It deserve
having its own dedicated cache line and not to share with tail
end of thread_info which is not used heavily.

Align the bottom of kernel rbs stack to 128 byte boundary.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/ptrace.h.orig	2006-01-19 16:45:49.695591377 -0800
+++ ./include/asm-ia64/ptrace.h	2006-01-20 02:24:05.985205410 -0800
@@ -75,7 +75,7 @@
 # define KERNEL_STACK_SIZE_ORDER		0
 #endif
 
-#define IA64_RBS_OFFSET			((IA64_TASK_SIZE + IA64_THREAD_INFO_SIZE + 15) & ~15)
+#define IA64_RBS_OFFSET			((IA64_TASK_SIZE + IA64_THREAD_INFO_SIZE + 127) & ~127)
 #define IA64_STK_OFFSET			((1 << KERNEL_STACK_SIZE_ORDER)*PAGE_SIZE)
 
 #define KERNEL_STACK_SIZE		IA64_STK_OFFSET


