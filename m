From: Keith Owens <kaos@sgi.com>
Date: Thu, 03 Apr 2003 02:14:39 +0000
Subject: [Linux-ia64] [patch] 2.4.21-pre5 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-105590723705385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial correction of array size.

--- arch/ia64/kernel/mca.c.orig	Thu Apr  3 12:11:42 2003
+++ arch/ia64/kernel/mca.c	Thu Apr  3 12:12:13 2003
@@ -72,7 +72,7 @@
 u64				ia64_mca_stack[1024] __attribute__((aligned(16)));
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
-u64				ia64_init_stack[INIT_TASK_SIZE] __attribute__((aligned(16)));
+u64				ia64_init_stack[INIT_TASK_SIZE/8] __attribute__((aligned(16)));
 u64				ia64_mca_sal_data_area[1356];
 u64				ia64_tlb_functional;
 u64				ia64_os_mca_recovery_successful;


