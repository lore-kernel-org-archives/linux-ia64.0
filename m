From: John Levon <levon@movementarian.org>
Date: Wed, 08 Oct 2003 16:05:10 +0000
Subject: [PATCH] kill pointless perfmon abstractions
Message-Id: <marc-linux-ia64-106562954910433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Another small patch, there's no benefit to having the extra code
here.

regards
john

Index: linux-ia64/arch/ia64/kernel/perfmon.c
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/kernel/perfmon.c,v
retrieving revision 1.35
diff -u -a -p -r1.35 perfmon.c
--- linux-ia64/arch/ia64/kernel/perfmon.c	19 Sep 2003 21:01:14 -0000	1.35
+++ linux-ia64/arch/ia64/kernel/perfmon.c	8 Oct 2003 13:57:44 -0000
@@ -544,14 +542,8 @@ static struct vm_operations_struct pfm_v
 	close: pfm_vm_close
 };
 
-#define pfm_wait_task_inactive(t)	wait_task_inactive(t)
 #define pfm_get_cpu_var(v)		__ia64_per_cpu_var(v)
 #define pfm_get_cpu_data(a,b)		per_cpu(a, b)
-typedef	irqreturn_t	pfm_irq_handler_t;
-#define PFM_IRQ_HANDLER_RET(v)	do {  \
-		put_cpu_no_resched(); \
-		return IRQ_HANDLED;   \
-	} while(0);
 
 static inline void
 pfm_put_task(struct task_struct *task)
@@ -2588,7 +2567,7 @@ pfm_task_incompatible(pfm_context_t *ctx
 	/*
 	 * make sure the task is off any CPU
 	 */
-	pfm_wait_task_inactive(task);
+	wait_task_inactive(task);
 
 	/* more to come... */
 
@@ -4686,7 +4665,7 @@ pfm_check_task_state(pfm_context_t *ctx,
 
 	UNPROTECT_CTX(ctx, flags);
 
-	pfm_wait_task_inactive(task);
+	wait_task_inactive(task);
 
 	PROTECT_CTX(ctx, flags);
 
@@ -5407,7 +5386,7 @@ report_spurious:
 	return -1;
 }
 
-static pfm_irq_handler_t
+static irqreturn_t
 pfm_interrupt_handler(int irq, void *arg, struct pt_regs *regs)
 {
 	unsigned long start_cycles, total_cycles;
@@ -5436,7 +5415,9 @@ pfm_interrupt_handler(int irq, void *arg
 
 		pfm_stats[this_cpu].pfm_ovfl_intr_cycles += total_cycles;
 	}
-	PFM_IRQ_HANDLER_RET();
+
+	put_cpu_no_resched();
+	return IRQ_HANDLED;
 }
 
 
