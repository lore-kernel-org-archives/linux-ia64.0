From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 17 Mar 2003 22:13:28 +0000
Subject: [Linux-ia64] [patch] extra info for show_regs()
Message-Id: <marc-linux-ia64-105590709806147@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Bjorn,

Here is a small patch to 2.4.21-pre5 that adds a bit of extra info
to the show_regs() function.

Thanks,
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


--- linux-2.4.21-pre5-ia64-030312.pristine/arch/ia64/kernel/process.c	Sun Mar 16 10:18:53 2003
+++ linux-2.4.21-pre5-ia64-030312/arch/ia64/kernel/process.c	Sun Mar 16 10:24:02 2003
@@ -78,6 +78,8 @@
 	unsigned long ip = regs->cr_iip + ia64_psr(regs)->ri;
 
 	printk("\nPid: %d, comm: %20s\n", current->pid, current->comm);
+	printk("Registers: cpu %d, sapicid 0x%04x\n",
+		smp_processor_id(), hard_smp_processor_id());
 	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s\n",
 	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted());
 	printk("unat: %016lx pfs : %016lx rsc : %016lx\n",

