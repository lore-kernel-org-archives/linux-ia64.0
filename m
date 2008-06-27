From: Doug Chapman <doug.chapman@hp.com>
Date: Fri, 27 Jun 2008 14:45:50 +0000
Subject: [PATCH] ia64: export account_system_vtime
Message-Id: <1214577950.3232.10.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The symbol account_system_vtime is used by the kvm module but
not exported.  This breaks building with CONFIG_VIRT_CPU_ACCOUNTING
and CONFIG_KVM=m.

Signed-off-by: Doug Chapman <doug.chapman@hp.com>

---
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 8c73643..aad1b7b 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -117,6 +117,7 @@ void account_system_vtime(struct task_struct *tsk)
 
 	local_irq_restore(flags);
 }
+EXPORT_SYMBOL_GPL(account_system_vtime);
 
 /*
  * Called from the timer interrupt handler to charge accumulated user time


