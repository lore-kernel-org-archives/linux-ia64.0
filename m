From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:47 +0000
Subject: [PATCH 2.6.13 6/7] MCA/INIT: align the initial task
Message-Id: <20050830050447.7997.44959.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Align the stack for the initial task to be the same alignment as all
other process stacks.  Otherwise the validation code needs special
cases for the intial task, it is currently only page aligned.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 vmlinux.lds.S |    1 +
 1 files changed, 1 insertion(+)

Index: linux/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux.orig/arch/ia64/kernel/vmlinux.lds.S	2005-08-17 14:34:38.404220401 +1000
+++ linux/arch/ia64/kernel/vmlinux.lds.S	2005-08-17 14:36:24.052711993 +1000
@@ -165,6 +165,7 @@ SECTIONS
   __init_end = .;
 
   /* The initial task and kernel stack */
+  . = ALIGN(KERNEL_STACK_SIZE);
   .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
 	{ *(.data.init_task) }
 
