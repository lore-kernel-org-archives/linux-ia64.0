From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 15 Nov 2002 02:22:24 +0000
Subject: [Linux-ia64] First crack at preemption support for IA64
Message-Id: <marc-linux-ia64-105590709805442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi folks,
   Here's my first go at preemption support for IA64.  I've tested it
on the simulator and I2000 UP.  It's very rough around the edges
(especially in entry.S), but someone may have some useful comments for
me... so it's being released here.

So far, it appears that response to mouse movememnts ont eh console,
etc., is *more* jerky with the preempt turned on than without.

Expect a warning from the IDE code when you boot, too.  You'll get the
same thing on IA32 with CONFIG_PREEMPT.

The stuff in entry.S is hard to follow.  The pseudocode works like
this:

ia64_leave_kernel(bool pKern, bool pUser, machine_context_t ctx)
{
	local_irq_disable();
	while (pUser && current->threadinfo->flags & (RESCHED | NOTIFY) ||
	      pKern && preempt_count = 0 &&
		    current->threadinfo->flags & RESCHED) {
		  if (pKern)
			preempt_count() = PREEMPT_ACTIVE;
		   if (current->threadinfo->flags & RESCHED)
		        schedule();
	           else
		        notify_resume();
		   local_irq_disable()
		   if (pKern)
		      preempt_count() = 0;
        }
	set_context(ctx);
}

but the set_context is effectively done in parallel with all of the
other stuff.
			


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.815   -> 1.816  
#	arch/ia64/kernel/entry.S	1.21    -> 1.22   
#	include/asm-ia64/hardirq.h	1.10    -> 1.11   
#	arch/ia64/Config.help	1.10    -> 1.11   
#	arch/ia64/kernel/efivars.c	1.8     -> 1.9    
#	arch/ia64/hp/sim/simserial.c	1.9     -> 1.10   
#	include/asm-ia64/thread_info.h	1.5     -> 1.6    
#	 arch/ia64/config.in	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/11/15	peterc@gelato.unsw.edu.au	1.816
# Preliminary preemption support.
# --------------------------------------------
#
diff -Nru a/arch/ia64/Config.help b/arch/ia64/Config.help
--- a/arch/ia64/Config.help	Fri Nov 15 13:07:05 2002
+++ b/arch/ia64/Config.help	Fri Nov 15 13:07:05 2002
@@ -567,3 +567,13 @@
 
   Select "16MB" for a small granule size.
   Select "64MB" for a large granule size.  This is the current default.
+
+CONFIG_PREEMPT
+  This option reduces the latency of the kernel when reacting to
+  real-time or interactive events by allowing a low priority process to
+  be preempted even if it is in kernel mode executing a system call.
+  This allows applications to run more reliably even when the system is
+  under load.
+
+  Say Y here if you are building a kernel for a desktop, embedded
+  or real-time system.  Say N if you are unsure.
diff -Nru a/arch/ia64/config.in b/arch/ia64/config.in
--- a/arch/ia64/config.in	Fri Nov 15 13:07:05 2002
+++ b/arch/ia64/config.in	Fri Nov 15 13:07:05 2002
@@ -117,6 +117,7 @@
 fi
 
 bool 'SMP support' CONFIG_SMP
+bool 'Preemptible Kernel' CONFIG_PREEMPT
 bool 'Support running of Linux/x86 binaries' CONFIG_IA32_SUPPORT
 bool 'Performance monitor support' CONFIG_PERFMON
 tristate '/proc/pal support' CONFIG_IA64_PALINFO
diff -Nru a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
--- a/arch/ia64/hp/sim/simserial.c	Fri Nov 15 13:07:05 2002
+++ b/arch/ia64/hp/sim/simserial.c	Fri Nov 15 13:07:05 2002
@@ -63,7 +63,6 @@
 
 static char *serial_name = "SimSerial driver";
 static char *serial_version = "0.6";
-static spinlock_t serial_lock = SPIN_LOCK_UNLOCKED;
 
 /*
  * This has been extracted from asm/serial.h. We need one eventually but
@@ -235,14 +234,15 @@
 
 	if (!tty || !info->xmit.buf) return;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) = 0) {
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 	info->xmit.buf[info->xmit.head] = ch;
 	info->xmit.head = (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 static _INLINE_ void transmit_chars(struct async_struct *info, int *intr_done)
@@ -250,7 +250,9 @@
 	int count;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+
+	local_save_flags(flags);
+	local_irq_disable();
 
 	if (info->x_char) {
 		char c = info->x_char;
@@ -293,7 +295,7 @@
 		info->xmit.tail += count;
 	}
 out:
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 static void rs_flush_chars(struct tty_struct *tty)
@@ -334,7 +336,8 @@
 				break;
 			}
 
-			spin_lock_irqsave(&serial_lock, flags);
+			local_save_flags(flags);
+			local_irq_disable();
 			{
 				c1 = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail,
 						       SERIAL_XMIT_SIZE);
@@ -344,7 +347,7 @@
 				info->xmit.head = ((info->xmit.head + c) &
 						   (SERIAL_XMIT_SIZE-1));
 			}
-			spin_unlock_irqrestore(&serial_lock, flags);
+			local_irq_restore(flags);
 
 			buf += c;
 			count -= c;
@@ -352,7 +355,8 @@
 		}
 		up(&tmp_buf_sem);
 	} else {
-		spin_lock_irqsave(&serial_lock, flags);
+		local_save_flags(flags);
+		local_irq_disable();
 		while (1) {
 			c = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
 			if (count < c)
@@ -367,7 +371,7 @@
 			count -= c;
 			ret += c;
 		}
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 	}
 	/*
 	 * Hey, we transmit directly from here in our case
@@ -398,9 +402,10 @@
 	struct async_struct *info = (struct async_struct *)tty->driver_data;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	info->xmit.head = info->xmit.tail = 0;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 
 	wake_up_interruptible(&tty->write_wait);
 
@@ -573,7 +578,8 @@
 	       state->irq);
 #endif
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	{
 		/*
 		 * First unlink the serial port from the IRQ chain...
@@ -611,7 +617,7 @@
 
 		info->flags &= ~ASYNC_INITIALIZED;
 	}
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 /*
@@ -634,13 +640,14 @@
 
 	state = info->state;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
+	local_irq_disable();
 	if (tty_hung_up_p(filp)) {
 #ifdef SIMSERIAL_DEBUG
 		printk("rs_close: hung_up\n");
 #endif
 		MOD_DEC_USE_COUNT;
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 #ifdef SIMSERIAL_DEBUG
@@ -665,11 +672,11 @@
 	}
 	if (state->count) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 	info->flags |= ASYNC_CLOSING;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 
 	/*
 	 * Now we wait for the transmit buffer to clear; and we notify
@@ -776,7 +783,8 @@
 	if (!page)
 		return -ENOMEM;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 
 	if (info->flags & ASYNC_INITIALIZED) {
 		free_page(page);
@@ -857,11 +865,11 @@
 	}
 
 	info->flags |= ASYNC_INITIALIZED;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 	return 0;
 
 errout:
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 	return retval;
 }
 
diff -Nru a/arch/ia64/kernel/efivars.c b/arch/ia64/kernel/efivars.c
--- a/arch/ia64/kernel/efivars.c	Fri Nov 15 13:07:05 2002
+++ b/arch/ia64/kernel/efivars.c	Fri Nov 15 13:07:05 2002
@@ -66,6 +66,7 @@
 #include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/efi.h>
+#include <linux/smp_lock.h>
 
 #include <asm/uaccess.h>
 
@@ -342,6 +343,9 @@
 
 
 
+/*
+ * Called with BKL held
+ */
 static int __init
 efivars_init(void)
 {
@@ -351,10 +355,11 @@
 	efi_char16_t *variable_name = kmalloc(1024, GFP_KERNEL);
 	unsigned long variable_name_size = 1024;
 
-	spin_lock(&efivars_lock);
 
 	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);
 
+        BUG_ON(!kernel_locked());
+
         /* Since efi.c happens before procfs is available,
            we create the directory here if it doesn't
            already exist.  There's probably a better way
@@ -398,7 +403,6 @@
 	} while (status != EFI_NOT_FOUND);
 
 	kfree(variable_name);
-	spin_unlock(&efivars_lock);
 	return 0;
 }
 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Fri Nov 15 13:07:05 2002
+++ b/arch/ia64/kernel/entry.S	Fri Nov 15 13:07:05 2002
@@ -570,10 +570,16 @@
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	// work.need_resched etc. mustn't get changed by this CPU before it returns to userspace:
+.work_recheck:
 (pUser)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUser
-(pUser)	rsm psr.i
+	rsm psr.i				// disable interrupts
 	;;
-(pUser)	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+(pKern) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+(pKern) ld4  r21=[r20]			// preempt_count ->r21
+	;;
+(pKern)	cmp.eq	p6,p0=r21,r0
 	;;
 .work_processed:
 (p6)	ld4 r18=[r17]				// load current_thread_info()->flags
@@ -802,6 +808,11 @@
 .work_pending:
 	tbit.z p6,p0=r18,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
 (p6)	br.cond.sptk.few .notify
+(pKern)	dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
+	;;
+(pKern) ssm psr.i
+(pKern) st4 [r20]=r21
+	
 #if __GNUC__ < 3
 	br.call.spnt.many rp=invoke_schedule
 #else
@@ -811,6 +822,9 @@
 	rsm psr.i
 	;;
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+	st8 [r20]=r0
 	br.cond.sptk.many .work_processed		// re-check
 
 .notify:
@@ -844,7 +858,7 @@
 	br.cond.sptk ia64_leave_kernel
 END(handle_syscall_error)
 
-#ifdef CONFIG_SMP
+#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be needed
 	 * in case a system call gets restarted.
@@ -861,7 +875,7 @@
 	br.ret.sptk.many rp
 END(ia64_invoke_schedule_tail)
 
-#endif /* CONFIG_SMP */
+#endif /* CONFIG_SMP || CONFIG_PREEMPT */
 
 #if __GNUC__ < 3
 
diff -Nru a/include/asm-ia64/hardirq.h b/include/asm-ia64/hardirq.h
--- a/include/asm-ia64/hardirq.h	Fri Nov 15 13:07:05 2002
+++ b/include/asm-ia64/hardirq.h	Fri Nov 15 13:07:05 2002
@@ -83,13 +83,13 @@
 #define hardirq_trylock()	(!in_interrupt())
 #define hardirq_endlock()	do { } while (0)
 
-#define in_atomic()		(preempt_count() != 0)
 #define irq_enter()		(preempt_count() += HARDIRQ_OFFSET)
 
 #if CONFIG_PREEMPT
-# error CONFIG_PREEMT currently not supported.
+# define in_atomic()		((preempt_count() & ~PREEMPT_ACTIVE) != kernel_locked())
 # define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else
+# define in_atomic()		(preempt_count() != 0)
 # define IRQ_EXIT_OFFSET HARDIRQ_OFFSET
 #endif
 
diff -Nru a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
--- a/include/asm-ia64/thread_info.h	Fri Nov 15 13:07:05 2002
+++ b/include/asm-ia64/thread_info.h	Fri Nov 15 13:07:05 2002
@@ -15,7 +15,8 @@
 #define TI_ADDR_LIMIT	0x10
 #define TI_PRE_COUNT	0x18
 
-#define PREEMPT_ACTIVE	0x4000000
+#define PREEMPT_ACTIVE_BIT 26
+#define PREEMPT_ACTIVE	(1<<PREEMPT_ACTIVE_BIT)
 
 #ifndef __ASSEMBLY__
 




--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

