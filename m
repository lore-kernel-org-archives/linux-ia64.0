From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Oct 2005 19:15:52 +0000
Subject: Re: [RFC] Extend notify_die() hooks for IA64
Message-Id: <20051026191552.GA20969@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10137.1128667602@kao2.melbourne.sgi.com>
In-Reply-To: <10137.1128667602@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 07, 2005 at 04:46:42PM +1000, Keith Owens wrote:
> This mail is only for discussion, the patch is 2.6.15-rc1 material.  It
> has been compiled and has minimal testing.  Against 2.6.14-rc3.

I applied your patch to Tony Luck's test tree. Added some changes of my own
to XPC so it would register for the notify_die() callouts. And I did some
preliminary testing which showed that things for the most part worked as
advertised.

I used DIE_MACHINE_RESTART and DIE_MACHINE_HALT to get XPC to indicate to
other partitions (on a SGI Altix system) to disengage from accessing the
terminating partitions memory.

And I used DIE_MCA_MONARCH_ENTER and DIE_INIT_MONARCH_ENTER to indicate to
other partitions to ignore the fact that our heartbeat wasn't incrementing.
And I used DIE_MCA_MONARCH_LEAVE and DIE_INIT_MONARCH_LEAVE to indicate that
we should now be heartbeating again.

I also needed to make a few changes to kdebug.h and trap.c (see patch below)
to allow register_notify_die() to be utilized by a module. And I added an
unregister_notify_die() since a module can be removed. Would it be acceptable
to add such changes should your proposed patch find approval?

Is there a reason why the notify_die() callout isn't being added to
emergency_restart()?

Thanks,
Dean


Index: linux-2.6.git-test/arch/ia64/kernel/traps.c
=================================--- linux-2.6.git-test.orig/arch/ia64/kernel/traps.c	2005-10-25 08:15:13.478012900 -0500
+++ linux-2.6.git-test/arch/ia64/kernel/traps.c	2005-10-25 08:15:39.592602522 -0500
@@ -32,7 +32,8 @@
 struct notifier_block *ia64die_chain;
 static DEFINE_SPINLOCK(die_notifier_lock);
 
-int register_die_notifier(struct notifier_block *nb)
+int
+register_die_notifier(struct notifier_block *nb)
 {
 	int err = 0;
 	unsigned long flags;
@@ -41,6 +42,19 @@
 	spin_unlock_irqrestore(&die_notifier_lock, flags);
 	return err;
 }
+EXPORT_SYMBOL_GPL(register_die_notifier);
+
+int
+unregister_die_notifier(struct notifier_block *nb)
+{
+	int err = 0;
+	unsigned long flags;
+	spin_lock_irqsave(&die_notifier_lock, flags);
+	err = notifier_chain_unregister(&ia64die_chain, nb);
+	spin_unlock_irqrestore(&die_notifier_lock, flags);
+	return err;
+}
+EXPORT_SYMBOL_GPL(unregister_die_notifier);
 
 void __init
 trap_init (void)
Index: linux-2.6.git-test/include/asm-ia64/kdebug.h
=================================--- linux-2.6.git-test.orig/include/asm-ia64/kdebug.h	2005-10-25 08:15:13.475083504 -0500
+++ linux-2.6.git-test/include/asm-ia64/kdebug.h	2005-10-25 08:15:39.593578987 -0500
@@ -38,7 +38,8 @@
 	int signr;
 };
 
-int register_die_notifier(struct notifier_block *nb);
+extern int register_die_notifier(struct notifier_block *);
+extern int unregister_die_notifier(struct notifier_block *);
 extern struct notifier_block *ia64die_chain;
 
 enum die_val {
