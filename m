From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Wed, 10 Mar 2004 04:40:00 +0000
Subject: IA32 programs make kernel stall on IPF machine when CONFIG_PREEMPT is enabled
Message-Id: <3AA03342E913FA4BA6D8BD0732BFC74B05154D94@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a bug in base kernel 2.6.3. When CONFIG_PREEMPT is enabled, all
IA32 programs will make kernel stall on IPF machines.

Here is the patch to fix it.

diff -Narup a/arch/ia64/ia32/ia32_support.c
b/arch/ia64/ia32/ia32_support.c
--- a/arch/ia64/ia32/ia32_support.c	2004-03-09 23:13:53.000000000
-0800
+++ b/arch/ia64/ia32/ia32_support.c	2004-03-09 23:28:14.052063896
-0800
@@ -134,8 +134,6 @@ ia32_load_state (struct task_struct *t)
 	regs->r17 = (_TSS << 48) | (_LDT << 32) | (__u32) regs->r17;
 	regs->r30 = load_desc(_LDT);				/* LDTD
*/
 	load_TLS(&t->thread, smp_processor_id());
-
-	put_cpu();
 }
 
 /*

